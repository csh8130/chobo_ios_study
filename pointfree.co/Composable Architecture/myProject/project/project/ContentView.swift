//
//  ContentView.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store<AppState>
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: self.store)) {
                    Text("Counter demo")
                }
//                NavigationLink(destination: FavoritePrimes(state: self.store.value.favoritePrimesState)) {
//                  Text("Favorite primes")
//                }
            }
            .navigationBarTitle("State management")
        }
    }
}
