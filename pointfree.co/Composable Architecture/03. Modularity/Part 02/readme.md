# Modular State Management: View State

 리듀서는 모듈식으로 별도의 프레임워크로 추출하는데 성공했지만 View는 여전히 모듈식과는 거리가 있습니다. 해당 문제를 해결 해 보겠습니다.

 앞서 컴포저블 아키텍처가 얼마나 모듈화를 고려했는지 알 수 있었던 점으로 리듀서를 별도의 모듈로 추출하는데 리펙터링이나 코드 수정이 필요하지 않았습니다. 최악의 경우 추가 boilerplate 코드가 필요한 정도였을 뿐입니다.

### Modularizing our views

 모든 뷰는 모든 앱 상태(State)에 액세스 할 수 있고, 액션(Action)도 보낼 수 있습니다. 이는 모두 AppState와 AppAction을 통해 일반화된 Store를 보유하고 있기 때문입니다. 이러한 중앙 집중식 Store를 보고서 한눈에 어떤 정보에 접근하고 어떤 변이를 일으키는지 알 방법이 없습니다.

 예를 들어, `FavoritePrimesView` 는 favoritePrimes 배열과 deleteFavoritePrimes 액션에만 액세스 하면 되지만 지금은 모든 항목에 액세스가 가능합니다.

 이것은 글로벌 State와 Action이 유출되는걸 막을 수 없다는 의미입니다.


