//
//  SpotifyService.swift
//  Debaser
//
//  Created by Markus Bergh on 2017-12-06.
//  Copyright © 2017 Markus Bergh. All rights reserved.
//

import Combine
import Foundation

enum SpotifyNotification: String {
    case error = "spotifyGenericError"
    case authError = "spotifyAuthError"
    case loginSuccessful = "spotifyLoginSuccessful"
    case userLoggedOut = "spotifyUserLoggedOut"
    case userRetrieved = "spotifyUserRetrieved"
    case streamDidChangePosition = "spotifyStreamDidChangePosition"
    case controllerError = "spotifyStreamingControllerError"
}

enum SpotifyServiceError: Equatable, Error {
    /// Service
    case auth
    case unknown
    case requestError(String)
    case userNotFound
    case tracksNotFoundForArtist
    case playerUnavailable
    case streamURLUnavailable
    case couldNotStartStream(String)
    case premiumAccountRequired
    
    /// Session
    case invalidSession
    case refreshToken(String)
    case previousSessionNotFound
    case unknownError
    case errorWhileRefreshingToken
}

enum SpotifyUser {
    case active
    case inactive
}

class SpotifyService: NSObject {

    /// Core
    let auth = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController?
    var session: SPTSession?
    var currentUser: SPTUser?
    var currentArtistURI: String?

    /// Is user logged in?
    var userState: SpotifyUser = .inactive

    /// Login url for authentication
    var loginUrl: URL?
    
    /// Is stream active?
    var streaming = false

    /// Singleton instance
    static let shared = SpotifyService()
    
    /// Credentials
    static let cliendID = "bebe3d1ed01a4d9ba8d9fe2351d20936"
    static let redirectURL = "debaser-spotify-login://callback"
    static let sessionStorageKey = "spotifyCurrentSession"

    override private init() {
        super.init()

        // Subscribe to login event
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.updateAfterFirstLogin),
                                               name: Notification.Name(rawValue: SpotifyNotification.loginSuccessful.rawValue),
                                               object: nil)
    }
    
    /// Custom log helper
    ///
    /// - parameter message: The message to log
    static func log(message: String) {
        print("🎹 [SpotifyService]: \(message)")
    }
}

// MARK: Initializing

extension SpotifyService {
    
    /// Initial configuration
    func configure() {
        // Set up some requiremenets
        setup()

        // Check if we have a previous session
        do {
            try checkPreviousSession()
        } catch SpotifyServiceError.previousSessionNotFound {
            return SpotifyService.log(message: "Previous session not found")
        } catch {
            return SpotifyService.log(message: "Unknown error while getting previous session")
        }
        
        // We are safe to say we are logged in now
        userState = .active
    }

    /// Initial setup
    private func setup() {
        SpotifyService.log(message: "Setting up")

        guard let auth = self.auth else { return }

        auth.clientID = SpotifyService.cliendID
        auth.redirectURL = URL(string: SpotifyService.redirectURL)
        auth.requestedScopes = [SPTAuthStreamingScope]

        loginUrl = auth.spotifyAppAuthenticationURL()
    }

    /// Sets first session
    @objc private func updateAfterFirstLogin() {
        SpotifyService.log(message: "updateAfterFirstLogin")

        let userDefaults = UserDefaults.standard

        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            guard let sessionDataObj = sessionObj as? Data else { return }
            
            do {
                if let firstTimeSession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(sessionDataObj) as? SPTSession {
                    session = firstTimeSession
                    initializePlayer(authSession: firstTimeSession)
                }
            } catch {
                print("Error while reading session")
                
                return
            }
        }
    }
    
}

// MARK: - Helpers

extension SpotifyService {
    
    ///
    /// Log out from current session
    ///
    /// - parameter userDefaults: User defaults to clear
    ///
    func logout(with userDefaults: UserDefaults = UserDefaults.standard) {
        print("[SpotifyService]: Log out")

        guard let player = self.player else { return }
        
        // Delete previous token
        userDefaults.removeObject(forKey: "SpotifySession")

        player.logout()
    }

    ///
    /// Get current user
    ///
    /// - throws: An error of type `SpotifyServiceError`
    ///
    private func getUser() throws {
        guard let session = self.session else {
            throw SpotifyServiceError.invalidSession
        }

        SPTUser.requestCurrentUser(withAccessToken: session.accessToken, callback: { (error, data) in
            if let error = error {
                return SpotifyService.log(message: "Error when requesting user, \(error.localizedDescription)")
            }
            
            guard let user = data as? SPTUser else {
                return SpotifyService.log(message: "User was not found")
            }
            
            self.currentUser = user
            
            // Dispatch
            let notificationName = Notification.Name(rawValue: SpotifyNotification.userRetrieved.rawValue)
            NotificationCenter.default.post(name: notificationName, object: nil)
        })
    }

    ///
    /// Renew session
    ///
    /// - throws: An error of type `SpotifyServiceError`
    /// - returns: A user session
    ///
    private func renewSession() throws {
        SpotifyService.log(message: "Try to renew token")

        guard let auth = self.auth else { throw SpotifyServiceError.unknownError }

        auth.renewSession(auth.session, callback: { (error, session) in
            if let error = error {
                return SpotifyService.log(message: "Error while refreshing token: \(error.localizedDescription)")
            }

            guard let session = session else {
                return SpotifyService.log(message: "Session was invalid")
            }
                    
            self.session = session
            self.initializePlayer(authSession: session)
        })
    }
    
    ///
    /// Check for previous session
    ///
    /// - throws: An error of type `SpotifyServiceError`
    /// - parameter userDefaults: User defaults to look in
    ///
    private func checkPreviousSession(_ userDefaults: UserDefaults = UserDefaults.standard) throws {
        SpotifyService.log(message: "Get previous session from user defaults")
        
        guard let sessionData = userDefaults.object(forKey: "SpotifySession") as? Data else {
            throw SpotifyServiceError.previousSessionNotFound
        }
        
        do {
            guard let previousSession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(sessionData) as? SPTSession, previousSession.isValid() else {
                // Token might has expired, so try and refresh it
                do {
                    try refreshTokenForUser()
                } catch {
                    throw SpotifyServiceError.errorWhileRefreshingToken
                }
                
                return
            }
            
            self.session = previousSession
            self.initializePlayer(authSession: previousSession)
        } catch {
            throw SpotifyServiceError.unknownError
        }
    }
    
    /// Refresh token
    private func refreshTokenForUser() throws {
        SpotifyService.log(message: "Previous token has probably expired")
        
        guard let auth = self.auth, auth.hasTokenRefreshService else {
            throw SpotifyServiceError.unknown
        }
        
        return try renewSession()
    }
    
    ///
    /// Initializes a player
    ///
    /// - parameter authSession: Current session
    ///
    private func initializePlayer(authSession: SPTSession) {
        if player == nil {
            SpotifyService.log(message: "Initialize player")

            guard let player = SPTAudioStreamingController.sharedInstance() else {
                return
            }

            guard let auth = self.auth else { return }

            // Set delegates
            player.playbackDelegate = self
            player.delegate = self
            
            self.player = player

            do {
                try player.start(withClientId: auth.clientID)
            } catch (let error) {
                print("[SpotifyService]: Error when initializing player, \(error.localizedDescription)")
            }
        }
        
        self.tryLoginWithPlayer()
    }

    /// Login with current player
    private func tryLoginWithPlayer() {
        SpotifyService.log(message: "Try to login with player")

        guard let player = self.player, let session = self.session else { return }

        player.login(withAccessToken: session.accessToken)
    }
    
}

// MARK: - SPTAudioStreamingDelegate

extension SpotifyService: SPTAudioStreamingDelegate {
    
    ///
    /// After a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
    ///
    /// - parameter audioStreaming: Current streaming controller
    ///
    internal func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController) {
        SpotifyService.log(message: "User is authenticated")
    
        do {
            try getUser()

            // User is definitely logged in
            userState = .active
            
            SpotifyService.log(message: "Current user retrieved")
        } catch SpotifyServiceError.requestError(let errorDescription) {
            SpotifyService.log(message: "There was an error while requesting user: \(errorDescription)")
        } catch {
            SpotifyService.log(message: "Unexpected error while requesting user")
        }
    }

    ///
    /// Called when there was an error with the streaming controller
    ///
    /// - parameters:
    ///   - audioStreaming: Current streaming controller
    ///   - error: Received error
    ///
    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error) {
        SpotifyService.log(message: "Streaming controller received error, \(error)")
        
        if userState == .active {
            logout()
        }
        
        // Dispatch error further
        let notificationName = Notification.Name(SpotifyNotification.controllerError.rawValue)
        NotificationCenter.default.post(name: notificationName, object: error as NSError)
    }
    
}

// MARK: - SPTAudioStreamingPlaybackDelegate

extension SpotifyService: SPTAudioStreamingPlaybackDelegate {

    ///
    /// Called when streaming changes position
    ///
    /// - parameters:
    ///   - audioStreaming: Current streaming controller
    ///   - position: The current time interval
    ///
    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePosition position: TimeInterval) {
        guard let player = self.player else { return }

        // Get progress
        let duration = player.metadata.currentTrack?.duration ?? 0
        let current = position / duration * 100.0
        let total = player.metadata.currentTrack?.duration ?? 0

        // Set dictionary
        let metaDurationDict: [String: TimeInterval] = ["current": current, "total": total]

        // Dispatch
        let notificationName = Notification.Name(SpotifyNotification.streamDidChangePosition.rawValue)
        NotificationCenter.default.post(name: notificationName, object: metaDurationDict)
    }

    ///
    /// Called when track playback starts
    ///
    /// - parameters:
    ///   - audioStreaming: Current streaming controller
    ///   - trackUri: Current track
    ///
    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStartPlayingTrack trackUri: String) {
        SpotifyService.log(message: "didStartPlayingTrack, \(trackUri)")
    }

    ///
    /// Called when track playback stops
    ///
    /// - parameters:
    ///   - audioStreaming: Current streaming controller
    ///   - trackUri: Current track
    ///
    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didStopPlayingTrack trackUri: String) {
        SpotifyService.log(message: "didStopPlayingTrack, \(trackUri)")
    }
    
    ///
    /// Called when user logouts
    ///
    /// - parameters:
    ///   - audioStreaming: Current streaming controller
    ///
    internal func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        SpotifyService.log(message: "audioStreamingDidLogout")
        
        // We can truly say we are logged out
        userState = .inactive

        // Dispatch
        let notificationName = Notification.Name(SpotifyNotification.userLoggedOut.rawValue)
        NotificationCenter.default.post(name: notificationName, object: nil)
    }
    
}

// MARK: - Playback

extension SpotifyService {
    
    /// Handles a play or pause of current stream
    func playPauseStream() {
        guard let player = self.player else { return }
        
        let isPlaying = !player.playbackState.isPlaying
        
        player.setIsPlaying(isPlaying) { error in
            SpotifyService.log(message: "didTryPlayPauseStream, \(isPlaying)")

            self.streaming = player.playbackState.isPlaying
        }
    }

    /// Handles a stop
    func stop() {
        guard let player = self.player else { return }
        
        player.setIsPlaying(false, callback: nil)
    }

    ///
    /// Handles a search for the requested artist
    ///
    /// - parameters:
    ///   - query: The string to search for
    ///   - returns: A publisher that outputs an error of type `SpotifyServiceError`
    ///
    func searchTrackForEventArtist(query: String) -> AnyPublisher<Void, SpotifyServiceError> {
        SpotifyService.log(message: "Performing search for: \(query)")

        guard let session = self.session else {
            return Fail(error: SpotifyServiceError.invalidSession).eraseToAnyPublisher()
        }
        
        return Future<Void, SpotifyServiceError> { promise in
            SPTSearch.perform(withQuery: query, queryType: .queryTypeArtist, accessToken: session.accessToken) { (error, object) in
                let result = Result { () throws in
                    if let error = error {
                        SpotifyService.log(message: "Error when performing search: \(error.localizedDescription)")
                        
                        throw SpotifyServiceError.tracksNotFoundForArtist
                    }
                    
                    // No errors, will try and stream
                    if let list = object as? SPTListPage, let items = list.items, let firstArtist = items.first as? SPTPartialArtist {
                        SpotifyService.log(message: "Setting current track: \(firstArtist.uri.absoluteString)")
                        
                        // Save reference to playable artist
                        self.currentArtistURI = firstArtist.uri.absoluteString
                    } else {
                        // Zero search result
                        SpotifyService.log(message: "There was a successful search, but no tracks would be found")
                        
                        throw SpotifyServiceError.tracksNotFoundForArtist
                    }
                }.mapError { error in
                    return SpotifyServiceError.tracksNotFoundForArtist
                }
                
                // Call promise with result
                promise(result)
            }

        }.eraseToAnyPublisher()
    }

    ///
    /// Executed when user wants to stream the current track
    ///
    /// - throws: An error of type `SpotifyServiceError`
    ///
    func playTrackForArtist() throws {
        guard let player = self.player else { throw SpotifyServiceError.playerUnavailable }
        guard let streamURL = currentArtistURI else { throw SpotifyServiceError.streamURLUnavailable }

        player.playSpotifyURI(streamURL, startingWith: 0, startingWithPosition: 0) { error in
            if let error = error {
                SpotifyService.log(message: "There was an error while stremaing: \(error.localizedDescription)")
            }
            
            self.streaming = true
        }
    }
    
}
