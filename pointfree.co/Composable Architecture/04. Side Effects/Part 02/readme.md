# Effectful State Management: Unidirectional Effects

 지난시간에 우리 아키텍처의 side effect 처리를 모델링했지만 아직 부족합니다. 리듀서는 out side로 write를 할 수 있지만 다시 read 할 수 없습니다. 이번 주제는 단방향 데이터 흐름에 대해 전념할 것입니다.



### Introduction

 지난시간에 우리는 첫번째 Effect를 추출했습니다. 다시 확인 해 봅시다.



### Recap

 즐겨찾기한 소수를 디스크에 저장하는 side effect가 있었고, 이를 제어할 방법이 필요하다는 것을 알았습니다. 뷰를 단순화 하기위해 모든 로직을 리듀서로 옮기고 단순히 뷰가 사용자 Action을 Store로 보내도록 했습니다.



즉 말 그대로 side effect 코드를 reducer로 옮겼습니다. 대신 reducer의 테스트 용의성과 코드 가독성을 해쳤습니다.



그래서 `side effect 에피소드`에서 배운 교훈을 사용해서 함수에 새로운 output을 생성하고 effect를 함수 밖으로 밀어냈습니다. side effect 실행 책임을 Store로 넘겼습니다.



 disk에 save하는것은 단순한 effect였고 즐겨찾기 목록을 load 하는것은 좀 더 복잡한 effect 입니다.

저장은 fire-and-forget 작업이며 실행 후 어떤 일이 발생했는지 관심가질 필요가 없습니다.

그러나 load는 작업을 수행하고 data를 reducer로 다시 전달해야합니다.



### Synchronous effects that produce results

아래에 위치한 disk load 작업을 reducer로 옮겨 봅시다.

```swift
Button("Load") {
 let documentsPath = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    )[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl
    .appendingPathComponent("favorite-primes.json")
  guard
    let data = try? Data(contentsOf: favoritePrimesUrl),
    let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return }
  self.store.send(.loadedFavoritePrimes(favoritePrimes))
}
```

버튼을 눌렀을때 store로 send하는 액션이 이미 있지만 side effect까지 store로 옮기고 싶습니다.



새로운 Action을 도입하고 이를 수행하게하겠습니다. 

```swift
Button("Load") {
  self.store.send(.loadButtonTapped)
  }
  
public enum FavoritePrimesAction {
  // …
  case loadButtonTapped
  }
```

이제 reducer에서 `case  .loadButtonTapped:` 를 처리해야 합니다



load 버튼에 있던 동작을 모두 가져왔습니다.

```swift
case .loadButtonTapped:
  let documentsPath = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    )[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl
    .appendingPathComponent("favorite-primes.json")
  guard
    let data = try? Data(contentsOf: favoritePrimesUrl),
    let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return }
  self.store.send(.favoritePrimesLoaded(favoritePrimes))
```

하지만 reducer에서 side effect를 일으키고 싶지 않습니다. 클로저로 감쌉니다.

```swift
case .loadButtonTapped:
  return {
    let documentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
      )[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    let favoritePrimesUrl = documentsUrl
      .appendingPathComponent("favorite-primes.json")
    guard
      let data = try? Data(contentsOf: favoritePrimesUrl),
      let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
      else { return }
    self.store.send(.favoritePrimesLoaded(favoritePrimes))
  }
```

`Use of unresolved identifier ‘self’` 

side-effect를 store로 보내고 싶지만 reducer는 self.store 접근이 불가능합니다.



그리고 effect를 reducer로 옮겼기 때문에 고려 해야 할 것이 있습니다. store에서 effect를 수행하고나서 결과를 다시 reducer에서 받아야 하기 때문입니다!

`() -> Void` 클로저로는 할 수 없는 작업입니다. 

`public  typealias  Effect<Action>  =  ()  ->  Action`

형태로 타입의 시그니처를 변경합니다.

하지만 기존의 fire-and-forget 방식은 Action을 nil로 하기위해 옵셔널로 만듭니다.

`public  typealias  Effect<Action>  =  ()  ->  Action?`



send function으로 가보겠습니다.

```swift
public func send(_ action: Action) {
  let effect = self.reducer(&self.value, action)
  effect()
```

`Result of call to function returning ‘Action?’ is unused`

effect()를 실행하고 나온 Action을 사용하지않는다는 좋은(?)경고입니다. 

```swift
public func send(_ action: Action) {
  let effect = self.reducer(&self.value, action)
  if let action = effect() {
    self.send(action)
  }
```

반환된 action이 nil(fire-and-forget)이 아닌경우 send 합니다.



reducer를 결합하는 combine에도 같은 경고가 있습니다.

```swift
public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.map { $0(&value, action) }
    return {
      for effect in effects {
        effect()
      }
    }
```

반환된 action을 받습니다.

```swift
return {
  for effect in effects {
    let action = effect()
  }
}
```

반환 클로저는 () -> Action? 입니다.

```swift
return { () -> Action? in
```

```swift
return { () -> Action? in
  for effect in effects {
    let action = effect()
    return action
  }
}
```

위처럼 작업하면 첫번째 이팩트만 실행되고 reducer로 피드백 될것입니다. 틀린 방법입니다.



```swift
return { () -> Action? in
  var finalAction: Action?
  for effect in effects {
    let action = effect()
    if let action = action {
      finalAction = action
    }
  }
  return finalAction
}
```

모든 이펙트가 수행되고 마지막 Action을 반환합니다. 이것도 조금 이상합니다 일부 Action을 놓치게됩니다.



### Combining multiple effects that produce results

reducer의 시그니처는 잘못된것으로 보입니다.

`public  typealias  Reducer<Value,  Action>  =  (inout  Value,  Action)  ->  Effect<Action>`



단일 Action이 아닌 복수의 Action을 처리해야 합니다.

`public  typealias  Reducer<Value,  Action>  =  (inout  Value,  Action)  ->  [Effect<Action>]`



send 메서드로 돌아가서 effects를 순회하며 action을 수행하도록 변경합니다.

```swift
public func send(_ action: Action) {
  let effects = self.reducer(&self.value, action)
  effects.forEach { effect in
    if let action = effect() {
      self.send(action)
    }
  }
}
```



이제 combine을 수정할 수 있습니다.

```swift
public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.flatMap { $0(&value, action) }
    return effects
```

flatmap으로 effects를 반환합니다.



### Pulling local effects back globally

pullback또한 수정되어야 합니다.



pullback은 로컬 reducer(State, Action)를 global reducer로 바꿔주는 역할입니다.

로컬 reducer를 실행하면 로컬 effects가 생깁니다. 이를 global effects로 변환해 줍니다.



또 logging 부분 수정이 필요합니다.



```swift
public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effect = reducer(&value, action)
    let newValue = value
    return {
```

마찬가지로 이제 단일 effect가 아닌 배열을 수행해야합니다

```swift
return { value, action in
  let effects = reducer(&value, action)
  let newValue = value
  return [{
    print("Action: \(action)")
    print("Value:")
    dump(newValue)
    print("---")
    return nil
  }] + effects
}
```



### Working with our new effects

Composable 아키텍쳐 모듈은 수정을 마쳤지만 view 실행을 위해 favorite primes 모듈은 이제 손봐야 됩니다.



action은 effect배열을 반환합니다.

```swift
public func favoritePrimesReducer(
  state: inout [Int], action: FavoritePrimesAction
) -> [Effect<FavoritePrimesAction>] {
```

다른 부분도 대체로 배열로 레핑하는 형태로 수정됩니다.



점점 reducer가 거대해지고 이해하기 힘들어질 위험이 발생합니다.



save나 load는 private func 로 빼내어



### What’s unidirectional data flow?

복수의 effect를 외부로 추출했습니다. 우리가 한것을 다시 생각 해 봅시다.



 우리는 disk load를 외부로 추출하고 싶었습니다. 이는 disk save와 전혀 다른것을 알게되었습니다.

save 작업은 fire-and-forget 이었습니다. 실행결과를 신경 쓸 필요가 없었습니다.

그러나 load는 reducer로 Action을 다시 보내야 했습니다. 이를 위해 effect 시그니처를 void-to-void 클로저 반환에서 void-to-optional 반환으로 변경 했습니다.

그 후 Store는 reducer의 effect를 모두 수집하고 수행하고 , 모든 action을 reducer에서 수행합니다.



바로 이 작업을 단방향 데이터 흐름이라고 합니다. reducer에서 생긴 피드백은 그래도 reducer에서 다시 수행됩니다. 



결국 상태 변경은 reducer에서만 동작하기때문에 이해하기 간단합니다. 하지만 reducer에서 다시 reducer로 피드백 주기위해 처리해야할것이 너무 많았고 이 복잡함을 피하기 위해 swiftUI를 포함한 많은 프레임 워크들이 양방향 바인딩을 지원하는 것입니다. 하지만 그런 방식은 상황을 나중에 더 복잡하게 만들 수 있습니다.



### Next time: asynchronous effects


