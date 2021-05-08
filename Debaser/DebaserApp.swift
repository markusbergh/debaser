//
//  DebaserApp.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-03-12.
//

import SwiftUI

import DebaserService

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
    @StateObject var carouselState = UIStateModel()
    
    @State private var colorScheme: ColorScheme = .light
    @State private var eventReceived: Event? = nil
    @State private var shouldOpenModal = false
    @State private var eventReceivedId = ""

    private let auth = SPTAuth()
    private let spotifyUserRetrieved = NotificationCenter.default.publisher(for: NSNotification.Name("spotifyUserRetrieved"))
    
    init() {
        configureSpotifyConnection()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    store.dispatch(withAction: .list(.getFavouritesRequest))
                    store.dispatch(withAction: .spotify(.initialize))
                    store.dispatch(withAction: .settings(.getOverrideColorScheme))
                    store.dispatch(withAction: .settings(.getDarkMode))
                    store.dispatch(withAction: .settings(.getHideCancelled))
                    store.dispatch(withAction: .settings(.getShowImages))
                }
                .environmentObject(store)
                .environmentObject(tabViewRouter)
                .environmentObject(carouselState)
                .onReceive(spotifyUserRetrieved) { _ in
                    store.dispatch(withAction: .spotify(.requestLoginComplete))
                }
                .onReceive(store.state.settings.hideCancelled) { _ in
                    // Reset state due to change in settings, regardless of change
                    carouselState.reset()
                }
                .onReceive(store.state.settings.darkMode) { value in
                    switch value {
                    case true: colorScheme = .dark
                    case false: colorScheme = .light
                    }
                }
                .onChange(of: store.state.list.events, perform: { _ in
                    if shouldOpenModal {
                        presentModalViewForEvent()
                        
                        // All done...
                        shouldOpenModal = false
                    }
                })
                .onOpenURL{ url in
                    if auth.canHandle(auth.redirectURL) && url.absoluteString.hasPrefix(auth.redirectURL.absoluteString) {
                        handleSpotifyLoginCallbackURL(url)
                    }
                    
                    if canHandleExtensionEventURL(url: url), !eventReceivedId.isEmpty {
                        if store.state.list.events.isEmpty {
                            // We might have no data yet, but we should still present modal
                            shouldOpenModal = true
                        } else {
                            presentModalViewForEvent()
                        }
                    }
                }
                .sheet(item: $eventReceived) { event in
                    let event = EventViewModel(with: event)
                    
                    DetailView(event: event, canNavigateBack: false)
                        .preferredColorScheme(
                            store.state.settings.systemColorScheme.value ? nil : colorScheme
                        )
                        .environmentObject(store)
                }
                .preferredColorScheme(
                    store.state.settings.systemColorScheme.value ? nil : colorScheme
                )
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
        })
    }
}

// MARK: iMessage Extension + Widget Extension

extension DebaserApp {
    func canHandleExtensionEventURL(url: URL) -> Bool {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        
        guard let queryItems = urlComponents.queryItems else {
            return false
        }
        
        guard !queryItems.isEmpty else {
            return false
        }
        
        // Look for an event id
        for queryItem in queryItems where queryItem.name == "eventId" {
            eventReceivedId = queryItem.value ?? ""
            
            return true
        }
        
        return false
    }
}

// MARK: Modal

extension DebaserApp {
    func presentModalViewForEvent() {
        let matchedEvent = store.state.list.events.first(where: { event in
            event.id == eventReceivedId
        })
        
        eventReceived = matchedEvent
    }
}
