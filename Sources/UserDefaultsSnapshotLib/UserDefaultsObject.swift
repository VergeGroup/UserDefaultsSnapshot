/**
 Copyright 2020 Hiroshi Kimura

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

open class UserDefaultsObject: Hashable, @unchecked Sendable {

  public static func == (lhs: UserDefaultsObject, rhs: UserDefaultsObject) -> Bool {
    lhs === rhs
  }

  public func hash(into hasher: inout Hasher) {
    ObjectIdentifier(self).hash(into: &hasher)
  }

  public let storage: [String : Any]
  private(set) var modified: [String : Any] = [:]

  public required init(
    snapshot: [String : Any]
  ) {
    self.storage = snapshot
  }

  public func read<T: UserDefaultValueType>(type: T.Type? = nil, from key: String) -> T? {
    return (modified[key] as? T.PrimitiveValue).flatMap(T.fromPrimitiveValue(_:))
    ?? (storage[key] as? T.PrimitiveValue).flatMap(T.fromPrimitiveValue(_:))
  }

  /// non-atomic
  public func write<T: UserDefaultValueType>(value: T?, for key: String) {
    guard let value = value else {
      modified[key] = NSNull()
      return
    }
    modified[key] = value.toPrimitiveValue()
  }

}

extension UserDefaultsObject {

  @propertyWrapper
  public struct OptionalProperty<WrappedValue: UserDefaultValueType> {

    @available(*, unavailable)
    public var wrappedValue: WrappedValue? {
      get { fatalError() }
      set { fatalError() }
    }

    public let key: String

    public init(key: String) {
      self.key = key
    }

    public static subscript<Instance: UserDefaultsObject>(
      _enclosingInstance instance: Instance,
      wrapped wrappedKeyPath: KeyPath<Instance, WrappedValue?>,
      storage storageKeyPath: KeyPath<Instance, Self>
    ) -> WrappedValue? {
      get {
        let storage = instance[keyPath: storageKeyPath]
        return instance.read(type: WrappedValue.self, from: storage.key)
      }
      set {
        let storage = instance[keyPath: storageKeyPath]
        instance.write(value: newValue, for: storage.key)
      }
    }

  }

  @propertyWrapper
  public struct Property<WrappedValue: UserDefaultValueType> {

    @available(*, unavailable)
    public var wrappedValue: WrappedValue {
      get { fatalError() }
      set { fatalError() }
    }

    public let key: String
    public let defaultValue: WrappedValue

    public init(wrappedValue: WrappedValue, key: String) {
      self.key = key
      self.defaultValue = wrappedValue
    }

    public static subscript<Instance: UserDefaultsObject>(
      _enclosingInstance instance: Instance,
      wrapped wrappedKeyPath: KeyPath<Instance, WrappedValue>,
      storage storageKeyPath: KeyPath<Instance, Self>
    ) -> WrappedValue {
      get {
        let storage = instance[keyPath: storageKeyPath]
        return instance.read(type: WrappedValue.self, from: storage.key) ?? storage.defaultValue
      }
      set {
        let storage = instance[keyPath: storageKeyPath]
        instance.write(value: newValue, for: storage.key)
      }
    }

  }

}
