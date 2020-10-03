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


