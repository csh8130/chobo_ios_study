import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: CounterView(store: self.store)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: FavoritePrimesView(store: self.store)) {
                  Text("Favorite primes")
                }
            }
            .navigationBarTitle("State management")
        }
    }
}

//class AppState: ObservableObject {
//    @Published var count: Int = 0
//    @Published var favoritePrimes: [Int] = []
//    @Published var loggedInUser: User?
//    @Published var activityFeed: [Activity] = []
//
//    struct Activity {
//      let timestamp: Date
//      let type: ActivityType
//
//      enum ActivityType {
//        case addedFavoritePrime(Int)
//        case removedFavoritePrime(Int)
//      }
//    }
//
//    struct User {
//      let id: Int
//      let name: String
//      let bio: String
//    }
//}
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

final class Store<Value, Action>: ObservableObject {
    @Published var value: Value
    let reducer: (inout Value, Action) -> Void
    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
      self.value = initialValue
      self.reducer = reducer
    }
    
    func send(_ action: Action) {
      self.reducer(&self.value, action)
    }
}

enum CounterAction {
    case decrTapped
    case incrTapped
}
enum PrimeModalAction {
    case saveFavoritePrimeTapped
    case removeFavoritePrimeTapped
}
enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
}
enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)
}


func appReducer(value: inout AppState, action: AppAction) -> Void {
    switch action {
    case .counter(.decrTapped):
        value.count -= 1
    case .counter(.incrTapped):
        value.count += 1
    case .primeModal(.saveFavoritePrimeTapped):
        value.favoritePrimes.append(value.count)
        value.activityFeed.append(.init( type: .addedFavoritePrime(value.count)))
    case .primeModal(.removeFavoritePrimeTapped):
        value.favoritePrimes.removeAll(where: { $0 == value.count })
        value.activityFeed.append(.init( type: .removedFavoritePrime(value.count)))
    case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
        for index in indexSet {
            let prime = value.favoritePrimes[index]
            value.favoritePrimes.remove(at: index)
            value.activityFeed.append(.init(type: .removedFavoritePrime(prime)))
        }
    }
}

struct CounterView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false
    
    var body: some View {
        VStack {
            HStack {
                Button("-") { self.store.send(.counter(.decrTapped)) }
                Text("\(self.store.value.count)")
                Button("+") { self.store.send(.counter(.incrTapped)) }
            }
            Button(action: { self.isPrimeModalShown = true }) {
                Text("Is this prime?")
            }
            Button(action: nthPrimeButtonAction) {
              Text("What's the \(ordinal(self.store.value.count)) prime?")
            }
            .disabled(isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: $isPrimeModalShown) {
            IsPrimeModalView(store: self.store)
        }
        .alert(item: self.$alertNthPrime) { alert in
          Alert(
            title: Text("The \(ordinal(self.store.value.count)) prime is \(alert.prime)"),
            dismissButton: .default(Text("Ok"))
          )
        }
    }
    
    private func ordinal(_ n: Int) -> String {
      let formatter = NumberFormatter()
      formatter.numberStyle = .ordinal
      return formatter.string(for: n) ?? ""
    }
    
    func nthPrimeButtonAction() {
        self.isNthPrimeButtonDisabled = true
        nthPrime(self.store.value.count) { prime in
            self.alertNthPrime = prime.map{PrimeAlert(prime: $0)}
            self.isNthPrimeButtonDisabled = false
        }
    }
}

struct IsPrimeModalView: View {
  @ObservedObject var store: Store<AppState, AppAction>
  var body: some View {
    VStack {
      if isPrime(self.store.value.count) {
        Text("\(self.store.value.count) is prime 🎉")
        if self.store.value.favoritePrimes.contains(self.store.value.count) {
          Button("Remove from favorite primes") {
            self.store.send(.primeModal(.removeFavoritePrimeTapped))
          }
        } else {
          Button("Save to favorite primes") {
            self.store.send(.primeModal(.saveFavoritePrimeTapped))
          }
        }
      } else {
        Text("\(self.store.value.count) is not prime :(")
      }
    }
  }
}

struct FavoritePrimesState {
  var favoritePrimes: [Int]
  var activityFeed: [AppState.Activity]
}

struct FavoritePrimesView: View {
  @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        List {
            ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }.onDelete { indexSet in
             self.store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
    }
    
}

private func isPrime (_ p: Int) -> Bool {
  if p <= 1 { return false }
  if p <= 3 { return true }
  for i in 2...Int(sqrtf(Float(p))) {
    if p % i == 0 { return false }
  }
  return true
}

struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    let wolframAlphaApiKey = "6H69Q3-828TKQJ4EP"
  var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey),
  ]

  URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
    callback(
      data
        .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
    )
    }
    .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
  wolframAlpha(query: "prime \(n)") { result in
    callback(
      result
        .flatMap {
          $0.queryresult
            .pods
            .first(where: { $0.primary == .some(true) })?
            .subpods
            .first?
            .plaintext
      }
      .flatMap(Int.init)
    )
  }
}

struct PrimeAlert: Identifiable {
  let prime: Int

  var id: Int { self.prime }
}

//nthPrime(10000) {
//    print($0)
//}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
    rootView: ContentView(store: Store(initialValue: AppState(), reducer: appReducer))
)
