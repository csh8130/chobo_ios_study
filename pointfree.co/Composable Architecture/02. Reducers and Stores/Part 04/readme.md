# Composable State Management: Higher-Order Reducers

  `고차 구성`은 기존 방식으로는 만들 수 없던 기능을 만들어 낼 수 있는 방식으로 예를들어 함수를 인자로 받아서 다른 함수를 반환하는 고차 함수가 있습니다.

다른 point-free 영상에서 고차 제네레이터를 만들어 본 적이 있으며 고차 난수생성기, 고차 파서를 고려 해 본적도 있습니다. 고차원 구조를 만들 때 마다 기존 방법으로 만들수 없던 것을 만들 수 있게 됩니다.



### What’s a higher-order reducer?

 `고차 리듀서`는 그래서 어떤형태가 되야 할까요. 리듀서를 입력으로 받고 리듀서를 출력으로 반환하는 함수가 있으면 어디서 쓰일까요? 이미 우리는 몇가지 고차 리듀서를 만들었습니다.



- `combine` 은 고차 리듀서 입니다, 여러 리듀서를 입력으로 받아서 각각의 리듀서를 한번씩 실행시키는 새로운 리듀서를 출력하는 함수입니다.

- `pullback`은 고차 리듀서 입니다, 리듀서를 입력으로 받고 로컬 상태 또는 액션을 글로벌 상태 또는 액션으로 작동되는 리듀서로 반환해주는 함수입니다.



 앞선 강의에서 이 두 함수가 얼마나 강력한지 확인했었습니다. 우선 리듀서의 시그니처부터 한번 살펴보겠습니다.

```swift
func higherOrderReducer(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
}
```

간단하게 글로벌 상태와 액션을 사용하여 작성 합니다. 그리고 어떤 상태와 액션을 반환해야 하더라도 아래와 같이 시작하게 됩니다.

```swift
func higherOrderReducer(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {
  return { state, action in
  }
}
```

그리고 여기서부터 우리가 할 수 있는 일에 제한이 없습니다. 리듀서를 수행하기전에 상태나 액션을 사용하여 무언가 수행하는 코드를 넣을 수 있습니다.

```swift
return { state, action in
  // do some computations with state and action
  reducer(&state, action)
}
```

또는 리듀서를 수행하고나서 나온 상태나 액션을 검사 할 수도 있습니다.

```swift
return { state, action in
    // do some computations with state and action
    reducer(&state, action)
    // inspect what happened to state?
}
```

 리듀서를 호출하기 전과 후에 상태와 액션을 변형 시킬 수 있습니다. 이 함수는 많은 힘을 가질 수 있으며 이는 고차 리듀서이기 때문입니다.

그리고 고차 리듀서를 도입하는 이유는 앞서 순수 SwiftUI로 앱을 빌드할때 실수로 버그를 발생시키는 상황을 피하기 위함입니다.



 몇 에피소드 전에 앱의 기본 버전에 활동 피드기능을 추가 할 때로 돌아가보겠습니다. 단순히 타임 스탬프와 Prime이 추가 삭제되는 이벤트만 추적했습니다.

 이전에 우리는 이 기능을 너무 순진하게(?) 구현했습니다. 지금은 리듀서에 그 로직이 들어있습니다.

```swift
func primeModalReducer(state: inout AppState, action: PrimeModalAction) -> Void {
  switch action {
  case .removeFavoritePrimeTapped:
    state.favoritePrimes.removeAll(where: { $0 == state.count })
    state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.count)))

  case .saveFavoritePrimeTapped:
    state.favoritePrimes.append(state.count)
    state.activityFeed.append(.init(timestamp: Date(), type: .addedFavoritePrime(state.count)))
  }
}
```

그러나 여기서 버그는 우리가 Prime 목록을 변경하는 유일한 장소가 아니라는 점 입니다. 완전히 다른 화면인 즐겨찾기 화면이 있으며, 여기에서 Prime을 제거 할 수 있습니다. 처음에는 활동 피드를 변경할 생각이 없었기 때문에 일부를 놓치고 있었습니다.

수정을 쉬웠으며 리듀서에 해당 로직을 추가했습니다.

```swift
func favoritePrimesReducer(state: inout FavoritePrimesState, action: FavoritePrimesAction) -> Void {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.activityFeed.append(.init(timestamp: Date(), type: .removedFavoritePrime(state.favoritePrimes[index])))
      state.favoritePrimes.remove(at: index)
    }
  }
}
```

여전히 좋아보이지 않습니다. 이 두군대 로직은 같은것이지만 두개의 리듀서로 떨어져 있습니다. 이러한 리듀서는 다른 파일이나 모듈에 위치해서 멀리 떨어질 수 있으며 모든 위치에서 확인하기가 어렵습니다. 새로운 활동 피드를 추가하려면 어떻게 해야합니까? 리듀서의 모든 액션을 일일이 검사해야합니다.



### Higher-order activity feeds

고차 리듀서는 이 상황을 더 좋게 만들 수 있습니다. 액티비티 피드 갱신 위치를 이동시키기 위해 고차 리듀서를 만듭니다. counter 액션은 피드 갱신을 하지않으므로 break 합니다.

```swift
func higherOrderReducer(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {

  return { state, action in
    switch action {
    case .counter(_):
        break
    case .primeModal(.removeFavoritePrimeTapped):
    case .primeModal(.saveFavoritePrimeTapped):
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
}
```

나머지 액션들에 대해서 피드를 추가하고 함수명을 변경합니다.

```swift
func activityFeed(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {

  return { state, action in
    switch action {
    case .counter:
      break

    case .primeModal(.removeFavoritePrimeTapped):
      state.activityFeed.append(
        .init(type: .removedFavoritePrime(state.count))
      )

    case .primeModal(.saveFavoritePrimeTapped):
      state.activityFeed.append(
        .init(type: .addedFavoritePrime(state.count))
      )

    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet {
        state.activityFeed.append(
          .init(type: .removedFavoritePrime(state.favoritePrimes[index]))
        )
      }
    }
    reducer(&state, action)
  }
}
```

이제 이고차  리듀서를 사용하여 appReducer를 받습니다.

```swift
ContentView(
  store: Store(
    initialValue: AppState(),
    reducer: activityFeed(appReducer)
  )
)
```

마지막으로 다른 리듀서에 있는 피드 추가 코드를 모두 삭제합니다. 덕분에 즐겨찾기 화면은 더이상 글로벌 상태가 필요없습니다. 이를 주석 처리해서 삭제합니다. 즐겨찾기화면은 이제 Integer 배열만 상태로 가지면 됩니다.

```swift
//struct FavoritePrimesState {
//  var favoritePrimes: [Int]
//  var activityFeed: [AppState.Activity]
//}

func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> Void {
  switch action {
  case let .removeFavoritePrimes(indexSet):
    for index in indexSet {
      state.remove(at: index)
    }
  }
}
```

extension에 추가한 즐겨찾기 화면 상태 코드도 필요가없습니다. 이제 풀백에서 prime 배열에만 접근하면 됩니다.

```swift
//extension AppState {
//  var favoritePrimesState: FavoritePrimesState {
//    get {
//      return FavoritePrimesState(
//        favoritePrimes: self.favoritePrimes,
//        activityFeed: self.activityFeed
//      )
//    }
//    set {
//      self.activityFeed = newValue.activityFeed
//      self.favoritePrimes = newValue.favoritePrimes
//    }
//  }
//}

pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
```

### Higher-order logging

 이제 모든 피드 항목이 고차 리듀서로 이동했습니다. 아직 활동 피드를 조회하는 화면이 없어서 제대로 동작하는지 확인이 어렵습니다. 우선 Store에 print를 추가하여 콘솔에서 로그를 확인 할 수 있습니다.

```swift
func send(_ action: Action) {
  self.reducer(&self.value, action)
  print("Action: \(action)")
  print("Value:")
  dump(self.value)
  print("---")
}
```

확인이 되면 이를 제거하고 고차 리듀서로 다시 만들어봅니다. 그리고 고차 리듀서를 적용합니다

```swift
func logging<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
  return { value, action in
    reducer(&value, action)
    print("Action: \(action)")
    print("State:")
    dump(value)
    print("---")
  }
}

logging(activityFeed(appReducer))
```

하지만 이런식으로 고차 리듀서가 계속 중첩되는것은 좋지않습니다.

```swift
bar(foo(logger(activityFeed(appReducer))))
```

Overture라는 라이브러리를 이용해서 이를 해결 할 수 있습니다.

```swift
// import Overture

ContentView(
  store: Store(
    value: AppState(),
    reducer: with(
      appReducer,
      compose(
        logger,
        activityFeed
      )
    )
  )
)
```

 깔끔해졌습니다. 이런 방식으로 고차 리듀서를 활용하는것이 얼마나 강력한지 생각 해볼 가치가 있습니다. 앱 동작에 영향을 주지않는 로직을 추가하느라 앱 내부에 버그를 만드는것을 방지하고 손쉽게 로깅 기능을 추가했기 때문입니다.

이런 작업은 순수 SwiftUI로는 불가능한 작업입니다. 그리고 지금까지 본것은 고차 리듀서의 시작일 뿐입니다. 

### What’s the point?

지금까지 리듀서는 4가지 유형으로 다루었습니다.

- 동일한 유형의 리듀서들을 combine을 통해 단일 리듀서로 합성했습니다.

- 하위 레벨 상태에서 동작하는 리듀서를 global 영역 상태에서 작동하도록 pullback 했습니다.

- 하위 레벨 액션에서 동작하는 리듀서를 global 영역 액션에서 작동하도록 pullback 했습니다.

- 고차 리듀서를 만들어 추가기능을 계층적으로 쌓을 수 있었습니다



 이것으로 컴포저블 아키텍처의 상태관리 파트 시리즈를 마무리하겠습니다. 아직 우리는 시리즈 시작때 설명한 5가지 문제중 2.5가지정도밖에 해결하지 못했습니다.

우리는 모듈식 아키텍처를 원했기 때문에 구성을 분리하고 자체 모듈에 넣을 수 있어야 합니다. 리듀서를 더 작은 리듀서로 나눌 수 있지만 여전히 상태와 액션을 가지는 Store에 의존적입니다. 그 객체를 분리 할 방법이 없으며 이를 다음장부터 다룰것입니다.

또한 사이드 이펙트에대해서 다뤄야하지만 이번장에서는 언급하지 않았습니다. 마지막으로 아키텍처를 완성 해 갈수록 더 테스트 가능한 앱이 될것이라는점도 다룰 것입니다!
