//
//  Store.swift
//  Debaser
//
//  Created by Markus Bergh on 2021-04-15.
//

import Combine

protocol StoreProtocol {
    associatedtype Action
    
    func dispatch(_ action: Action)
}

final class Store<State, Action>: ObservableObject {
    private let reducer: Reducer<State, Action>
    private var cancellables: [AnyCancellable]?

    @Published private(set) var state: State
    
    init(initialState: State, reducer: @escaping Reducer<State, Action>) {
        self.state = initialState
        self.reducer = reducer
    }
}

extension Store: StoreProtocol {
    func dispatch(_ action: Action) {
        reducer(&state, action)
    }
}
