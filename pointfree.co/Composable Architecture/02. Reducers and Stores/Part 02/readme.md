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

### Focusing a reducer's state

Reducer를 쪼개는데는 성공했지만 각각의 리듀서는 AppState 전체를 취하고있습니다. 우리가 원하는것은 아래와 같이 각 리듀서가 자신에게 필요한 앱 상태만 취하는것입니다.

```swift
//func counterReducer(state: inout AppState, action: AppAction) -> Void {
func counterReducer(state: inout Int, action: AppAction) -> Void {
  switch action {
  case .counter(.decrTapped):
    // state.count -= 1
    state -= 1

  case .counter(.incrTapped):
    // state.count += 1
    state += 1

  default:
    break
  }
}
```

하지만 이렇게 바꾸면 방금 구현한 combine 에서 컴파일 애러가 발생한다. 이를 해결하기위해 `pullback`을 사용하여 해결하게 된다.

### Pulling back reducers along state

```swift
pullback(counterReducer) { $0.count }
```

 위에서 변경한 local state를 가지는 counterReducer를 글로벌 state를 가지는 reducer로 변형 해주는 함수를 만들어 컴파일 애러를 잡아야 한다. 기존의 (예전에 다른 강의에서 소개했던) pullback 구조로는 동작이 원하는데로 되지 않는다. 

```swift
func pullback<LocalValue, GlobalValue, Action>(
  _ reducer: @escaping (inout LocalValue, Action) -> Void,
  get: @escaping (GlobalValue) -> LocalValue,
  set: @escaping (inout GlobalValue, LocalValue) -> Void
) -> (inout GlobalValue, Action) -> Void {

  return  { globalValue, action in
    var localValue = get(globalValue)
    reducer(&localValue, action)
    set(&globalValue, localValue)
  }
}
```

`get`, `set`을 모두 가지는 풀백 구조로 변형하여 글로벌 상태 내부의 변수에 set이 가능하도록 만들었다.

```swift
pullback(counterReducer, get: { $0.count }, set: { $0.count = $1 })
```

풀백을 호출하는 형태도 위와같이 변경 해야 한다.


