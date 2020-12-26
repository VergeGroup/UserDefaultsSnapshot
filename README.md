# UserDefaultsSnapshot

This library enables us to create a snapshot of the values which UserDefaults manages.  
The snapshot means an immutable data model, that could be super effective to embed into the state of state-management.

## Overview

**Creates a schema of the snapshot from UserDefaults**

This object is just a schema that projects the keys which the UserDefaults manages.  
So there are no namespaces, please carefully on naming the key.

```swift
final class MyDefaults: UserDefaultsObject {
  @Property(key: "count") var count = 0
  @OptionalProperty(key: "name") var name: String?
}
```

> 💎
As mention that above, this object is just a schema like a proxy to access UserDefaults (technically UserDefaults dictionary represented)  
The specified key would be used to read and write directly.  
This means we can start and stop using this library anytime!  
And no needs to projects all of the keys on UserDefaults.  
We only project the keys which we want to put on the snapshot.  
And we can create multiple schemas for each use-case.

### Attributes

* `Property` - A non optional value property, returns the initialized value if UserDefautls returns nil.
* `OptionalProperty` - A optional value property

<img width=400px src="https://user-images.githubusercontent.com/1888355/103155348-6a81bb00-47e2-11eb-9925-8002ecba0dd0.png" />

**Creates a persistent-store**

```swift
let userDefaults = UserDefaults.init("your_userdefaults")!
let persistentStore = UserDefaultsPersistentStore<MyDefaults>(userDefaults: userDefaults)
```

**Writing the value over `UserDefaultsPersistentStore`**

Thanks to creating a schema, we can modify the value with type-safely.  

```swift
persistentStore.write { d in
  d.name = "John"
}

XCTAssertEqual(userDefaults.string(forKey: "name"), "john") // ✅
```

**Reading the value from persitent-store**

Using a snapshot to read the value which UserDefaults manages.  
And the snapshot reads the backing dictionary represented by UserDefaults creates.

Same as writing, thanks to creating a schema, we can read the value with type-safely.  

```swift
let snaphot: UserDefaultsSnapshot<MyDefaults> = persistentStore.makeSnapshot()

XCTAssertEqual(store.makeSnapshot().name, "John") // ✅
```

**Subscribing the snapshot each UserDefaults updates**

`UserDefaultsPersistentStore` publishes new snapshot each receiving the notification that indicates UserDefaults changed.  
With this, it provides `sinkSnapshot` method.

```swift
let token = store.sinkSnapshot { snapshot in
  // Receives initial snapshot and every time UserDefaults updated.
}
```

**Integrating with Verge**

A snapshot is a reference type, but it's an immutable data model.  
It can be embedded in the value type such as a state of something like a store in state-management.

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
