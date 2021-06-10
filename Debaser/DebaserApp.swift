//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

@main
struct DebaserApp: App {
    
    // MARK: Store
    
    @StateObject var store: Store<AppState, AppAction> = Store(
        initialState: AppState(
            list: ListState(),
            settings: SettingsState(),
            onboarding: OnboardingState(),
            spotify: SpotifyState()
        ),
        reducer: appReducer,
        middlewares: [
            listMiddleware(),
            spotifyMiddleware()
        ]
    )
    
    @StateObject var tabViewRouter = TabViewRouter()
    @StateObject var carouselState = CarouselState()
    
    @State private var colorScheme: ColorScheme = .light
    @State private var eventReceivedFromURL: EventViewModel? = nil
    @State private var eventIdReceivedFromURL: String?
    @State private var shouldOpenModal = false

    private let spotifyAuth: SPTAuth = {
        let spotifyAuth = SPTAuth()
        spotifyAuth.redirectURL = URL(string: "debaser-spotify-login://callback")
        spotifyAuth.sessionUserDefaultsKey = "spotifyCurrentSession"
        
        return spotifyAuth
    }()
    
    private let spotifyUserRetrieved = NotificationCenter.default.publisher(for: NSNotification.Name("spotifyUserRetrieved"))
    
    private var preferredColorScheme: ColorScheme? {
        store.state.settings.systemColorScheme.value ? nil : colorScheme
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    configure()
                }
                .onReceive(spotifyUserRetrieved) { _ in
                    store.dispatch(action: .spotify(.requestLoginComplete))
                }
                .onReceive(store.state.settings.hideCancelled) { _ in
                    carouselState.reset()
                }
                .onReceive(store.state.settings.darkMode) { isOn in
                    // Set globals for color scheme
                    switch isOn {
                    case true: colorScheme = .dark
                    case false: colorScheme = .light
                    }
                }
                .onChange(of: store.state.list.events, perform: { _ in
                    // Should open modal from previous link
                    if shouldOpenModal {
                        getEventForModalView()
                        
                        // All done...
                        shouldOpenModal = false
                    }
                })
                .onOpenURL{ url in
                    /// URL might be Spotify related
                    if spotifyAuth.canHandle(spotifyAuth.redirectURL) &&
                        url.absoluteString.hasPrefix(spotifyAuth.redirectURL.absoluteString) {
                        handleSpotifyLogin(withURL: url)
                    }
                    
                    /// URL might be an extension
                    if canHandleEvent(withURL: url) {
                        if store.state.list.events.isEmpty {
                            // We might have no data yet, but we should still show a modal
                            shouldOpenModal = true
                            
                            return
                        }
                        
                        // Otherwise just show modal viwe
                        getEventForModalView()
                    }
                }
                .sheet(item: $eventReceivedFromURL) { event in
                    presentModalView(with: event)
                }
                .environmentObject(store)
                .environmentObject(tabViewRouter)
                .environmentObject(carouselState)
                .preferredColorScheme(preferredColorScheme)
        }
    }
}

// MARK: App launch lifecycle

extension DebaserApp {
    
    /// Initial configuration for app
    private func configure() {
        resetIfNeeded()
        skipOnbordingIfNeeded()
    }
    
    /// Reset user defaults when running tests
    private func resetIfNeeded() {
        guard CommandLine.arguments.contains("-resetUserDefaults") else {
            configureStore()

            return
        }
        
        let defaultsName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    }
    
    /// Skip onboarding when running tests
    private func skipOnbordingIfNeeded() {
        guard CommandLine.arguments.contains("-skipOnboarding") else {
            return
        }
        
        UserDefaults.standard.setValue(false, forKey: "seenOnboarding")
    }
    
    /// Set state for store
    private func configureStore() {
        store.dispatch(action: .list(.getFavouritesRequest))
        store.dispatch(action: .spotify(.initialize))
        store.dispatch(action: .settings(.getOverrideColorScheme))
        store.dispatch(action: .settings(.getDarkMode))
        store.dispatch(action: .settings(.getHideCancelled))
        store.dispatch(action: .settings(.getShowImages))
        store.dispatch(action: .onboarding(.getOnboarding))
    }
    
}

// MARK: Spotify

extension DebaserApp {
    
    ///
    /// Tries to handle a Spotify login action
    ///
    /// - parameters:
    ///     - url: Received authentication url
    ///     - userDefaults: User defaults to store session in
    ///
    private func handleSpotifyLogin(withURL url: URL?, userDefaults: UserDefaults = UserDefaults.standard) {
        spotifyAuth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
            if let error = error {
                print("We have an error: ", error)
                
                // Fire away notification
                let notificationName = Notification.Name(rawValue: SpotifyNotification.authError.rawValue)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                // Dispatch
                store.dispatch(action: .spotify(.requestLoginError(.auth)))
                
                return
            }
            
            // No sessions means goodbye
            guard let session = session else { return }
            
            do {
                // Save data
                let sessionData = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
                
                userDefaults.set(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
            } catch {
                print("Error while reading session data")
                
                // Fire away notification
                let notificationName = Notification.Name(rawValue: SpotifyNotification.error.rawValue)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                // Dispatch
                store.dispatch(action: .spotify(.requestLoginError(.unknown)))
            }
            
            // Fire away notification
            let notificationName = Notification.Name(rawValue: SpotifyNotification.loginSuccessful.rawValue)
            NotificationCenter.default.post(name: notificationName, object: nil)
        })
    }
}

// MARK: iMessage + Widget Extension

extension DebaserApp {
    
    ///
    /// Checks if extension url can be handled
    ///
    /// - parameter url: Received extension url
    /// - returns: A boolean
    ///
    private func canHandleEvent(withURL url: URL) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        guard let queryItems = urlComponents.queryItems, !queryItems.isEmpty else {
            return false
        }
        
        for item in queryItems where item.name == "eventId" {
            eventIdReceivedFromURL = item.value
            
            return true
        }
        
        return false
    }
    
}

// MARK: Modal view

extension DebaserApp {
    
    /// Match the received event id with an event
    private func getEventForModalView() {
        guard let eventIdReceivedFromURL = eventIdReceivedFromURL else {
            return
        }
        
        let matchedEvent = store.state.list.events.first(where: { event in
            event.id == eventIdReceivedFromURL
        })
        
        eventReceivedFromURL = matchedEvent
    }
    
    ///
    /// Presents a modal view with the event
    ///
    /// - parameter event: The event to present
    /// - returns: A `DetailView` to present modally
    ///
    private func presentModalView(with event: EventViewModel) -> some View {
        let colorScheme = store.state.settings.systemColorScheme.value ? nil : colorScheme

        return DetailView(event: event, canNavigateBack: false)
            .preferredColorScheme(colorScheme)
            .environmentObject(store)
    }
    
}
