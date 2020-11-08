import SwiftUI
import Combine

public final class Store<Value, Action>: ObservableObject {
    @Published public private(set) var value: Value
    let reducer: (inout Value, Action) -> Void
    public init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
      self.value = initialValue
      self.reducer = reducer
    }
    
    public func send(_ action: Action) {
      self.reducer(&self.value, action)
    }
    
    public func map<LocalValue>(
        _ f: @escaping (Value) -> LocalValue
    ) -> Store<LocalValue, Action> {
        return Store<LocalValue, Action>(
            initialValue: f(self.value),
            reducer: { localValue, action in
                self.send(action)
                localValue = f(self.value)
            }
        )
    }
}

public func combine<Value, Action>(
  _ reducers: (inout Value, Action) -> Void...
) -> (inout Value, Action) -> Void {

  return { value, action in
    for reducer in reducers {
      reducer(&value, action)
    }
  }
}

public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
  _ reducer: @escaping (inout LocalValue, LocalAction) -> Void,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> (inout GlobalValue, GlobalAction) -> Void {

  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return }
    reducer(&globalValue[keyPath: value], localAction)
  }
}

public func logging<Value, Action>(
  _ reducer: @escaping (inout Value, Action) -> Void
) -> (inout Value, Action) -> Void {
  return { value, action in
    reducer(&value, action)
    print("Action: \(action)")
    print("State:")
    dump(value)
    print("---")
  }
}
