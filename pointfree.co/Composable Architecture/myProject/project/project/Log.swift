//
//  Log.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

struct Activity {
  let type: ActivityType

  enum ActivityType {
    case addedFavoritePrime(Int)
    case removedFavoritePrime(Int)
  }
}
