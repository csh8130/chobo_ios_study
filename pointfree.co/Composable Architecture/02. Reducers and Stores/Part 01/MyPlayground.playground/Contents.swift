import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store<AppState>
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

final class Store<Value>: ObservableObject {
    @Published var value: Value
    init(initialValue: Value) {
        self.value = initialValue
    }
}

struct CounterView: View {
    @ObservedObject var store: Store<AppState>
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: PrimeAlert?
    @State var isNthPrimeButtonDisabled = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.store.value.count -= 1 }) {
                  Text("-")
                }
                Text("\(self.store.value.count)")
                Button(action: { self.store.value.count += 1 }) {
                  Text("+")
                }
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
  @ObservedObject var store: Store<AppState>
  var body: some View {
    VStack {
      if isPrime(self.store.value.count) {
        Text("\(self.store.value.count) is prime 🎉")
        if self.store.value.favoritePrimes.contains(self.store.value.count) {
          Button(action: { self.store.value.favoritePrimes.removeAll(where: { $0 == self.store.value.count })
          }) {
            Text("Remove from favorite primes")
          }
        } else {
          Button(action: { self.store.value.favoritePrimes.append(self.store.value.count)
          }) {
            Text("Save to favorite primes")
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
  @ObservedObject var store: Store<AppState>

    var body: some View {
        List {
            ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }.onDelete { indexSet in
                for index in indexSet {
                    self.store.value.favoritePrimes.remove(at: index)
                }
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
    rootView: ContentView(store: Store(initialValue: AppState()))
)
