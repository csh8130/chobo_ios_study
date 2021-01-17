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

그리고 즐겨찾기 액션을 수행한 후 예상 값과 같은지 비교합니다

```swift
XCTAssertEqual(state, (2, [3, 5, 2]))
```

 🛑 Global function ‘XCTAssertEqual(*:*:_:file:line:)’ requires that ‘(Int, [Int])’ conform to ‘Equatable’

하지만 Equatable이 아니어서 코드가 실행되지 않습니다.
