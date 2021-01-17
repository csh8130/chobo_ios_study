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

마지막으로 테스트 이름을 알맞게 변경합니다. `func  testSaveFavoritePrimesTapped() `



이제 즐겨찾기 삭제를 테스트 해보겠습니다. 방금 테스트를 복사해서 일부만 수정합니다.

```swift
    func testRemoveFavoritePrimeTapped() {
      var state = (count: 3, favoritePrimes: [3, 5])

      let effects = primeModalReducer(state: &state, action: .removeFavoritePrimeTapped)

      let (count, favoritePrimes) = state
      XCTAssertEqual(count, 3)
      XCTAssertEqual(favoritePrimes, [5])
      XCTAssert(effects.isEmpty)
    }
```



### Testing favorite primes

primeModal 화면보다 복잡한 화면으로 테스트를 시도합니다.

마찬가지로 우선 테스트를 작성하기 전 `favoritePrimesReducer`의 무엇을 테스트할지 생각합니다. 

`state`는 단순히 Int 배열입니다. `action`은 4가지가 있습니다.



우선 가장 간단한 action은 즐겨찾기된 소수를 제거하는 action입니다. `.deleteFavoritePrimes`

이를 테스트 하려면 삭제할 state와 index가 필요합니다.

```swift
var state = [2, 3, 5, 7]

favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))
```

이렇게하면 state에서 5가 제거되길 기대합니다. 테스트에 맞는 이름을 추가하고 조건에 맞는 assert를 작성합니다.

```swift
func testDeleteFavoritePrimes() {
var state = [2, 3, 5, 7]

let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))

XCTAssertEqual(state, [2, 3, 7])
XCTAssert(effects.isEmpty)
}
```



다음으로 저장 버튼 동작의 테스트를 작성하겠습니다. 이 action은 수행후 state가 변경되지 않습니다. 디스크에 저장하기만 하면 됩니다. 

```swift
func testSaveButtonTapped() {
  var state = [2, 3, 5, 7]

  let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)

  XCTAssertEqual(state, [2, 3, 5, 7])
  XCTAssert(effects.isEmpty) // ?
}
```

effects에 대한 assert를 어떻게 작성해야 합니까? 이번에는 비어있지 않으며 하나의 값이 있습니다.

```swift
XCTAssertEqual(effects.count, 1)
```

갯수만 검사하는것은 잘못된 방법입니다. effect가 어떤 일을 일으키는지 관심이 없기 때문입니다.

불행히도 지금은 이것이 최선입니다. 나중에 이 부분을 다시 살펴보겠습니다.



다음으로 저장된 즐겨찾기 목록을 불러오는 버튼의 테스트를 작성합니다.

```swift
func testLoadButtonTapped() {
  var state = [2, 3, 5, 7]

  let effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)

  XCTAssertEqual(state, [2, 3, 5, 7])
  XCTAssertEqual(effects.count, 1)
}
```

`.loadButtonTapped`이후 불리는 `.loadedFavoritePrimes` 까지 포함해서 전체 흐름을 테스트 하는것이 더 낫습니다.

```swift
...
var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)

  XCTAssertEqual(state, [2, 3, 5, 7])
  XCTAssertEqual(effects.count, 1)

  effects = favoritePrimesReducer(state: &state, action: .loadedFavoritePrimes([2, 31]))

  XCTAssertEqual(state, [2, 31])
  XCTAssert(effects.isEmpty)
}
```

`effects`를 변경가능하게 `var` 로 바꾸고, 두번째 action의 effects는 비어있는 배열을 반환받습니다.

그리고 전체 흐름을 테스트 함을 표현하기위해 테스트 이름을 바꿉니다.

`testLoadFavoritePrimesFlow`

그러나 이 테스트도 반환받은 effect의 갯수만 검사하기 때문에 잘못 작성되어 보입니다.

지금 이 문제를 해결할 수 없으므로 이 방법으로 계속 진행합니다.



### Testing the counter

마지막으로 남은 화면은 숫자 선택 화면으로 숫자 변경 버튼 이외에 "nth prime"을 요청 할 수 있습니다.

먼저 `couterViewReducer`가 취하는 `state`와 `action`을 기억해 봅니다.

```swift
var state = CounterViewState(
  alertNthPrime: nil,
  count: 2,
  favoritePrimes: [3, 5],
  isNthPrimeButtonDisabled: false
)
```

먼저 구조체 형태의 state를 초기화합니다.

`CounterViewAction`은 두가지 케이스가 존재합니다.

`PrimeModalAction`과 `CounterAction`

`PrimeModalAction`은 앞에서 테스트 했으므로 후자에 집중하고 싶습니다.



`CounterAction`는 또 다수의 케이스가 존재합니다.

우선 증가 버튼을 누를때 숫자가 1씩 증가하는 action을 테스트합니다.

```swift
counterViewReducer(&state, .counter(.incrTapped))

XCTAssertEqual(
  state,
  CounterViewState(
    alertNthPrime: nil,
    count: 3,
    favoritePrimes: [3, 5],
    isNthPrimeButtonDisabled: false
  )
)
```

하지만 즉시 컴파일 애러가 발생합니다.

🛑 Global function ‘XCTAssertEqual(*:*:_:file:line:)’ requires that ‘CounterViewState’ conform to ‘Equatable’

```swift
public struct CounterViewState: Equatable {
```

CounterViewState가 Equatable을 준수하도록 즉시 고칩니다.

다음으로 PrimeAlert에서 마찬가지 오류가 발생합니다.

```swift
public struct PrimeAlert: Identifiable, Equatable {
```

테스트를 통과합니다. 테스트 이름을 알맞게 변경합니다. `testIncrButtonTapped`

이 테스트를 복사해서 감소 action에 대해서도 동일하게 테스트합니다.



남아있는 작성해야할 테스트는 "nth prime"에 대한 테스트입니다.

우리는 이미 effect가 있는 action을 테스트하기에 얼마나 부족한 상황인지 알아봤었습니다.

그래도 최선의 방법으로 테스트를 작성합니다.

```swift
func testNthPrimeButtonFlow() {
  var state = CounterViewState(
    alertNthPrime: nil,
    count: 2,
    favoritePrimes: [3, 5],
    isNthPrimeButtonDisabled: false
  )
 var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
 }
```

이 테스트 flow에서 처음 발생하는것은 버튼을 탭 하는 것입니다.

이 동작을 수행하면 api요청은 진행 중이고 단일 effect가 발생하기때문에 버튼이 비활성화 상태가 될것입니다. (아직 effect에 대해서 코드에서는 알 수 없습니다)

```swift
XCTAssertEqual(
  state,
  CounterViewState(
    alertNthPrime: nil,
    count: 2,
    favoritePrimes: [3, 5],
    isNthPrimeButtonDisabled: true
  )
)
XCTAssertEqual(effects.count, 1)
```

반환된 effects에 대해 알 수 없지만 api response가 돌아오면 그 결과가 store로 되돌아 오는것을 알고 있습니다.

지금은 이것을 수동으로 reducer를 호출해서 발생시킵니다. `nthPrimeResponse`

```swift
effects = counterViewReducer(&state, .counter(.nthPrimeResponse(3)))

XCTAssertEqual(
  state,
  CounterViewState(
    alertNthPrime: PrimeAlert(prime: 3),
    count: 2,
    favoritePrimes: [3, 5],
    isNthPrimeButtonDisabled: false
  )
)
XCTAssert(effects.isEmpty)
```

state의 두 부분이 바뀌게됩니다.

PrimeAlert은 3을 나타냅니다. (2번째 prime이 3이므로)

버튼의 disable 상태가 enable로 바뀝니다.



test flow에 아직 한단계가 더 남아있습니다. 사용자가 Alert을 닫을 수 있습니다.

```swift
effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))
XCTAssertEqual(
  state,
  CounterViewState(
    alertNthPrime: nil,
    count: 2,
    favoritePrimes: [3, 5],
    isNthPrimeButtonDisabled: false
  )
)
XCTAssert(effects.isEmpty)
```

effects를 전혀 테스트하지 않았지만 이게 얼마나 멋진지 생각 해 볼 가치가 있습니다.

1. 사용자가 버튼을 누르고, 2. 응답을 받고, 3. 경고를 닫습니다.

 그리고 버튼의 활성화 여부와 경고 해제여부 등 각 작업후 상태를 assert로 체크합니다.

이는 꽤 광범위한 체크이지만 간단하게 수행됩니다.



또한 이러한 스타일의 아키텍처 및 테스트는 `test-driven development`과 잘 어울립니다. 

 이 스타일의 테스트에서는 로직이없는 리듀서의 상태 구조체, 액션 열거 형 및 시그니처를 설정하고 빈 효과 배열을 반환 하도록 먼저 만듭니다.

그런다음 테스트의 동작을 먼저 구현한 다음 테스트 구현을 기반으로 reducer를 구현합니다.



### Unhappy paths and integration tests

Counter View는 꽤 잘 테스트되었습니다. 여기서 멈출 수도 있지만 테스트를 다음단계로 끌어올릴 수 있습니다.

1. 우리는 n번째 Prime 호출이 항상 성공하는 경우만 테스트하고 있었습니다. 실패하는 경우도 생각해야 합니다.

2.  CounterView는 `PrimeModal`의 기능을 포함하고 있으며 이 기능은 PrimeModal test에서 이미 다뤘지만 `PrimeModal`기능이 Counter View 를 망치는 케이스는 없는지 테스트 해보고 싶습니다. 이는 `통합 테스트`를 작성해서 확인 할 수 있습니다.

우선 기존의 테스트는 행복한(?) 상황을 가정했으므로 테스트 이름을 변경합니다.

```swift
func testNthPrimeButtonHappyFlow() {
```

이제 불행한 케이스를 테스트하기위해 행복한 케이스를 복사해와서 변경을 시도합니다.

```swift
func testNthPrimeButtonUnhappyFlow() {
        var state = CounterViewState(
            alertNthPrime: nil,
            count: 2,
            favoritePrimes: [3, 5],
            isNthPrimeButtonDisabled: false
        )
        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: true
            )
        )
        XCTAssertEqual(effects.count, 1)
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(nil)))
        XCTAssertEqual(
            state,
            CounterViewState(
                alertNthPrime: nil,
                count: 2,
                favoritePrimes: [3, 5],
                isNthPrimeButtonDisabled: false
            )
        )
        XCTAssert(effects.isEmpty)
    }
```

테스트는 성공합니다.



이제 counter와 primeModal이 잘 통합되었는지 통합 테스트를 작성합니다.

```swift
func testPrimeModal() {
  var state = CounterViewState(
    alertNthPrime: nil,
    count: 2,
    favoritePrimes: [3, 5],
    isNthPrimeButtonDisabled: false
  )

  var effects = counterViewReducer(&state, .primeModal(.saveFavoritePrimeTapped))

  XCTAssertEqual(
    state,
    CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5, 2],
      isNthPrimeButtonDisabled: false
    )
  )
  XCTAssert(effects.isEmpty)

  effects = counterViewReducer(&state, .primeModal(.removeFavoritePrimeTapped))

  XCTAssertEqual(
    state,
    CounterViewState(
      alertNthPrime: nil,
      count: 2,
      favoritePrimes: [3, 5],
      isNthPrimeButtonDisabled: false
    )
  )
  XCTAssert(effects.isEmpty)
}
```

여기서 PrimeModal이 Counter에 포함되었을때 Counter의 어떤 state를 망가뜨리지 않는지 검사합니다.

이것은 기본적으로 reducer에 대한 통합 테스트 입니다.

여러 계층의 기능을 테스트하고,

서로 상호작용하는것을 테스트해서 함께 잘 작동하는것을 알았습니다.

이것은 꽤 큰 작업입니다! 지금은 장난감 앱이지만 대규모 앱에서는 여러개의 재사용 가능한 구성요소가 함께 연결되어도 계속 제대로 작동되는지 테스트 할 수 있습니다.

이미 강력한 테스트를 작성했지만 아직 Effect 에 대한 테스트를 작성하지 않았습니다.



### 다음시간 : Effect 테스트

 이번장에서는 순수함수인 reducer를 테스트하는게 얼마나 쉬운지 확인했습니다.

반면에 effect의 테스트는 작성하지 못했습니다. 어떤 Effect가 생성되었다는것은 확인 했지만 특정 Effect가 생성되었다는것을 식별할 수 없었습니다.

 우리는 임시적으로 어떤 Effect가 action을 수행할 것을 알고 수동으로 action을 호출했습니다. 그러나 수동으로 이것을 작동시키는것은 위험합니다. 우리가 수동으로 이것을 추가하는것을 빠뜨린다면 이 부분이 아예 테스트되지 않을것입니다. 또한 수동으로 잘못된 테스트를 작성한다면 실제로 일어나지 않을 일을 테스트 하고 있을 것 입니다.



 아마도 우리는 effect를 실행하여 테스트 해 볼 수 있겠지만 effect는 좀처럼 테스트 가능하지 않다. 무슨말인가 하면 예를 들어 아주 간단한 effect인 "저장" 혹은 "불러오기"의 경우 디스크 어딘가에 JSON을 작성하고 올바르게 작성되었는지 알려면 디스크 내부의 위치를 알아야 합니다. 테스트 종료 후 디스크 내부를 정리하려면 역시 위치가 필요합니다. 파일 시스템과 상호작용을 해야하지만 일부 환경에서는 문제가 됩니다. 파일 권한이나, 디스크 공간 등등...



 복잡한 effect는 훨씬 더 상황이 복잡해집니다. "nth prime"을 찾는 API의 경우 서버와 비동기 통신을 수행합니다. 즉 네트워크 시스템과 상호작용 해야하고 서버가 예상대로 실행된다고 가정해야합니다. 거기다가 응답을 기다려야 해서 Test속도가 현저히 느려집니다. 

이를 위해 때때로 CI를 깨뜨릴 수 있는 느리고 불안정한 테스트를 도입합니다.(?)



그렇다면 효과적으로 아키텍처를 어떻게 테스트할까요? 특정 데이터가 effect에 전달되고 특정 결과가 리듀서로 다시 전달되도록 하기위해 effect를 어떻게 제어해야 할까요?



"Environment"라는것을 도입해서 다음시간에 이를 해결 해 보겠습니다.
