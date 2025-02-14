//
//  Store.swift
//  ReduxDemo
//
//  Created by Dien Bell on 2025/2/13.
//

import Combine
import SwiftUI

// MARK: - Actions
enum CounterAction {
    case increment
    case decrement
    case reset
    case addToHistory
}

// MARK: - State
struct CounterState {
    var counter: Int = 0
    var history: [Int] = []
}

// MARK: - Store
@MainActor
class CounterStore: ObservableObject {
    @Published private(set) var state: CounterState
    private let reducer: (CounterState, CounterAction) -> CounterState
    
    init(initialState: CounterState,
         reducer: @escaping (CounterState, CounterAction) -> CounterState) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(_ action: CounterAction) {
        state = reducer(state, action)
    }
}

// MARK: - Reducer
func appReducer(state: CounterState, action: CounterAction) -> CounterState {
    var newState = state
    
    switch action {
    case .increment:
        newState.counter += 1
    case .decrement:
        newState.counter -= 1
    case .reset:
        newState.counter = 0
    case .addToHistory:
        newState.history.append(state.counter)
    }
    
    return newState
}


