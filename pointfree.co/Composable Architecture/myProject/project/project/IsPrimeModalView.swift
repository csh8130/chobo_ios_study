//
//  IsPrimeModalView.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

struct PrimeAlert: Identifiable {
  let prime: Int
  var id: Int { self.prime }
}

private func isPrime (_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

struct IsPrimeModalView: View {
    @ObservedObject var store: Store<AppState>
    var body: some View {
        VStack {
            if isPrime(self.store.value.count) {
                Text("\(self.store.value.count) is prime 🎉")
            } else {
                Text("\(self.store.value.count) is not prime :(")
            }
            if self.store.value.favoritePrimes.contains(self.store.value.count) {
                Button(action: {
                    self.store.value.favoritePrimes.removeAll(where: { $0 == self.store.value.count })
                    self.store.value.activityFeed.append(.init(type: .removedFavoritePrime(self.store.value.count)))
                    
                }) {
                    Text("Remove from favorite primes")
                }
            } else {
                Button(action: {
                    self.store.value.favoritePrimes.append(self.store.value.count)
                    self.store.value.activityFeed.append(.init(type: .addedFavoritePrime(self.store.value.count)))
                }) {
                    Text("Save to favorite primes")
                }
            }
          
        }
      }
}
