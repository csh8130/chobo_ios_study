# SwiftUI and State Management: Part 3

Part1, 2에서 만든 프로그램을 가지고 문제점을 알아보자.



#### 앞서 살펴본 SwiftUI 장점

- UI를 표현하기위해 단일 진입 점으로 `body` 만 사용하는것은 기존에 UIKit을 사용할 때 보다 훌륭하다. 뷰를 선언적 프로그래밍으로 만들 수 있다.

- 로컬 상태를 관리하는 도구가 제공된다. `@State` 이 값이 변경되면 화면을 렌더링 할 수 있게하는 바인딩 가능한 값을 제공합니다.

- 로컬 상태관리로 충분하지 않은 경우 `@ObjectBinding` 을 사용하여 여러 뷰가 동일한 데이터를 공유할 수 있도록 할 수 있습니다.

- 뷰의 역할이 확실히 분리되었다. SwiftUI는 View를 위한 `struct`를 만들고 `body`에 뷰를 정의 하는것, 그리고 뷰를 동적으로 업데이트하기위해 상태를 만드는것 외에 다른 방법을 제공하지 않습니다.
  
  - 기존의 UIKit에서 UIView와 UIViewController가 역할을 분리하지 못했다. 그리고 상태 를 업데이트하는 방법에 일관성이 없었다. (notification, KVO, delegate, action, callback)



#### 앱 상태를 추가하기 번거로움

AppState 클래스를 BindableObject로 만들고 passthrough subject에 연결하는것은 쉬웠지만 확장이 쉽지는 않습니다. 지금은 속성이 두 개 뿐이지만 상태 클래스는 쉽게 수십개의 속성이 추가 될 수 있으며 여러 하위 클래스를 가질 수 있습니다.



예를 들어, 구조체를 추가하여 로그인 한 사용자의 개념을 도입 할 수 있습니다.

```swift
struct User {
  let id: Int
  let name: String
  let bio: String
}
```

그리고 AppState에 옵셔널 User를 추가합니다.

```swift
var loggedInUser: User? {
  willSet { self.objectWillChange.send() }
}
```

이 사용자가 수행했던 모든 활동을 기록하고싶습니다. 이를 위해 또 상태를 정의합니다.

```swift
struct Activity {
  let timestamp: Date
  let type: ActivityType

  enum ActivityType {
    case addedFavoritePrime(Int)
    case removedFavoritePrime(Int)
  }
}
```

AppState에 추가합니다.

```swift
var activityFeed: [Activity] = [] {
  willSet { self.didChange.send() }
}
```

모든 상태마다 willSet `boilerplate code`를 추가해야해서 점점 알아보기가 힘듭니다.

```swift
var count = 0 {
  didSet { self.didChange.send() }
}

var favoritePrimes: [Int] = [] {
  didSet { self.didChange.send() }
}

var activityFeed: [Activity] = [] {
  didSet { self.didChange.send() }
}

var loggedInUser: User? = nil {
  didSet { self.didChange.send() }
}
```

최근에는 `@Published`가 생겨서 알아보기 쉽게 변경되었다.

```swift
@Published var count: Int = 0
@Published var favoritePrimes: [Int] = []
@Published var loggedInUser: User?
@Published var activityFeed: [Activity] = []
```



#### 흩어져있는 상태 변경 코드

상태 변경이 쉽고 UI전체에 변경사항이 적용되지만 이를 어떻게 구성해야하는지 명확하지않습니다. 우리 프로젝트에서 `Counter`는 상태 변경코드가 너무 흩어져있습니다.

```swift
Button(action: { self.state.count -= 1 }) {
…
Button(action: { self.state.count += 1 }) {
…
Button(action: { self.showModal = true }) {
…
Button(action: {
  nthPrime(self.state.count) { prime in
    self.alertNthPrime = prime
  }
}) {
…
onDismiss: { self.showModal = false }
```

이러한 변형중 일부는 글로벌 상태에서, 일부는 로컬 상태에서 발생합니다. 그리고 또 alert의 경우 아래와 같이 바인딩에의해 내부 코드가 숨겨져있습니다.

```swift
.alert(item: self.$alertNthPrime) { alert in
```



여기서 문제는 상태들이 어떻게 변경되는지를 찾을 수 있는 분명한 방법이 없다는 것입니다. 여러 장소에 숨겨져 있으므로 이해하기 힘든 코드입니다.

또 다른 문제는 이런 코드가 추가 될 수록 선언형 프로그래밍으로부터 멀어진다는 것입니다. 실행해야할 명령이 나열된 클로저이므로 선언적이지 않습니다.

`body`는 순전히 상태들을 뷰 구조로 표시해주기만 하도록 나타내는게 이해하기쉽고 테스트하기도 좋습니다.



이번에는 유저의 변경 내역을 추적하는 코드를 추가해보겠습니다.

```swift
Button(action: {
  self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })
  self.state.activityFeed.append(.init(type: .removedFavoritePrime(self.state.count)))
})
…
Button(action: {
  self.state.favoritePrimes.append(self.state.count)
  self.state.activityFeed.append(.init(type: .addedFavoritePrime(self.state.count)))
})
```

즐겨찾기 추가, 삭제하는 부분에 activityFeed를 추가했습니다. 하지만 아직 심각한 버그가있습니다. 즐겨찾기 소수 목록 화면에서도 delete를 수행 할 수 있는것을 빠뜨렸습니다.

```swift
.onDelete(perform: { indexSet in
  for index in indexSet {
    self.state.favoritePrimes.remove(at: index)
  }
})
```

따라서 이 코드도 추가되어야합니다.



이것보다 더 좋은 방법으로는 AppState로 로직을 이동하는 것이 될 수 있습니다.

```swift
extension AppState {
  func addFavoritePrime() {
    self.favoritePrimes.append(self.count)
    self.activityFeed.append(Activity(timestamp: Date(), type: .addedFavoritePrime(self.count)))
  }

  func removeFavoritePrime(_ prime: Int) {
    self.favoritePrimes.removeAll(where: { $0 == prime })
    self.activityFeed.append(Activity(timestamp: Date(), type: .removedFavoritePrime(prime)))
  }

  func removeFavoritePrime() {
    self.removeFavoritePrime(self.count)
  }

  func removeFavoritePrimes(at indexSet: IndexSet) {
    for index in indexSet {
      self.removeFavoritePrime(self.favoritePrimes[index])
    }
  }
}
```

합리적인 방식으로 이를 관리하는 지침이 Apple의 SwiftUI에서 제공되고있지는 않으므로 이에 대해 고민이 필요합니다.



#### 사이드 이펙트

디바운싱을 위해 울프람알파 api 호출 클로저에 disable 로직을 추가했었지만 api가 중복호출되는것을 제대로 통제하는 방법을 SwiftUI에서 제공하지 않습니다. Combine 프레임워크를 사용해서 해결 할 수 있을 수 있지만 아직까지 이에대한 정보가 많이 없습니다.



#### 상태 관리는 컴포저블 하지 않다

마지막 문제점으로 앞에서 봐왔던 상태를 처리하기위한 코드들은 모듈식으로 프로그램을 쪼갤수 없게 만든다는점입니다.

예를 들어 `FavoritePrimes`뷰를 살펴 보겠습니다.

```swift
struct FavoritePrimes: View {
  @ObjectBinding var state: AppState
```

이 뷰는 `AppState` 전체 정보를 가져오지만 `favoritePrimes `배열만을 사용합니다. 우리가 원하는것은 뷰가 관심있는 데이터만 가지고 접근하는 것입니다.

그게 가능해져야 그 뷰를 Swift 패키지로 추출하여 다른 애플리케이션에서 사용할 수 있게 되고, 그것이 모듈 식 애플리케이션 설계의 최종 도착지입니다.

안타깝게도 SwiftUI에서 이런 설계를 하는법에대해 정리되지 않았습니다.

우리가 생각해낸 방법은 AppState를 감싸는 래퍼를 만드는것입니다.

```swift
struct FavoritePrimesState {
  var favoritePrimes: [Int]
  var activityFeed: [AppState.Activity]
}
extension AppState {
  var favoritePrimesState: FavoritePrimesState {
    get {
      FavoritePrimesState(
        favoritePrimes: self.favoritePrimes,
        activityFeed: self.activityFeed
      )
    }
    set {
      self.favoritePrimes = newValue.favoritePrimes
      self.activityFeed = newValue.activityFeed
    }
  }
}
```

이제 작동하는지 확인하기 위해 즐겨찾기 뷰의 객체 바인딩을 변경합니다.

```swift
struct FavoritePrimesView: View {
  @ObjectBinding var state: FavoritePrimesState
```

```swift
NavigationLink(destination: FavoritePrimesView(state: self.$state.favoritePrimesState))
```

하지만 최근에는 이런식으로도 바인딩을 전달 할 수도 있습니다.

```swift
struct FavoritePrimesView: View {
  @Binding var favoritePrimes: [Int]
  @Binding var activityFeed: [AppState.Activity]
```

잘 작동되면서 사용하지않는 글로벌 상태들을 잘라냈습니다. 하지만 boilerplate코드가 많이 있으며 아직까지 이를 모듈로 분리 할 방법이 없습니다. 하지만 이것이 지금까지는 뷰가 원하는것에만 관심을 가지는 가장 적절한 방법으로 보이며 앞으로 Swift가 제공 할 수도있으나 현제로서는 방법이 없습니다.



#### SwiftUI는 테스트가 불가능합니다.

현재로서 Apple이 SwiftUI 뷰 테스트를 하기위한 지침이나 도구를 제공하지않습니다. 즐겨찾기 추가 버튼을 누를때 카운트가 증가하는지, 실제로 추가되는지 와같은것을 테스트 할 간단한 방법이 없습니다.



#### 결론

해결해야 할 문제의 리스트입니다.

- How to manage and mutate state
- How to execute side effects
- How to decompose large applications into small ones, and
- How to test our application.

다음 시리즈부터 함수형 프로그래밍이 상태 관리하는것을 해볼것이고, 패키지로 통합하는 메커니즘을 만들 수 있음을 보여줄 것입니다. 이 방식의 좋은점은 SwiftUI에서만 사용 가능한게 아니라는 점입니다. UIKit에서도 잘 작동합니다.

**다음 시간에 계속 **


