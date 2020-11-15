//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import Foundation

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
