# Modular State Management: Reducers

 SwiftUI만으로는 해결 할 수 없는 5가지 유형의 문제를 알아보았고 

- 단순한 값 타입으로, 복잡한 app state를 구성 할 것
- 변경 코드들을 흩 뿌리지 말고 일관되게 다룰 것
- 거대한 프로그램을 여러개의 작은 단위의 조합으로 나타낼 것
- 사이드 이펙트를 일으키고 결과를 잘 다룰 것
- 테스트를 간단하게 할 수 있을 것

 우리는 그 중 2.5개를 해결했습니다.

- state는 간단한 value 타입으로 구성되었습니다.
- 상태 변경은 일관된 방법으로 관리됩니다.
- 다양한 구성을 사용하여 app 전체에 적용되는 리듀서를 화면별로 작은 리듀서로 쪼갤 수 있습니다.

 마지막 내용은 아키텍쳐의 모듈성을 절반만 해결한 것입니다. 리듀서는 쪼개는게 가능하지만 state를 그리거나 store에 action을 보내는 뷰에서는 할 수 없습니다.

 특정 뷰가 관심을 갖는 state와 action에 대한 store만 분리 할 수 있다면 뷰 자체가 모듈로 추출 될 수 있습니다.

 그래서 오늘 먼저 모듈화의 의미와 이것이 왜 유익한지 직접 확인하고, `Store`를 관심 있는것에만 집중하게 만들어 보겠습니다.



### Recap

 이전에 만든 앱입니다. 간단한 예제 프로그램이지만 실제 앱에서 볼수있는 특징이 있습니다.

- 여러 화면에서 지속되어야 하는 전역적인 상태를 관리합니다.

- 네트워크 요청으로 side-effect를 excute합니다.

이전까지는 하나의 플레이그라운드에서 모든 작업을 했지만 모듈화 작업에 앞서 우선 별도의 프로젝트로 옮기도록 하겠습니다.



### What does modularity mean?

 모듈화를 시작하기전에 모듈화가 의미하는 바를 정의합니다. 

모듈은 앱에서 가져와서 사용 할 수 있는 코드들의 단위입니다. Foundation 같이 Swift에서 제공되는 모듈이 있고 SwiftUI도 모듈이며 타사에서 제공하는 라이브러리도 마찬가지 입니다.

 모듈은 자신을 사용하는 부모의 동작에 접근 할 수 없습니다. 타입, 뷰컨트롤러를 알 수 없으며 모듈을 사용하는 코드와는 완전히 분리되어 있습니다.

 모듈 방식으로 나누면 테스트하기에도 수월합니다. 더 간단하고 이해하기 쉬운 테스트를 금방 만들 수 있게 됩니다.

그렇다면 앱을 어떤 단위로 나누어야 할까요? 여러가지 방법이 있습니다 (프레임워크, 라이브러리, 패키지) 그 중 우리는 프레임 워크로 모듈을 나눌 것 입니다.



### Modularizing our reducers

우리가 정의한 모든 리듀서는 구성 요소를 설명하는 단위입니다. 즉 모듈로 나눌 수 있어야 합니다. `counterReducer`, `primeModalReducer`, `favoritePrimesReducer` 3개의 리듀서가 있고 각각 하나의 화면을 나타냅니다.

프로젝트로 이동하여 각 감속기마다 하나씩, 3개의 프레임워크를 추가합니다. 그리고 Store와 리듀서 구성 함수를 포함하는 아키텍쳐 핵심 라이브러리 코드가 있으므로 `ComposableArchitecture`라는 프레임 워크를 추가로 만듭니다.



 ComposableArchitecture프레임워크 폴더에서 ComposableArchitecture.swift 파일을 만들고 Store와 pullback, combine, logging을 옮겨옵니다. command + b 를 통해 프레임워크를 빌드 할 수 있습니다.

 그러나 API가 공개되어있지 않기 때문에 사용 할 수 없습니다. 기본적으로 모듈 외부로는 숨겨진 상태이므로 인터페이스 앞에 public을 붙여줘야 합니다.

그리고 마지막으로 ContentView.swift와 SceneDelegate.swift에서 import를 해주어야 합니다.

```swift
import ComposableArchitecture
```

### Modularizing the favorite primes reducer

마찬가지로 `FavoritePrimes` 모듈에 FavoritePrimes.swift를 추가합니다. 그리고 `favoritePrimesReducer`를 이동시킵니다. 그리고 `FavoritePrimesAction`도 함께 이동시킵니다.



ContentView.swift에서 모듈을 import 하고 접근 제어를 public으로 변경합니다. 빌드에 성공했으면 FavoritePrimes.swift 파일을 다시 살펴보겠습니다.

```swift
public enum FavoritePrimesAction {
  case deleteFavoritePrimes(IndexSet)
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.remove(at: index)
    }
  }
}
```

 우리는 코드를 옮기고 거의 바로 빌드에 성공했기 때문에 한것이 거의 없는것 처럼 느껴집니다. 하지만 이것은 별도의 모듈로 분리되었기 때문에 아주 많은 진전이 있었습니다.

 여기에는 매우 읽기쉬운 11줄의 코드만 남았고 App 전체 영역의 State, Action에 접근이 불가능해 졌습니다. 표준 라이브러리 외에 어디에도 접근이 불가능하게 분리하였습니다.



### Modularizing the counter reducer

`Counter` 모듈도  `FavoritePrimes`과 동일하게 작업합니다



### Modularizing the prime modal reducer

추출할 모듈이 하나 더 있습니다. 다른 모듈과 거의 동일하지만 좀 더 복잡합니다. 이전과 똑같이 작업하면 AppState를 찾지 못해서 애러가 발생합니다.

> Cannot find type 'AppState' in scope



근본적인 문제는 모듈에서 AppState에 의존하는 코드가 있다는 점 입니다. 앱 전체 State를 모듈로 가져오고 싶지 않습니다.

PrimeModalState 라는 State를 새로 만듭니다.

```swift
public struct PrimeModalState {
  public var count: Int
  public var favoritePrimes: [Int]

  public init(count: Int, favoritePrimes: [Int]) {
    self.count = count
    self.favoritePrimes = favoritePrimes
  }
}
```

AppState와 동일한 구성이기 때문에 애러가 나는부분은 pullback을 호출하는 부분 뿐입니다. 

```swift
pullback(primeModalReducer, value: \.self, action: \.primeModal),
```

키-패스를 사용할 수 있게 추가합니다.

```swift
extension AppState {
  var primeModal: PrimeModalState {
    get {
      PrimeModalState(
        count: self.count,
        favoritePrimes: self.favoritePrimes
      )
    }
    set {
      self.count = newValue.count
      self.favoritePrimes = newValue.favoritePrimes
    }
  }
}

// 키패스 경로 변경   
pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
```

 모든것이 이전처럼 잘 작동합니다. 앱의 모든 리듀서를 모듈화 했습니다. 3개중 2개의 리듀서는 간단하게 모듈화가 가능했지만 나머지 하나는 앱 상태의 여러 부분에 접근이 필요해서 복잡했습니다. 이를 해결하기 위해 관심있는 정보만 가져오기위한 중간 구조체를 도입했습니다.

 이것은 앞으로도 여러 전역 상태에 접근 할 때 마다 반복적으로 사용 가능한 트릭입니다. 하지만 `boilerplate` 코드가 그 때 마다 발생하므로 이를 해결하기위해 공개 이니셜라이저를 정의 합니다.



```swift
public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])
```

 여전히 잘 빌드되고 작동됩니다. 그러나 튜플을 너무 남용하면 종종 문제가 됩니다. 처음에는 튜플로 만들고 나중에 구조체가 필요한 순간에 변경할 수도 있습니다.

이번에 모듈화 작업을 하며 이 아키텍쳐가 얼마나 모듈화 되어있는지 알 수 있었습니다. 매우 간단하게 모듈로 분리가 가능했고 최악의 상황에는 약간의 추가 코드가 필요했을 뿐입니다.



다음시간에는 우리는 리듀서와 상태 그리고 액션을 분리했지만 아직까지 `View`를 분리하지 못했습니다. 그 문제에 접근 할 예정입니다.


