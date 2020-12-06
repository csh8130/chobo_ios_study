import SwiftUI
import Combine

public typealias Reducer<Value, Action> = (inout Value, Action) -> Void

public final class Store<Value, Action>: ObservableObject {
    @Published public private(set) var value: Value
    private var cancellable: Cancellable?
    
    let reducer: Reducer<Value, Action>
    public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
      self.value = initialValue
      self.reducer = reducer
    }
    
    public func send(_ action: Action) {
      self.reducer(&self.value, action)
    }
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction> {
        let localStore = Store<LocalValue, LocalAction>(
            initialValue: toLocalValue(self.value),
            reducer: { localValue, localAction in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
            }
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {

  return { value, action in
    for reducer in reducers {
      reducer(&value, action)
    }
  }
}

public func pullback<GlobalValue, LocalValue, GlobalAction, LocalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {

  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return }
    reducer(&globalValue[keyPath: value], localAction)
  }
}

public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    reducer(&value, action)
    print("Action: \(action)")
    print("State:")
    dump(value)
    print("---")
  }
}
