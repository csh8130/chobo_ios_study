# Composable State Management: Reducers

`BindableObject` 대신 `ObservableObject`와 `@Published`를 사용해서 상용구를 많이 줄이게되었다.

하지만 문제가 남아있다.

- `Combine` 프레임워크에 너무 종속된 코드이다. Linux측 Server Swift에서 모델을 공유할 수 없게된다.

- 모든 속성에 `@Published`를 붙여야된다. 잊어버리고 붙이지않으면 값 변경이 있을 때 UI업데이트가 안된다.

- 여전히 상태라는 의미에 알맞는 `struct`가 아닌 `class`로 만들어야한다.

### 글로벌 상태를 모델링하는 더 나은 방법

AppState가 class로 된것을 걷어내기 위해 struct로 변환한 다음 `ObservableObject` 주위에 매우 얇은 래퍼로 감싸겠습니다.

상태를 구조체로 바꾸는것은 간단합니다.

```swift
struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var activityFeed: [Activity] = []
  var loggedInUser: User? = nil

  struct Activity {
    let type: ActivityType
    let timestamp = Date()

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}
```

ObservableObject와 @Published 없이 동일하게 동작하도록 struct를 class로 래핑해야합니다.

그것을 Store라고 부르겠습니다.

```swift
final class Store: ObservableObject {
  @Published var value: AppState

  init(initialValue: AppState) {
    self.value = value
  }
}
```

컴파일러에서 오류가 나고있지만 그 전에 너무 AppState에 종속적인 코드입니다. AppState인 것을 몰라도 되도록 제네릭을 적용합니다.

```swift
final class Store<Value>: ObservableObject {
  @Published var value: Value

  init(initialValue: Value) {
    self.value = initialValue
  }
}
```

이제 깨진 코드를 고쳐나갑니다.

```swift
@ObservedObject var state: AppState
---
self.state
```

이것을

```swift
@ObservedObject var store: Store<AppState>
---
self.store.value
```

모두 이것으로 바꿉니다.



### Functional state management

Combine, SwiftUI 프레임워크에서 상태관리 코드를 분리하고 struct로 변환했다. state에 값을 쉽게 추가할 수 있게 되었다. (다른 작업이 필요없다)

조금 더 복잡한 문제를 해결 해 보겠다. 상태 값을 변경하는 코드를 일관되게 관리해야 한다.

현재 코드의 문제는 사용자 액션을 잘못 정의했다는 점이다. 뷰에서 직접 상태 변화를 일으키는 대신 뷰가 할 행동을 enum으로 정의하겠습니다.

```swift
enum CounterAction {
  case decrTapped
  case incrTapped
}
```

이제 현재 상태에서 액션을 수행하고 새로운 상태를 반환하는 함수를 만들 수 있습니다.

```swift
func counterReducer(state: AppState, action: CounterAction) -> AppState {
  var copy = state
  switch action {
  case .decrTapped:
    copy.count -= 1
  case .incrTapped:
    copy.count += 1
  }
  return copy
}
```

리듀서에서 항상 copy를 한번 합니다, 그리고 copy와 state를 햇갈리면 미묘한 버그를 유발합니다. 나중에 좀 더 개선해보겠습니다.

왜 이름이 `counterReducer`일까요? `reduce`를 보면 알 수 있습니다.

```swift
[1, 2, 3].reduce(
  <#initialResult: Result#>,
  <#nextPartialResult: (Result, Int) throws -> Result#>
)
```

기존의 reduce는 연산을 계속 해서 `Result`에 축적해 나갑니다. 우리의 `counterReducer`가 reducer라는 이름이 붙은 이유입니다.

버튼의 코드를 아래와 같이 변경합니다.

```swift
Button("-") {
  self.store.value = counterReducer(state: self.store.value, action: .decrTapped)
}
```

코드가 많이 추가되었지만 한가지 좋은 점이 있습니다. 버튼의 액션 클로저 내부의 상태를 직접 변경하는 대신 해당 액션 값을 리듀서에 보내고 리듀서가 필요한 모든 변경을 수행하도록합니다. 이것이 바로 사용자 작업을 선언형으로 처리 한다는 의미입니다. 그리고 상태의 변화를 리듀서 내부로 제한시켰습니다.

### Ergonomics: capturing reducer in store

그러나 이것은 우리가 reducer와 store를 사용하는 방식이 아닙니다. 매번 리듀서를 직접 호출하고 store에 다시 할당해주는 코드를 없애고싶습니다.

reducer를 호출하는 책임을 store에게 맡긴다고 생각해보십시오.

```swift
Button("-") { self.store.send(.decrTapped) }
```

이렇게 간단한 코드가 될것입니다. 이렇게 변경하기위해 우선 store에 Action 종류를 알기위한 제네릭이 필요합니다.

```swift
final class Store<Value, Action>: ObservableObject {
  …
  func send(_ action: Action) {

  }
}
```

store 내부에서 reducer를 생성합니다.

```swift
class Store<Value, Action>: ObservableObject {
  let reducer: (Value, Action) -> Value
  …
  init(initialValue: Value, reducer: @escaping (Value, Action) -> Value) {
    self.value = value
    self.reducer = reducer
  }
}
```

그리고 send를 구현합니다.

```swift
func send(_ action: Action) {
  self.value = self.reducer(self.value, action)
}
```

이전과 똑같이 동작합니다. 다른점은 store에서 상태 변화를 시키고있다는 점 입니다. 이제 다른 위치에서는 AppState를 변경 할 수 없습니다. 액션을 넘겨서 리듀서에 보내야만 합니다.



### Ergonomics: in-out reducers

이제 계속해서 더 많은 상태 변경 코드를 액션과 리듀서에 추가 할 수 있습니다. 하지만 성가신 점이 두가지 있습니다. 먼저 AppState를 복사해서 변경하고 다시 대입하는 구문이 있습니다. 오류를 일으키기 쉽고 또 번거로운 형태입니다. 두번째로 AppState가 점점 커질수록 이런 복사 동작은 비효율적입니다. 리듀서가 동작할 때 마다 거대한 State를 복사하게 될 것 입니다.

Swift의 `inout`을 사용하여 해결하겠습니다.

새 값을 복사하고 반환하는 대신 inout을 사용하여 직접 매개변수의 주소에 접근하도록 리듀서를 변경합니다.

```swift
func counterReducer(value: inout AppState, action: CounterAction) {
  switch action {
  case .decrTapped:
    value.count -= 1
  case .incrTapped:
    value.count += 1
  }
}
```

성능적으로도 향상되었고, 가독성도 높아졌습니다.

### Moving more mutations into the store

아직 상태 변경 코드는 두가지로 나뉘어 있습니다. 일부는 스토어에 액션을 보내는 새 인터페이스를 이용하지만. 일부는 아직 뷰에 인라인으로 코드가 남아있습니다. 이를 수정하겠습니다.

```swift
enum CounterAction {
  case decrTapped
  case incrTapped
}
enum PrimeModalAction {
  case saveFavoritePrimeTapped
  case removeFavoritePrimeTapped
}
enum AppAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)
}
```

이와같이 즐겨찾기 액션을 추가하면서 모듈화 시키고 컴파일 애러를 잡아줍니다.

다음으로 변경할 상태변경 코드는 `FavoritePrimesView`에서 구현한 `.onDelete` 코드입니다

마찬가지로 액션을 추가합니다.

```swift
enum FavoritePrimesAction {
  case deleteFavoritePrimes(IndexSet)
}
enum AppAction {
  …
  case favoritePrimes(FavoritePrimesAction)
}
```

컴파일러 애러를 잡고 onDelete코드를 변경합니다.

```swift
.onDelete { indexSet in
  self.store.send(.favoritePrimes(.removeFavoritePrimes(at: indexSet)))
}
```

이제 모든 상태변경 인라인 코드를 리듀서로 옮겼습니다.
