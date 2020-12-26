# UserDefaultsSnapshot

This library enables us to create a snapshot of the values which UserDefaults manages.  
The snapshot means an immutable data model, that could be super effective to embed into the state of state-management.

<p>
<img alt="swift5.3" src="https://img.shields.io/badge/swift-5.3-ED523F.svg?style=flat"/>
<img alt="Tests" src="https://github.com/VergeGroup/UserDefaultsSnapshot/workflows/Tests/badge.svg"/>
<img alt="cocoapods" src="https://img.shields.io/cocoapods/v/UserDefaultsSnapshot" />
</p>


## Overview

### Creates a schema of the snapshot from UserDefaults

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

#### Attributes

* `Property` - A non optional value property, returns the initialized value if UserDefautls returns nil.
* `OptionalProperty` - A optional value property

<img width=400px src="https://user-images.githubusercontent.com/1888355/103155348-6a81bb00-47e2-11eb-9925-8002ecba0dd0.png" />

### Creates a persistent-store

```swift
let userDefaults = UserDefaults.init("your_userdefaults")!
let persistentStore = UserDefaultsPersistentStore<MyDefaults>(userDefaults: userDefaults)
```

### Writing the value over `UserDefaultsPersistentStore`

Thanks to creating a schema, we can modify the value with type-safely.  

```swift
persistentStore.write { d in
  d.name = "John"
}

XCTAssertEqual(userDefaults.string(forKey: "name"), "john") // ✅
```

## Reading the value from persitent-store

Using a snapshot to read the value which UserDefaults manages.  
And the snapshot reads the backing dictionary represented by UserDefaults creates.

Same as writing, thanks to creating a schema, we can read the value with type-safely.  

```swift
let snaphot: UserDefaultsSnapshot<MyDefaults> = persistentStore.makeSnapshot()

XCTAssertEqual(store.makeSnapshot().name, "John") // ✅
```

### Subscribing the snapshot each UserDefaults updates

`UserDefaultsPersistentStore` publishes new snapshot each receiving the notification that indicates UserDefaults changed.  
With this, it provides `sinkSnapshot` method.

```swift
let token = store.sinkSnapshot { snapshot in
  // Receives initial snapshot and every time UserDefaults updated.
}
```

### Integrating with Verge

[**Verge**](https://github.com/VergeGroup/Verge) is a state-management library.

A snapshot is a reference type, but it's an immutable data model.  
It can be embedded in the value type such as a state of something like a store in state-management.

```swift
struct MyState {

  // ✅ Embed a snapshot here.
  var defaults: UserDefaultsSnapshot<MyDefaults>
  
  // 💡 We can add any computed property to munipulate the value and provides.
  var localizedName: String {
    defaults.name + "+something"
  }
}

let persistentStore: UserDefaultsPersistentStore<MyDefaults>

let store: MyStore<MyState, Never> = .init(initialState: .init(defaults: persistentStore.makeSnapshot())

let token = store.sinkSnapshot { [weak store] snapshot in
  // ✅ Updates a snapshot every updates.
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

## Installations

Import a module with following installation methods.

```swift
import UserDefaultsSnapshotLib
```

**CocoaPods**

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:


```ruby
pod 'UserDefaultsSnapshotLib'
```

**SwiftPM**

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
  .package(url: "https://github.com/VergeGroup/UserDefaultsSnapshot.git", .upToNextMajor(from: "1.0.0"))
]
```

## Author

[🇯🇵 Muukii (Hiroshi Kimura)](https://github.com/muukii)

## License

UserDefaultsSnapshot is released under the MIT license.
