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
