//
//  CounterTests.swift
//  CounterTests
//
//  Copyright © 2019 Point-Free. All rights reserved.
//

import XCTest
@testable import Counter

class CounterTests: XCTestCase {

    func testing() {
        var state = CounterViewState(
            alertNthPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isNthPrimeButtonDisabled: false
        )
        
        let effects = counterViewReducer(&state, .counter(.incrTapped))
        
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 3,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }

}
