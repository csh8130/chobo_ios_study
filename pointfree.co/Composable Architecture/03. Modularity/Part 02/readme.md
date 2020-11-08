# Modular State Management: View State

 리듀서는 모듈식으로 별도의 프레임워크로 추출하는데 성공했지만 View는 여전히 모듈식과는 거리가 있습니다. 해당 문제를 해결 해 보겠습니다.

 앞서 컴포저블 아키텍처가 얼마나 모듈화를 고려했는지 알 수 있었던 점으로 리듀서를 별도의 모듈로 추출하는데 리펙터링이나 코드 수정이 필요하지 않았습니다. 최악의 경우 추가 boilerplate 코드가 필요한 정도였을 뿐입니다.

### Modularizing our views

 모든 뷰는 모든 앱 상태(State)에 액세스 할 수 있고, 액션(Action)도 보낼 수 있습니다. 이는 모두 AppState와 AppAction을 통해 일반화된 Store를 보유하고 있기 때문입니다. 이러한 중앙 집중식 Store를 보고서 한눈에 어떤 정보에 접근하고 어떤 변이를 일으키는지 알 방법이 없습니다.

 예를 들어, `FavoritePrimesView` 는 favoritePrimes 배열과 deleteFavoritePrimes 액션에만 액세스 하면 되지만 지금은 모든 항목에 액세스가 가능합니다.

 이것은 글로벌 State와 Action이 유출되는걸 막을 수 없다는 의미입니다.

```swift
.onDelete { indexSet in
  self.store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
  self.store.send(.counter(.incrTapped))
}
```

 예를들자면 이상한 동작이지만 이런식으로 counter 수치를 변경시키는 코드를 넣을 수 있다는 의미입니다. 이런 종류의 관계없는 변이는 복사-붙여넣기, 리펙토링 중에 쉽게 유입 될 수 있으며, 뷰를 완전히 격리해서 모듈화 시켰다면 컴파일러가 오류를 일으키게 됩니다.

 `IsPrimeModalView`, `CounterView` 도 동일합니다. 리듀서는 자기가 필요한것만 취하도록 리펙토링 했었지만, View들은 지금 자기가 필요한것 외에도 많은부분에 의존성을 갖고 있습니다.

```swift
@ObservedObject var store: Store<AppState, AppAction>
```

모두의 공통점은 앱 전체에 접근가능한 store를 이용한다는 점 입니다. 리듀서와 마찬가지로 Store또한 모듈화가 필요합니다.



### Transforming a store's value

```swift
public final class Store<Value, Action>: ObservableObject {
    // 기존 코드
    
    func ___<LocalValue>(
        _ f: @escaping (Value) -> LocalValue
    ) -> Store<LocalValue, Action> {
        return Store<LocalValue, Action>(
            initialValue: f(self.value),
            reducer: { localValue, action in
                self.send(action)
                localValue = f(self.value)
        }
        )
    }
}
```

store를 local Value에만 관심을 가지도록 변경하는 함수를 이처럼 만들 수 있습니다. 

하지만 이상한점이 두가지있습니다.

- refucer에서 가지고있는 data만으로 구현 할 수 없었고, Store에 action을 send해서 Store가 변경되었다는 사실에 의존해서 내부 동작으로 이용했습니다.

- reducer에서 localValue를 전달 받았으나 이를 사용하지는 않고 덮어 씌우는데에만 사용 했습니다.

### A familiar-looking function

이상한점은 제쳐두고 일단 컴파일에 성공했습니다. 함수를 다시 작성하면 아래와 같습니다.

```swift
// ((Value) -> LocalValue) -> ((Store<Value, _>) -> Store<LocalValue, _>

// ((A) -> B) -> ((Store<A, _>) -> Store<B, _>)

// ((A) -> B) -> ((F<A>) -> F<B>)

// map: ((A) -> B) -> ((F<A>) -> F<B>)
```

점점 추상화를 시켜보니 13번 에피소드 주제였던 map과 동일한 구조임을 알 수 있습니다. 



우리가 만든 map이 어떻게 작동하는지 playground에서 먼저 시험 해 보겠습니다.

```swift
let store = Store<Int, Void>(initialValue: 0,
 reducer: { count, _ in count += 1 })

store.send(())
store.send(())
store.send(())
store.send(())
store.send(())

store.value // 5
```

 간단한 Store와 reducer를 생성했습니다. 아직까지는 우리가 생각한대로 동작합니다.

```swift
let newStore = store.map { $0 }

newStore.value // 5
```

값을 변경하지않고 map을 사용한 store를 새로 생성합니다.

```swift
newStore.send(())
newStore.send(())
newStore.send(())
newStore.value // 8
```

새로운 store에 액션을 보내어 값을 확인합니다.

```swift
store.value // 8
```

 그리고 원래의 store의 값 또한 변한것을 알 수 있습니다. 약간 이상하게 느껴질 수 있지만 우리가 원하던 동작입니다. local store가 작업을 보낼 때 마다 global store에 변경사항이 적용되도록 합니다.

 불행히도 아직 완벽하지 않습니다.

```swift
store.send(())
store.send(())
store.send(())
newStore.value // 8
store.value // 11
```

다시 global store에 액션을 보내게 되면 값이 틀어지게 됩니다.

local store에서 action을 호출하면 global store의 action을 직접 호출하게 됩니다. 하지만 global store에서 데이터를 받을 방법이 없습니다. 
