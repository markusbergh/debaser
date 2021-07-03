//
//  Store.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import Combine
import Foundation

protocol StoreProtocol {
    associatedtype Action
    
    func dispatch(action: Action)
}

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

final class Store<State, Action>: ObservableObject {
    
    // MARK: Private
    
    private let reducer: Reducer<State, Action>
    private let middlewares: [Middleware<State, Action>]
    private var cancellables: [AnyCancellable] = []
    private let queue = DispatchQueue(label: "se.ejzi.Debaser.store", qos: .userInitiated)

    @Published private(set) var state: State
    
    init(initialState: State, reducer: @escaping Reducer<State, Action>, middlewares: [Middleware<State, Action>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }
}

extension Store: StoreProtocol {
    
    ///
    /// Dispatches an action (and applies a middleware, if available)
    ///
    /// - Parameter action: The action to dispatch
    ///
    func dispatch(action: Action) {
        queue.sync {
            state = reducer(&state, action)
            
            for middleware in middlewares {
                guard let middleware = middleware(state, action) else {
                    break
                }
                
                middleware
                    .receive(on: RunLoop.main)
                    .sink(receiveValue: dispatch)
                    .store(in: &cancellables)
            }
        }
    }
}

// MARK: Mock store

class MockStore: ObservableObject {
    static let store = Store(
        initialState: AppState(
            list: ListState(),
            settings: SettingsState(),
            onboarding: OnboardingState(),
            spotify: SpotifyState()
        ),
        reducer: appReducer
    )
    
    static func store(with events: [EventViewModel]) -> Store<AppState, AppAction> {
        let listState = ListState(events: events)
        
        let store = Store(
            initialState: AppState(
                list: listState,
                settings: SettingsState(),
                onboarding: OnboardingState(),
                spotify: SpotifyState()
            ),
            reducer: appReducer
        )
        
        return store
    }
}
