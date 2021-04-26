//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//


import SwiftUI

@main
struct DebaserApp: App {
    @StateObject var store: Store<AppState, AppAction> = Store(
        initialState: AppState(
            list: ListState(),
            settings: SettingsState(),
            onboarding: OnboardingState(),
            spotify: SpotifyState()
        ),
        reducer: appReducer,
        middlewares: [
            listMiddleware(service: EventService())
        ]
    )
    
    @StateObject var tabViewRouter = TabViewRouter()
    @State private var isDarkMode: Bool = false
    
    private let auth = SPTAuth()
    private let userAuthenticatedWithSpotify = NotificationCenter.default.publisher(for: NSNotification.Name("spotifyUserAuthenticated"))
    
    init() {
        configureSpotifyConnection()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(store.state.settings.darkMode) { value in
                    isDarkMode = value
                }
                .onAppear {
                    store.dispatch(withAction: .spotify(.initialize))
                    store.dispatch(withAction: .settings(.getDarkMode))
                    store.dispatch(withAction: .settings(.getHideCancelled))
                    store.dispatch(withAction: .settings(.getShowImages))
                }
                .environmentObject(store)
                .environmentObject(tabViewRouter)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .onReceive(userAuthenticatedWithSpotify) { _ in
                    store.dispatch(withAction: .spotify(.requestLoginComplete))
                }
                .onOpenURL{ url in
                    if auth.canHandle(auth.redirectURL) && url.absoluteString.hasPrefix(auth.redirectURL.absoluteString) {
                        handleSpotifyLoginCallbackURL(url)
                    }
                }
        }
    }
}

// MARK: Spotify

private extension DebaserApp {
    func configureSpotifyConnection() {
        // Set authentication for Spotify
        auth.redirectURL = URL(string: "debaser-spotify-login://callback")
        auth.sessionUserDefaultsKey = "current session"
    }
    
    func handleSpotifyLoginCallbackURL(_ url: URL?) {
        auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
            if let error = error {
                print("We have en error:", error)
                
                // Fire away notification
                let notificationName = Notification.Name(rawValue: SpotifyNotification.AuthError.rawValue)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                // Dispatch
                store.dispatch(withAction: .spotify(.requestLoginError(.authError)))
                
                return
            }
            
            // No sessions means goodbye
            guard let session = session else { return }
            
            // Session data is saved into user defaults, then notification is posted
            let userDefaults = UserDefaults.standard
            
            do {
                // Save data
                let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
                
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
            } catch {
                print("Error while reading session data")
                
                // Fire away notification
                let notificationName = Notification.Name(rawValue: SpotifyNotification.Error.rawValue)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                // Dispatch
                store.dispatch(withAction: .spotify(.requestLoginError(.unknown)))
            }
            
            // Fire away notification
            let notificationName = Notification.Name(rawValue: SpotifyNotification.LoginSuccessful.rawValue)
            NotificationCenter.default.post(name: notificationName, object: nil)
            
            // Dispatch
            store.dispatch(withAction: .spotify(.requestLoginComplete))
        })
    }
}
