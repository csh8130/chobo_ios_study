//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import Foundation

public enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}

public struct PrimeModalState {
  public var count: Int
  public var favoritePrimes: [Int]

  public init(count: Int, favoritePrimes: [Int]) {
    self.count = count
    self.favoritePrimes = favoritePrimes
  }
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> Void {
  switch action {
  case .saveFavoritePrimeTapped:
    state.favoritePrimes.append(state.count)
  case .removeFavoritePrimeTapped:
    state.favoritePrimes.removeAll(where: { $0 == state.count })
  }
}
