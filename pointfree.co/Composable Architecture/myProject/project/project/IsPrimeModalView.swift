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
    @ObservedObject var state: AppState
    var body: some View {
        VStack {
            if isPrime(self.state.count) {
              Text("\(self.state.count) is prime 🎉")
            } else {
              Text("\(self.state.count) is not prime :(")
            }
          Button(action: {}) {
            if self.state.favoritePrimes.contains(self.state.count) {
                Button(action: { self.state.favoritePrimes.removeAll(where: { $0 == self.state.count }) }) {
                Text("Remove from favorite primes")
              }
            } else {
                Button(action: { self.state.favoritePrimes.append(self.state.count) }) {
                Text("Save to favorite primes")
              }
            }
          }
        }
      }
}
