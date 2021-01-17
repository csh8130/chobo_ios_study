import XCTest
@testable import PrimeModal

class PrimeModalTests: XCTestCase {
  func testExample() {
    var state = (count: 2, favoritePrimes: [3, 5])
    primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)
    XCTAssertEqual(state.count, 2)
    XCTAssertEqual(state.favoritePrimes, [3, 5, 2])
  }
}
