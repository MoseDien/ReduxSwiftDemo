//
//  ContentView.swift
//  ReduxDemo
//
//  Created by Dien Bell on 2025/2/13.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            CounterView()
            ArticleView()
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
