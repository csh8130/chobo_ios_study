//
//  CounterView.swift
//  project
//
//  Created by Choi SeungHyuk on 2021/03/06.
//

import SwiftUI

private func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    @State var alertNthPrime: Int?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { self.state.count -= 1 }) {
                    Text("-")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1 }) {
                    Text("+")
                }
            }
            Button(action: { self.isPrimeModalShown = true }) {
                Text("Is this prime?")
                    
            }
            Button(action: {
                nthPrime(self.state.count) { prime in
                    self.alertNthPrime = prime
                  }
            }) {
                Text("What's the \(ordinal(self.state.count)) prime?")
            }
        }
        .font(.title)
        .navigationBarTitle("Counter demo")
        .sheet(isPresented: self.$isPrimeModalShown) {
            IsPrimeModalView(state: self.state)
        }
//        .alert(item: self.$alertNthPrime) { alert in
//            Alert(
//                title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
//                dismissButton: .default(Text("Ok"))
//            )
//        }
    }
}
