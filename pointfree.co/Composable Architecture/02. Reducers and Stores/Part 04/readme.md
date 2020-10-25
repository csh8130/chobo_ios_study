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




