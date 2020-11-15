# Modular State Management: View Actions

 View에서 AppState 전체가 아닌 작게 쪼갠 State를 취할 수 있게 되었습니다. View는 점점 Reducer와 비슷한 범위를 가지려 하고 있습니다.



### Transforming a store’s action

 Store를 사용하는 View에서 State에 접근하는 부분을 개선 했지만 AppAction에 의존하는 코드가 남아있어서 모듈로 분리는 불가능합니다.

```swift
final class Store<Value, Action>: ObservableObject {
  …
  func ___<LocalAction>() -> Store<Value, LocalAction>
}
```

 위 처럼 Global Action을 Local Action으로 변환 해 줄 함수가 필요합니다.



```swift
final class Store<Value, Action>: ObservableObject {
  …
  public func view<LocalAction>(
    f: @escaping (LocalAction) -> Action
  ) -> Store<Value, LocalAction> {
    return Store<Value, LocalAction>(
      initialValue: self.value,
      reducer: { value, localAction in
        self.send(f(action))
        value = self.value
    }
    )
  }
}
```


