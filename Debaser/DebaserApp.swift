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
            listMiddleware(service: EventService.shared)
        ]
    )
    
    @StateObject var tabViewRouter = TabViewRouter()
    @StateObject var carouselState = CarouselState()
    
    @State private var colorScheme: ColorScheme = .light
    @State private var eventReceived: EventViewModel? = nil
    @State private var eventReceivedId: String?
    @State private var shouldOpenModal = false

    private let spotifyAuth: SPTAuth = {
        let spotifyAuth = SPTAuth()
        spotifyAuth.redirectURL = URL(string: "debaser-spotify-login://callback")
        spotifyAuth.sessionUserDefaultsKey = "spotifyCurrentSession"
        
        return spotifyAuth
    }()
    
    private let spotifyUserRetrieved = NotificationCenter.default.publisher(for: NSNotification.Name("spotifyUserRetrieved"))
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    resetIfNeeded()
                    skipOnbordingIfNeeded()
                }
                .environmentObject(store)
                .environmentObject(tabViewRouter)
                .environmentObject(carouselState)
                .onReceive(spotifyUserRetrieved) { _ in
                    store.dispatch(action: .spotify(.requestLoginComplete))
                }
                .onReceive(store.state.settings.hideCancelled) { _ in
                    // Reset state due to change in settings, regardless of change
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
                    if canHandleEvent(withURL: url), !(eventReceivedId?.isEmpty ?? true) {
                        if store.state.list.events.isEmpty {
                            // We might have no data yet, but we should still show a modal
                            shouldOpenModal = true
                            
                            return
                        }
                        
                        // Otherwise just show modal viwe
                        getEventForModalView()
                    }
                }
                .sheet(item: $eventReceived) { event in
                    presentModalView(with: event)
                }
                .preferredColorScheme(
                    store.state.settings.systemColorScheme.value ? nil : colorScheme
                )
        }
    }
    
    private func resetIfNeeded() {
        guard CommandLine.arguments.contains("-resetUserDefaults") else {
            configureStore()

            return
        }
        
        let defaultsName = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: defaultsName)
    }
    
    private func skipOnbordingIfNeeded() {
        guard CommandLine.arguments.contains("-skipOnboarding") else {
            return
        }
        
        UserDefaults.standard.setValue(false, forKey: "seenOnboarding")
    }
    
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
    private func handleSpotifyLogin(withURL url: URL?, userDefaults: UserDefaults = UserDefaults.standard) {
        spotifyAuth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
            if let error = error {
                print("We have an error: ", error)
                
                // Fire away notification
                let notificationName = Notification.Name(rawValue: SpotifyNotification.AuthError.rawValue)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                // Dispatch
                store.dispatch(action: .spotify(.requestLoginError(.authError)))
                
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
                let notificationName = Notification.Name(rawValue: SpotifyNotification.Error.rawValue)
                NotificationCenter.default.post(name: notificationName, object: nil)
                
                // Dispatch
                store.dispatch(action: .spotify(.requestLoginError(.unknown)))
            }
            
            // Fire away notification
            let notificationName = Notification.Name(rawValue: SpotifyNotification.LoginSuccessful.rawValue)
            NotificationCenter.default.post(name: notificationName, object: nil)
        })
    }
}

// MARK: iMessage + Widget Extension

extension DebaserApp {
    private func canHandleEvent(withURL url: URL) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        guard let queryItems = urlComponents.queryItems, !queryItems.isEmpty else {
            return false
        }
        
        for item in queryItems where item.name == "eventId" {
            eventReceivedId = item.value
            
            return true
        }
        
        return false
    }
}

// MARK: Modal view

extension DebaserApp {
    private func getEventForModalView() {
        let matchedEvent = store.state.list.events.first(where: { event in
            event.id == eventReceivedId
        })
        
        eventReceived = matchedEvent
    }
    
    private func presentModalView(with event: EventViewModel) -> some View {
        let colorScheme = store.state.settings.systemColorScheme.value ? nil : colorScheme

        return DetailView(event: event, canNavigateBack: false)
            .preferredColorScheme(colorScheme)
            .environmentObject(store)
    }
}
