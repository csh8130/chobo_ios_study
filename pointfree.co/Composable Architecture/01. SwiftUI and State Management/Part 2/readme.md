# SwiftUI and State Management: Part 2

```swift
class AppState: ObservableObject {
    var count: Int = 0 {
        willSet {
            self.objectWillChange.send()
        }
    }
}
```

이전장에서 ObservableObject를 구현할 때 willSet에서 ping을 해줘야만 값이 세팅되는것이 전달되었다.

`self.objectWillChange.send()`구문을 지워보면 원하는데로 작동되지 않는것을 확인 할 수 있다.

```swift
class AppState: ObservableObject {
 @Published var count: Int = 0 {
 }
}
```

@Published 프로퍼티 레퍼를 사용하는것으로 간단하게 구현이 가능하다.

배열을 순회하며 View를 추가하기위해 ForEach를 사용했다.

```swift
    List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }.onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
```



ForEach안에 `id: .self`는 왜 필요한것인지 아직 잘 모르겠다.

설명되어있는것 같은 페이지 : https://www.hackingwithswift.com/books/ios-swiftui/why-does-self-work-for-foreach

List에 들어가는 뷰들은 무조건 서로를 구분할수 있는 id가 필요한듯하고 .self를 사용하면 각자 자신의 hash값을 (hashable 프로토콜을 구현하지않으면 애러) id로 사용하는것 같다.
