//
//  FavoritePrimes.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

struct FavoritePrimes: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
              Text("\(prime)")
            }
            .onDelete(perform: { indexSet in
              for index in indexSet {
                self.state.favoritePrimes.remove(at: index)
              }
            })
          }
        .navigationBarTitle(Text("Favorite Primes"))
    }
}
