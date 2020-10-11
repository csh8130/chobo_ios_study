# Composable State Management: State Pullbacks

 지금 우리는 아주 기본적인 아키텍쳐 구조를 만들었다. 앞에서 많은 로직을 리듀서로 가져왔지만 그 리듀서가 너무 커지면 문제가 됩니다. 

 스토어 클래스는 상태 값을 저장하기위한 struct 구조체로 만들었고, 래핑을 통해 값이 변경 될 때마다 SwiftUI에 이를 알릴 수 있습니다. 또 스토어 클래스는 프로그램의 두뇌 역할을 하는 리듀서를 가지고 있습니다.



appReducer는 너무 무거워 보입니다. 3개의 다른 화면을 모두 처리하기 위한 거대한 Reducer로 계속 확장하기에 좋아보이지 않습니다. Reducer를 쪼개서 구성하는 방법을 찾아야 합니다.



### Combining reducers

```swift
func appReducer(value: inout AppState, action: AppAction) -> Void {
  switch action {
  case .counter(.decrTapped):
    state.count -= 1

  case .counter(.incrTapped):
    state.count += 1

  case .primeModal(.saveFavoritePrimeTapped):
    state.favoritePrimes.append(state.count)
    state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

  case .primeModal(.removeFavoritePrimeTapped):
    state.favoritePrimes.removeAll(where: { $0 == state.count })
    state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

  case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
    for index in indexSet {
      let prime = state.favoritePrimes[index]
      state.favoritePrimes.remove(at: index)
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(prime)))
    }
  }
}
```

현재 우리의 appReducer입니다. 총 3개 화면, 5가지 액션을 처리하고 있습니다. 이를 쪼개기 전에 우선 두개의 Reducer를 하나로 합치는 코드를 구현하기는 쉽습니다.

```swift
func combine<Value, Action>(
  _ first: @escaping (inout Value, Action) -> Void,
  _ second: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {

  return { value, action in
    first(&value, action)
    second(&value, action)
  }
}
```

이것은 단순히 첫번째 Reducer를 실행하고 두번째 Reducer를 실행하는것으로 해결했습니다.

이제 거대한 리듀서를 화면 단위로 분해하겠습니다. Counter, Modal, Favorite 3가지 화면에대한 리듀서를 각각 만들겠습니다.

```swift
func counterReducer(value: inout AppState, action: AppAction) -> Void {
  switch action {
  case .counter(.decrTapped):
    state.count -= 1

  case .counter(.incrTapped):
    state.count += 1

  default:
    break
  }
}

func primeModalReducer(state: inout AppState, action: AppAction) -> Void {
  switch action {
  case .primeModal(.addFavoritePrime):
    state.favoritePrimes.append(state.count)
    state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))

  case .primeModal(.removeFavoritePrime):
    state.favoritePrimes.removeAll(where: { $0 == state.count })
    state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

  default:
    break
  }
}

func favoritePrimesReducer(state: inout AppState, action: AppAction) -> Void {
  switch action {
  case let .favoritePrimes(.removeFavoritePrimes(indexSet)):
    for index in indexSet {
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
      state.favoritePrimes.remove(at: index)
    }

  default:
    break
  }
}
```

그리고 모든 리듀서를 마스터 리듀서에 연결합니다

```swift
let appReducer = combine(combine(counterReducer, primeModalReducer), favoritePrimesReducer)
```

리듀서를 두개씩만 연결 가능해서 어색합니다. 가변 인자 함수로 구현하여 결합 합니다.

```swift
let appReducer = combine(
  counterReducer,
  primeModalReducer,
  favoritePrimesReducer
)
```


