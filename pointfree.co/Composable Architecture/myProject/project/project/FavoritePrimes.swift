//
//  FavoritePrimes.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

struct FavoritePrimesState {
    var favoritePrimes: [Int]
    var activityFeed: [Activity]
}

extension AppState {
  var favoritePrimesState: FavoritePrimesState {
    get {
      FavoritePrimesState(
        favoritePrimes: self.favoritePrimes,
        activityFeed: self.activityFeed
      )
    }
    set {
      self.favoritePrimes = newValue.favoritePrimes
      self.activityFeed = newValue.activityFeed
    }
  }
}

struct FavoritePrimes: View {
    @Binding var state: FavoritePrimesState

    var body: some View {
        List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
              Text("\(prime)")
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let prime = self.state.favoritePrimes[index]
                    self.state.favoritePrimes.remove(at: index)
                    self.state.activityFeed.append(Activity(type: .removedFavoritePrime(prime)))
                 }
            })
          }
        .navigationBarTitle(Text("Favorite Primes"))
    }
}
