# Composable State Management: Action Pullbacks

local영역에서 작동하는 action reducer를 pullback을 이용하여 global 영역으로 드러낼 수 있습니다. 하지만 Swift의 enum과 struct의 처리방식 차이로 인해 약간 작업이 더 필요합니다. `enum properties`를 이용해 이를 해결합니다. 

### Focusing a reducer's actions

```swift
func counterReducer(state: inout Int, action: AppAction) -> Void {
  switch action {
  case .counter(.decrTapped):
    state -= 1

  case .counter(.incrTapped):
    state += 1

  default:
    break
  }
}
```

 이전 시간에 작업한 reducer를 다시 확인합니다. state로 단일 Integer만 취하는것은 바람직합니다. 하지만 action의 경우 App전체의 동작이 모두 포함되고 있습니다.

switch-case 에서 default가 필요하다는 것을 보면 무언가 잘못 되었다는것을 느낄 수 있습니다.

```swift
func counterReducer(state: inout Int, action: CounterAction) -> Void {
  switch action {
  case .decrTapped:
    state -= 1

  case .incrTapped:
    state += 1
  }
}
```

 이번장에서는 이와 같이 CounterAction으로 관심있는 action에 대해서만 동작하도록 변경 해 보겠습니다. 코드가 짧아지고 이 코드를 처음 접하는 사람이 해당 모듈 이외에는 어디도 건드릴 수 없도록 제한 시킬 수 있게 됩니다.



### Enums and key paths

```swift
pullback(counterReducer, value: \.count)
```

위에서 코드를 변경하면 pullback에서 바로 컴파일 애러가 발생하게 됩니다. 이전 장에서 state를 다룰 때 global 영역에서 local영역으로 변경한 것과 유사한 상황 입니다.

동일한 솔루션을 사용하기에는 enum에는 key-path 개념이 없습니다. 

그래서 swift에서 key-path를 구현하는 방법과 동일하지는 않지만 유사하게 동작하게 만들려고 합니다.

```swift
struct EnumKeyPath<Root, Value> {
  let embed: (Value) -> Root
  let extract: (Root) -> Value?
}

// \AppAction.counter을 // EnumKeyPath<AppAction, CounterAction> 으로 사용 하기 위해
```

### Enum properties

 enum은 struct에 비해 지원되는 기능이 적습니다. enum properties라는 개념의 [주제](https://www.pointfree.co/episodes/ep52-enum-properties)로 다룬적이 있는 내용입니다. 이번에도 동일하게 enum을 다룹니다.

```swift
enum AppAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)
  case favoritePrimes(FavoritePrimesAction)

  var counter: CounterAction? {
    get {
      guard case let .counter(value) = self else { return nil }
      return value
    }
  }
  var primeModal: PrimeModalAction? {
    get {
      guard case let .primeModal(value) = self else { return nil }
      return value
    }
  }
  var favoritePrimes: FavoritePrimesAction? {
    get {
      guard case let .favoritePrimes(value) = self else { return nil }
      return value
    }
  }
}
```

 위와같이 enum 내부에서 모든 action에 대해 접근을 가능하게 추가하여 struct와 비슷하게 접근이 가능하며 이는 state를 다루던 방식과 비슷하게 action을 다룰 수 있게 해줍니다.

앞으로는 위의 작업을 수동으로 일일이 하기보다는 [오픈소스](https://github.com/pointfreeco/swift-enum-properties) 도구를 만들어 두었으므로 이를 적용해서 진행할 것이다.



도구를 사용했다면 우리가 지금 필요한 getter 가 생성되었을 것이고 나중에 필요한 setter도 생성되었을 것이다. enum을 아래와 같이 구조체처럼 사용 할 수 있게된다. 그리고 아래처럼 키패스도 동작하게 된다

```swift
let someAction = AppAction.counter(.incrTapped)
someAction.counter
// Optional(incrTapped)

someAction.favoritePrimes
// nil

\AppAction.counter
// WritableKeyPath<AppAction, CounterAction?>
```



### Pulling back reducers along actions


