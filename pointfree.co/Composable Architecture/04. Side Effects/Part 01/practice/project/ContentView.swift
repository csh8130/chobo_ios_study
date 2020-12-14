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
//import PrimeModal

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    "Counter demo",
                    destination: CounterView(
                        store: self.store.view(
                            value: { $0.counterView },
                            action: { .counterView($0) }
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

enum AppAction {
//  case counter(CounterAction)
//  case primeModal(PrimeModalAction)
    case counterView(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)

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
    
    var counterView: CounterViewAction? {
      get {
        guard case let .counterView(value) = self else { return nil }
        return value
      }
      set {
        guard case .counterView = self, let newValue = newValue else { return }
        self = .counterView(newValue)
      }
    }
}

func activityFeed(
  _ reducer: @escaping (inout AppState, AppAction) -> Void
) -> (inout AppState, AppAction) -> Void {

  return { state, action in
    switch action {
    case .counterView(.counter), .favoritePrimes(.loadedFavoritePrimes):
      break

    case .counterView(.primeModal(.removeFavoritePrimeTapped)):
      state.activityFeed.append(
        .init(type: .removedFavoritePrime(state.count))
      )

    case .counterView(.primeModal(.saveFavoritePrimeTapped)):
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

extension AppState {
    var counterView: CounterViewState {
        get {
            CounterViewState(
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

let _appReducer: (inout AppState, AppAction) -> Void = combine(
    pullback(counterViewReducer, value: \.counterView, action: \.counterView),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = pullback(_appReducer, value: \.self, action: \.self)
