# SwiftUI and State Management: Part 1

복잡한 프로젝트를 진행할때 생기는 문제를 이해하고 이를 해결하기위해 컴포저블 아키텍처에 대해 알아보고자 한다.



함수형 프로그래밍을 통해 복잡한 프로그램을 다뤄보기전에, 적당한 프로그램을 만들어보면서 어떤 문제가 발생하는지 우선 확인해보자.



 SwiftUI에서 진행되지만 이 문제는 UIKit에서도 동일하게 적용가능하다. SwiftUI를 선택한 이유는 Apple이 SwiftUI에서 앱 설계 방식에대해 더 많이 관심가지고있기 때문입니다. (?)



SwiftUI에 대해 많은 내용을 알아보지는 않을것입니다. 컴포저블 아키텍처를 설명하는데 필요한 만큼만 확인할것입니다.



@State 와 같은 구문을 보게 될건데 이와같은것은 **property wrapper** 라고 하고 종류가 몇가지 더 있다.

> - **property wrapper**
> 
> **propertyDelegate**와 동일한 것이지만 **property wrapper**라고 이름이 확정 되었다고 한다.
> 
> (https://github.com/dev-yong/SwiftUI-Landmark-MVVM/wiki/propertyWrapper)
> 
> 
> 
> propertyWrapper 정의하는 쉬운 예제 - https://wlaxhrl.tistory.com/90
> 
> propertyWrapper 모음 라이브러리 - https://github.com/guillermomuntaner/Burritos
> 
> 
> 
> 간단하게 get, set 연산 프로퍼티의 동작을 미리 정의해두고 @프로퍼티래퍼 를 사용해서 한번에 적용할 수 있다.
> 
> 프로퍼티의 초기화에 대한 동작을 제한할 수 있다. (init)
> 
> **projectedValue** 라는것을 구현하면 프로퍼티에서 $를 사용해서 해당 값에 접근할수 있는데 이를 활용하면 해당 프로퍼티에서 추가적인 정보를 제공 할 수 있다.
> 
> @State에서도 $를 사용한다!
> 
> 정리하자면 짧은 코드로 프로퍼티를 더 편하게 사용하기위한 녀석



@State는 로컬 화면에 대해서만 값이 유지된다. 우리가 메인화면으로 나가서 다른화면을 탐색해도 값이 계속 유지되게하려면 더 글로벌한 영역에 값을 저장해야 합니다. 이는 @ObservedObject를 사용하여 예제를 진행하게됩니다.



`var  body: some  View`에서 some은 어떤것일까?

> - Opaque Type - some
> 
> Generic 타입의 반대되는 개념으로 생각할 수 있다.
> 
> 우선 Generic Type은 호출하는 코드에서 타입을 결정해주고, 실제로 구현하는곳에서는 추상화된 타입을 사용한다. 그래서 구현부 외부에서 타입을 바로 알 수 있다.
> 
> 
> 
> Opaque Type은 구현부에서 타입이 선택된다.
> 
> 
> 
> Opaque Type은 Type Identity를 보존하기때문에 특정 유형임을 나타낼 수 있다(?) - 아직 잘 모르겠다.
> 
> ```swift
> example("Opaque type is preserve type identity") {
>  func someEquatable() -> some Equatable {
>  return String()
>  }
> }
> example("Protocol type isn't preserve type identity") {
> // func equatable() -> Equatable {
> // return String()
> // }
> }
> ```
> 
> - 참고자료
> 
> [https://github.com/dev-yong/SwiftUI_Playground](https://github.com/dev-yong/SwiftUI_Playground)
> 
> [https://jcsoohwancho.github.io/2019-08-24-Opaque-Type-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0/](https://jcsoohwancho.github.io/2019-08-24-Opaque-Type-%EC%82%B4%ED%8E%B4%EB%B3%B4%EA%B8%B0/)
> 
> http://minsone.github.io/programming/swift-opaque-type-and-erase-type
> 
> 






