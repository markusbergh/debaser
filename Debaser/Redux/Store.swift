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
    
    func dispatch(withAction action: Action)
}

typealias Middleware<State, Action> = (State, Action) -> AnyPublisher<Action, Never>?

final class Store<State, Action>: ObservableObject {
    private let reducer: Reducer<State, Action>
    private let middlewares: [Middleware<State, Action>]
    private var cancellables: [AnyCancellable] = []

    @Published private(set) var state: State
    
    init(initialState: State, reducer: @escaping Reducer<State, Action>, middlewares: [Middleware<State, Action>] = []) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }
}

extension Store: StoreProtocol {
    func dispatch(withAction action: Action) {
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

// MARK: Mock store

class MockStore: ObservableObject {
    static let store = Store(
        initialState: AppState(
            list: ListState(),
            settings: SettingsState(),
            onboarding: OnboardingState()
        ),
        reducer: appReducer
    )
}
