//
//  View.swift
//  ReduxDemo
//
//  Created by Dien Bell on 2025/2/13.
//

import SwiftUI

// MARK: - Views
struct CounterView: View {
    @StateObject private var store = CounterStore(
        initialState: CounterState(),
        reducer: appReducer
    )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("当前计数: \(store.state.counter)")
                    .font(.title)
                
                HStack(spacing: 20) {
                    Button(action: { store.dispatch(.decrement) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                    }
                    
                    Button(action: { store.dispatch(.increment) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
                
                Button("重置") {
                    store.dispatch(.reset)
                }
                .buttonStyle(.bordered)
                
                Button("添加到历史记录") {
                    store.dispatch(.addToHistory)
                }
                .buttonStyle(.bordered)
                
                if !store.state.history.isEmpty {
                    HistoryView(history: store.state.history)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("SwiftUI Redux计数器")
        }
    }
}

struct HistoryView: View {
    let history: [Int]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("历史记录")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(history.indices, id: \.self) { index in
                        Text("记录 \(index + 1): \(history[index])")
                            .padding(.vertical, 4)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
