//
//  Counter.swift
//  Counter
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import Foundation


public enum CounterAction {
    case decrTapped
    case incrTapped
}

public func counterReducer(state: inout Int, action: CounterAction) -> Void {
  switch action {
  case .decrTapped:
    state -= 1

  case .incrTapped:
    state += 1
  }
}
