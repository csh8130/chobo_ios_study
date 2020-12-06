//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import Foundation
import ComposableArchiteture
import SwiftUI

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> Void {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.remove(at: index)
    }
  }
}

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}

public struct FavoritePrimesView: View {
    @ObservedObject var store: Store<[Int], FavoritePrimesAction>
    
    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(self.store.value, id: \.self) { prime in
                Text("\(prime)")
            }.onDelete { indexSet in
                self.store.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
    }
    
}
