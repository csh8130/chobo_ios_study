# SwiftUI and State Management: Part 3

Part1, 2에서 만든 프로그램을 가지고 문제점을 알아보자.



##### 앞서 살펴본 SwiftUI 장점

- UI를 표현하기위해 단일 진입 점으로 `body` 만 사용하는것은 기존에 UIKit을 사용할 때 보다 훌륭하다. 뷰를 선언적 프로그래밍으로 만들 수 있다.

- 로컬 상태를 관리하는 도구가 제공된다. `@State` 이 값이 변경되면 화면을 렌더링 할 수 있게하는 바인딩 가능한 값을 제공합니다.

- 로컬 상태관리로 충분하지 않은 경우 `@ObjectBinding` 을 사용하여 여러 뷰가 동일한 데이터를 공유할 수 있도록 할 수 있습니다.

- SwiftUI는 View를 위한 `struct`를 만들고 `body`에 뷰를 정의 하는것, 그리고 뷰를 동적으로 업데이트하기위해 상태를 만드는것 이것 외에 다른 방법을 제공하지 않습니다.
  
  - 기존의 UIKit에서 UIView와 UIViewController가 역할을 분리하지 못했다. 그리고 상태 를 업데이트하는 방법에 일관성이 없었다. (notification, KVO, delegate, action, callback)

##### 번거로운 점

크고 복잡한 애플리케이션을 만들때 SwiftUI가 우리를 위해 해주지않는 점이 있습니다. 이것에 대해 이야기 해 봅시다.

AppState 클래스를 BindableObject로 만들고 passthrough subject에 연결하는것은 쉬웠지만 확장 가능한 상황은 아닙니다.

지금은 속성이 두 개 뿐이지만 상태 클래스는 쉽게 수십개의 속성이 추가 될 수 있으며 여러개의 상태 subclass를 가질 수 있습니다.




