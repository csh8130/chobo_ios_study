//
//  AppState.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

final class Store<Value>: ObservableObject {
  @Published var value: Value

  init(initialValue: Value) {
    self.value = initialValue
  }
}

struct AppState {
    var count: Int = 0
    var favoritePrimes: [Int] = []
    var activityFeed: [Activity] = []
    var loggedInUser: User?
    
    struct User {
      let id: Int
      let name: String
      let bio: String
    }
}

//extension AppState {
//  func addFavoritePrime() {
//    self.favoritePrimes.append(self.count)
//    self.activityFeed.append(Activity(type: .addedFavoritePrime(self.count)))
//  }
//
//  func removeFavoritePrime(_ prime: Int) {
//    self.favoritePrimes.removeAll(where: { $0 == prime })
//    self.activityFeed.append(Activity(type: .removedFavoritePrime(prime)))
//  }
//
//  func removeFavoritePrime() {
//    self.removeFavoritePrime(self.count)
//  }
//
//  func removeFavoritePrimes(at indexSet: IndexSet) {
//    for index in indexSet {
//      self.removeFavoritePrime(self.favoritePrimes[index])
//    }
//  }
//}

