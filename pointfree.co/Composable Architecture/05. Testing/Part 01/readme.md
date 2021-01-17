### Testing the prime modal

 테스트하기 가장 쉬운 부분은 reducer입니다. 그 이유는 동작이 현재 상태에서 다음상태로 이동하는 한 단계에 불과하고 순수 함수이기 때문입니다. 테스트는 현재 상태와 사용자 액션을 입력받아 결과 상태를 검출 할 수있도록 쉬워야 합니다.

 가장 간단한 화면인 PrimeModal 화면 부터 시작합니다. 현재 카운트 값이 소수인지 여부를 보여주는 화면이며 소수 인 경우 즐겨찾기에 추가하거나 제거 할 수 있습니다.

 모듈을 만들었을 때 자동으로 test파일이 생성되어 있었습니다.

```swift
//
//  PrimeModalTests.swift
//  PrimeModalTests
//
// …
```

모든 내용을 지우고 다음 내용만 남깁니다.

```swift
import XCTest
@testable import PrimeModal

class PrimeModalTests: XCTestCase {
  func testExample() {
  }
}
```

Assert 동작을 확인하기 위해 코드를 추가합니다.

```swift
XCTAssertTrue(false)
```

테스트는 실패하게됩니다. 

    ❌ XCTAssertTrue failed

 그리고 빌드를 마치는데 오래 걸렸고, 테스트를 수행하는것도 생각보다 오래 걸렸습니다. 이는 host application이 설정 되어있어서 입니다. 시뮬레이터의 애플리케이션을 빌드하고 거기서 테스트가 수행되기 때문입니다.

 host application을 none으로 바꿔서 이를 해결할 수 있습니다.

추가 설명 :  [XCTest 소요시간 단축하기](https://soojin.ro/blog/application-library-test)

이제 첫 테스트를 어떻게 작성할까요? primeModal reducer의 signiture를 먼저 살펴봅니다.

```swift
primeModalReducer(state: &<#PrimeModalState#>, action: <#PrimeModalAction#>)
```

reducer에 전달하기 위한 state와 action이 필요합니다. action은 두가지 케이스가 있으며 두가지 모드 테스트 하고 싶습니다. (즐겨찾기 추가, 즐겨찾기 제거)

현재 선택된 숫자는 2, 즐겨찾기에 추가된 숫자는 3, 5인 상태를 생성합니다.

```swift
var state = (count: 2, favoritePrimes: [3, 5])
```

그리고 즐겨찾기 버튼을 탭 한것처럼 시뮬레이션 할 수 있습니다.

```swift
primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)
```

액션을 수행한 후 예상 값과 같은지 비교합니다

```swift
XCTAssertEqual(state, (2, [3, 5, 2]))
```

 🛑 Global function ‘XCTAssertEqual(*:*:_:file:line:)’ requires that ‘(Int, [Int])’ conform to ‘Equatable’

튜플이`Equatable`를 만족하지 못해서 코드가 실행되지 않습니다.

 이전 파트에서 튜플로 이루어진 state를 사용하는 reducer를 만들면서 단점이 있다고 했었는데 그 중 하나가 이것입니다.



해결법 중 한가지는 튜플의 내용물을 각각 비교하는 것 입니다.

```swift
XCTAssertEqual(state.count, 2)
XCTAssertEqual(state.favoritePrimes, [3, 5, 2])
```

컴파일이 잘 되고 테스트는 통과됩니다.



 그러나 이 방법은 테스트를 놓치고 통과시킬 수도 있습니다. 만약 state에 새로운 필드가 추가되고 그 필드가 tap action에 의해 변경되었다면 지금 assert문으로는 그 작업을 완전히 놓치게됩니다.

 이상적으로 생각할 때 state에 새로운 필드가 추가된경우 컴파일 애러가 일어나게 만들어야 놓치지 않습니다.



이를 위해 튜플에 저장되는 필드를 명시적으로 다시 할당하고 분해하는 방법을 사용합니다.

```swift
func testExample() {
  var state = (count: 2, favoritePrimes: [3, 5])

  primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)

  let (count, favoritePrimes) = state
  XCTAssertEqual(count, 2)
  XCTAssertEqual(favoritePrimes, [3, 5, 2])
}
```

이제 state가 변경되면 컴파일이 실패하고 테스트를 다시 작성해야 합니다.



 혹은 다른방법으로`XCTAssertEqual`에서 튜플이 동작되도록 변경하거나, `PrimeModalState`가 `Equatable`를 만족하도록 바꿀 수 있을 것입니다. 하지만 튜플을 이용하는 방법도 충분히 가볍습니다.



테스트는 정상적으로 동작했지만 경고가 발생했습니다.

⚠️ Result of call to ‘primeModalReducer(state:action:)’ is unused

`primeModalReducer`가 반환하는 Effect를 사용하지 않았기 때문입니다. 운 좋게도 이 reducer는 실제로 어떤 값도 반환하지 않으므로 이 배열은 비어있는것으로 간주합니다.

```swift
let effects = primeModalReducer(state: &state, action: .saveFavoritePrimeTapped)

...

XCTAssert(effects.isEmpty)
```

 불필요한 코드처럼 보이지만 reducer가 effect를 사용하도록 변경되면 즉시 테스트 실패가 발생하여 분명히 알 수 있습니다. 따라서 reducer가 effects를 반환하지 않더라도 이러한 코드를 넣는것이 좋습니다.


