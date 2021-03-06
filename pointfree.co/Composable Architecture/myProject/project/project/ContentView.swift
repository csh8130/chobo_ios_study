//
//  ContentView.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var state: AppState
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritePrimes(state: self.$state.favoritePrimesState)) {
                  Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}
