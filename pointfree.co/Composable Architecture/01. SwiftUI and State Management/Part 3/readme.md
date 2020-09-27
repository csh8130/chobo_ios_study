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



앱에 두가지 새로운 기능을 추가해서 이를 확인 해 보겠습니다.
