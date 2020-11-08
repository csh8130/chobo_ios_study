import ComposableArchiteture

let store = Store<Int, Void>(initialValue: 0,
 reducer: { count, _ in count += 1 })
store.send(())
store.send(())
store.send(())
store.send(())
store.send(())
store.value // 5

let newStore = store.map { $0 }
newStore.value // 5

newStore.send(())
newStore.send(())
newStore.send(())
newStore.value // 8

store.value // 8
