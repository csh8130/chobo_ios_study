import ComposableArchiteture
import FavoritePrimes
import SwiftUI
import PlaygroundSupport
import PrimeModal
import Counter

PlaygroundPage.current.liveView = UIHostingController(
  rootView: CounterView(
    store: Store<CounterViewState, CounterViewAction>(
      initialValue: (1_000_000, []),
      reducer: counterViewReducer
    )
  )
)
