//
//  ContentView.swift
//  project
//
//  Created by Choi SeungHyuk on 2020/11/02.
//

import SwiftUI
import ComposableArchiteture
import FavoritePrimes
import Counter
import PrimeModal

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(
                        store: self.store.view(
                            value: { ($0.count, $0.favoritePrimes) },
                            action: {
                                switch $0 {
                                case let .counter(action):
                                    return AppAction.counter(action)
                                case let .primeModal(action):
                                    return AppAction.primeModal(action)
                                }
                            }
                        )
                    )
                )
                NavigationLink(
                  "Favorite primes",
                  destination: FavoritePrimesView(
                    store: self.store.view { $0.favoritePrimes } action: { .favoritePrimes($0) }
                  )
                )
            }
            .navigationBarTitle("State management")
        }
    }
}

struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var activityFeed: [Activity] = []
  var loggedInUser: User? = nil

  struct Activity {
    let type: ActivityType
    let timestamp = Date()

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

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

enum AppAction {
  case counter(CounterAction)
  case primeModal(PrimeModalAction)
  case favoritePrimes(FavoritePrimesAction)

    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }
    
    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
        }
    }
    
    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}

func activityFeed(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {

  return { state, action in
    switch action {
    case .counter:
      break

    case .primeModal(.removeFavoritePrimeTapped):
      state.activityFeed.append(
        .init(type: .removedFavoritePrime(state.count))
      )

    case .primeModal(.saveFavoritePrimeTapped):
      state.activityFeed.append(
        .init(type: .addedFavoritePrime(state.count))
      )

    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
      for index in indexSet {
        state.activityFeed.append(
          .init(type: .removedFavoritePrime(state.favoritePrimes[index]))
        )
      }
    }
    reducer(&state, action)
  }
}

struct _KeyPath<Root, Value> {
  let get: (Root) -> Value
  let set: (inout Root, Value) -> Void
}

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)
