public struct Effect<A> {
  public let run: (@escaping (A) -> Void) -> Void

  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    return Effect<B> { callback in self.run { a in callback(f(a)) } }
  }
}

import Dispatch

//let anIntInTwoSeconds = Effect<Int>(run: { callback in
//    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//      callback(42)
//    }
//  })

//anIntInTwoSeconds.run { int in print(int) }
// 42
//anIntInTwoSeconds.map { $0 * $0 }.run { int in print(int) }
// 1764

import Combine

//let aFutureInt = Future<Int, Never> { callback in
//  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//    callback(.success(42))
//  }
//}


//aFutureInt.subscribe(
//  AnySubscriber<Int, Never>(
//    receiveSubscription: { subscription in
//      print("subscription")
//      subscription.request(.unlimited)
//  },
//    receiveValue: { value in
//      print("value", value)
//      return .unlimited
//  },
//    receiveCompletion: { completion in
//      print("completion", completion)
//  })
//)


//let cancellable = aFutureInt.sink { int
//  in print(int)
//}
//cancellable.cancel()

//let aFutureInt = Future<Int, Never> { callback in
//  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//    print("Hello from inside the future!")
//    callback(.success(42))
//  }
//}

//let cancellable = aFutureInt.sink { int in
//  print(int)
//}

//let passthrough = PassthroughSubject<Int, Never>()
//let currentValue = CurrentValueSubject<Int, Never>(1)
//
//let c1 = passthrough.sink { x in print("passthrough", x) }
//let c2 = currentValue.sink { x in print("currentValue", x) }
//
//passthrough.send(42)
//currentValue.send(1729)
//passthrough.send(42)
//currentValue.send(1729)

// excercise

//class Effect<A> {
//  var callbacks: [(A) -> Void] = []
//  var value: A?
//
//  init(run: @escaping (@escaping (A) -> Void) -> Void) {
//    run { value in
//      self.callbacks.forEach { callback in callback(value) }
//      self.value = value
//    }
//  }
//
//  func run(_ callback: @escaping (A) -> Void) {
//    if let value = self.value {
//      callback(value)
//    }
//    self.callbacks.append(callback)
//  }
//}

let anIntInTwoSeconds = Effect<Int>(run: { callback in
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        print("testing")
      callback(42)
    }
  })

anIntInTwoSeconds.run { int in print(int) }
