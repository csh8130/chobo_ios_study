//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import Foundation

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> Void {
  switch action {
  case .saveFavoritePrimeTapped:
    state.favoritePrimes.append(state.count)
  case .removeFavoritePrimeTapped:
    state.favoritePrimes.removeAll(where: { $0 == state.count })
  }
}
