import ComposableArchiteture
import FavoritePrimes
import SwiftUI
import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  rootView: FavoritePrimesView(
    store: Store<[Int], FavoritePrimesAction>(
      initialValue: [2, 3, 5, 7, 11],
      reducer: favoritePrimesReducer
    )
  )
)
