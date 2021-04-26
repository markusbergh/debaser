//
//  SpotifyService.swift
//  Debaser
//
//  Created by Markus Bergh on 2017-12-06.
//  Copyright © 2017 Markus Bergh. All rights reserved.
//

import Foundation

enum SpotifyNotification: String {
    case AuthError = "spotifyAuthError"
    case LoginSuccessful = "spotifyLoginSuccessful"
    case Error = "genericError"
}

enum SpotifyServiceError: String {
    case authError = "spotifyAuthError"
    case tracksNotFoundForArtist = "tracksNotFoundForArtist"
    case unknown = "unknown"
}

class SpotifyService: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {

    // Spotify core
    let auth = SPTAuth.defaultInstance()
    var player: SPTAudioStreamingController?
    var session: SPTSession?
    var currentUser: SPTUser?
    var currentArtistURI: String?

    // Is user logged in?
    var isLoggedIn = false

    // Login url for authentication
    var loginUrl: URL?
    
    // Is stream active?
    var streaming = false

    // Singleton instance
    static let shared = SpotifyService()

    override private init() {
        super.init()

        // Subscribe to login event
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateAfterFirstLogin), name: Notification.Name(rawValue: "spotifyLoginSuccessful"), object: nil)
    }

    private func setup() {
        print("[SpotifyService]: Setting up")

        guard let auth = self.auth else { return }

        auth.clientID = "bebe3d1ed01a4d9ba8d9fe2351d20936"
        auth.redirectURL = URL(string: "debaser-spotify-login://callback")
        auth.requestedScopes = [SPTAuthStreamingScope]

        loginUrl = auth.spotifyAppAuthenticationURL()
    }

    @objc private func updateAfterFirstLogin() {
        print("[SpotifyService]: updateAfterFirstLogin")

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

    private func initializePlayer(authSession: SPTSession) {
        if player == nil {
            print("[SpotifyService]: Initialize player")

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
                print(error.localizedDescription)
            }
        }
        
        self.tryLoginWithPlayer()
    }

    private func tryLoginWithPlayer() {
        print("[SpotifyService]: Try login with player")

        guard let player = self.player, let session = self.session else { return }

        player.login(withAccessToken: session.accessToken)
    }

    // Get current user
    private func getUser() -> Void {
        guard let session = self.session else { return }

        SPTUser.requestCurrentUser(withAccessToken: session.accessToken, callback: { (error, data) in
            guard let user = data as? SPTUser else {
                print("[SpotifyService]: Error when fetching user")

                return
            }

            self.currentUser = user

            NotificationCenter.default.post(name: Notification.Name(rawValue: "spotifyUserRetrieved"), object: nil)
        })
    }

    private func renewToken() {
        print("[SpotifyService]: Trying to renew token")

        guard let auth = self.auth else { return }

        auth.renewSession(auth.session, callback: { (error, session) in
            if let error = error {
                print("[SpotifyService]: Error while refreshing token: \(error.localizedDescription)")
            }

            guard let session = session else { return }

            // Set up player
            self.initializePlayer(authSession: session)

            self.session = session
        })
    }

    // MARK: - Authenticaion Delegate

    // After a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
    internal func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("[SpotifyService]: User is authenticated")

        isLoggedIn = true

        // Get current user
        getUser()

        // Dispatch
        NotificationCenter.default.post(name: Notification.Name(rawValue: "spotifyUserAuthenticated"), object: nil)
    }

    // MARK: - Track player Delegate

    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        guard let player = self.player else { return }

        // Get progress
        let duration = player.metadata.currentTrack?.duration ?? 0
        let current = position / duration * 100.0
        let total = player.metadata.currentTrack?.duration ?? 0

        // Set dictionary
        let metaDurationDict: [String: TimeInterval] = ["current": current, "total": total]

        // Dispatch
        NotificationCenter.default.post(name: Notification.Name(rawValue: "spotifyStreamDidChangePosition"), object: metaDurationDict)
    }

    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        print("[SpotifyService]: didStartPlayingTrack", trackUri)
    }

    internal func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        print("[SpotifyService]: didStopPlayingTrack", trackUri)
    }

    internal func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("[SpotifyService]: audioStreamingDidLogout")
    }

    // MARK: - Public

    public func setupHelper() {
        // Set up some requiremenets
        setup()

        // Check if we have a token
        if session == nil {
            print("[SpotifyService]: Get previous session from user defaults")

            // Try and get it from user defaults
            let userDefaults = UserDefaults.standard

            if let sessionObj: AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject?,
               let sessionDataObj = sessionObj as? Data {
                
                do {
                    let previousSession = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(sessionDataObj) as? SPTSession
                    
                    self.session = previousSession
                } catch {
                    print("Error while reading previous session")
                }
            } else {
                print("[SpotifyService]: No previous session found in user defaults")

                return
            }
        }

        // If we have a token, is it valid?
        if let session = self.session, session.isValid() {
            isLoggedIn = true

            // Set up player
            initializePlayer(authSession: session)

            return
        }

        // Token has expired, so try and refresh it
        print("[SpotifyService]: Previous token has probably expired")

        if let auth = self.auth, auth.hasTokenRefreshService {
            renewToken()
        }
    }

    // Close current session
    public func logout() {
        print("[SpotifyService]: Log out")

        // Delete previous token
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "SpotifySession")

        player?.logout()
        isLoggedIn = false

        // Dispatch
        NotificationCenter.default.post(name: Notification.Name(rawValue: "spotifyUserLoggedOut"), object: nil)
    }

    // Handles a play or pause of current stream
    public func playPauseStream() {
        guard let player = self.player else { return }
        
        let isPlaying = !player.playbackState.isPlaying

        print("[SpotifyService]: didTryPlayPauseStream", isPlaying)

        player.setIsPlaying(isPlaying, callback: nil)
        
        streaming = false
    }

    // Handles a stop
    public func stop() {
        player?.setIsPlaying(false, callback: nil)
    }

    // Handles a search for the sent artist
    public func searchTrackForEventArtist(query: String, completion: @escaping () -> Void) -> Void {
        print("[SpotifyService]: Performing search for: ", query)

        guard let session = self.session else { return }

        SPTSearch.perform(withQuery: query,
                          queryType: SPTSearchQueryType.queryTypeArtist,
                          accessToken: session.accessToken, callback: { (error, object) in
                            if let error = error {
                                print("[SpotifyService]: Error when performing search: \(error.localizedDescription)")
                            }

                            // No errors, will try and stream
                            if let list = object as? SPTListPage,
                                let items = list.items,
                                let firstArtist = items.first as? SPTPartialArtist {
                                // Fire away event
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "spotifyDidFindArtistInSearch"), object: nil)

                                print("[SpotifyService]: Setting current track: \(firstArtist.uri.absoluteString)")

                                // Save reference to playable artist
                                self.currentArtistURI = firstArtist.uri.absoluteString
                                
                                // Do whatever needs to be done
                                completion()
                            } else {
                                print("[SpotifyService]: Search resulted in zero")
                            }
        })
    }

    // Executed when wanting to stream the current track
    public func playTrackForArtist() -> Void {
        if let currentURI = currentArtistURI {
            player?.playSpotifyURI(currentURI,
                                   startingWith: 0,
                                   startingWithPosition: 0,
                                   callback: { (error) in
                                    self.streaming = true
                                    
                                    if let error = error {
                                        print("[SpotifyService]: Error when trying to stream track: \(error.localizedDescription)")
                                    }
            })
        }
    }
}
