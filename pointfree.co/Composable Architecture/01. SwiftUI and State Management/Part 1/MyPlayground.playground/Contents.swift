import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView()) {
          Text("Counter demo")
        }
        NavigationLink(destination: EmptyView()) {
          Text("Favorite primes")
        }
      }
        .navigationBarTitle("State management")
    }
  }
}

struct CounterView: View {
  var body: some View {
    VStack {
      HStack {
        Button(action: {}) {
          Text("-")
        }
        Text("0")
        Button(action: {}) {
          Text("+")
        }
      }
      Button(action: {}) {
        Text("Is this prime?")
      }
      Button(action: {}) {
        Text("What is the 0th prime?")
      }
    }
    .font(.title)
    .navigationBarTitle("Counter demo")
  }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  rootView: ContentView()
//  rootView: CounterView()
)
