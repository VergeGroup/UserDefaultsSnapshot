# UserDefaultsSnapshot

This library enables us to create a snapshot of the values which UserDefaults manages.  
The snapshot means an immutable data model, that could be super effective to embed into the state of state-management.

## Overview

**Creates a schema of the snapshot from UserDefaults**

```swift
final class MyDefaults: UserDefaultsObject {
  @Property(key: "count") var count = 0
  @OptionalProperty(key: "name") var name: String?
}
```

**Reading and Writing the value over `UserDefaultsPersistentStore`**

```swift
let userDefaults = UserDefaults.init("your_userdefaults")!

let persistentStore = UserDefaultsPersistentStore<MyDefaults>(userDefaults: userDefaults)

// Writing
persistentStore.write { d in
  d.name = "John"
}

// Reading
let snaphot: UserDefaultsSnapshot<MyDefaults> = persistentStore.makeSnapshot()

XCTAssertEqual(store.makeSnapshot().name, "John") // ✅
XCTAssertEqual(userDefaults.string(forKey: "name"), "john") // ✅
```

**Subscribing the snapshot each UserDefaults updates**

```swift
let token = store.sinkSnapshot { snapshot in
  // Receives initial snapshot and every time UserDefaults updated.
}
```

**Integrating with Verge**
```swift
struct MyState {
  var defaults: UserDefaultsSnapshot<MyDefaults>
  
  var localizedName: String {
    defaults.name + "+something"
  }
}

let persistentStore: UserDefaultsPersistentStore<MyDefaults>

let store: MyStore<MyState, Never> = .init(initialState: .init(defaults: persistentStore.makeSnapshot())

let token = store.sinkSnapshot { [weak store] snapshot in
  store?.commit {
    $0.defaults = snapshot
  }  
}
```

Use store
```swift
let store: MyStore<MyState, Never>

store.sinkState { state in 

  state.ifChanged(\.localizedName) { value in 
    print(value) // "John+something"
  }
  
}

```
