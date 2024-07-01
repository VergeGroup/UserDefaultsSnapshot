/**
 Copyright 2020 Hiroshi Kimura

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

open class UserDefaultsPersistentStore<Schema: UserDefaultsObject>: UserDefaultsPersistentStoreBase, @unchecked Sendable {

  public let userDefaults: UserDefaults

  private let lock = NSRecursiveLock()

  public init(userDefaults: UserDefaults) {
    self.userDefaults = userDefaults

    super.init()

    NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: userDefaults, queue: nil) { [weak self] _ in

      self?.subscribers.forEach { $0.value() }

    }
  }

  public func removeAllValues() {
    lock.lock(); defer { lock.unlock() }
    userDefaults.dictionaryRepresentation().forEach { key, _ in
      userDefaults.removeObject(forKey: key)
    }
  }

  public final func makeSnapshot() -> UserDefaultsSnapshot<Schema> {
    lock.lock(); defer { lock.unlock() }
    return .init(
      wrapped: Schema.init(
        snapshot: userDefaults.dictionaryRepresentation()
      )
    )
  }

  public final func write(write: (borrowing Schema) throws -> Void) rethrows {
    lock.lock(); defer { lock.unlock() }
    let object = Schema(snapshot: userDefaults.dictionaryRepresentation())
    do {
      try write(object)
      userDefaults.setValuesForKeys(object.modified)
    } catch {
      throw error
    }
  }

  public final func sinkSnapshot(_ sink: @escaping @Sendable (UserDefaultsSnapshot<Schema>) -> Void) -> UserDefaultsPersistentStoreSinkCancellable {

    // deliver initial
    do {
      let snapshot = makeSnapshot()

      sink(
        snapshot
      )
    }

    return add { [weak self] in
      guard let self = self else { return }

      let snapshot = self.makeSnapshot()

      sink(
        snapshot
      )
    }

  }

  public final func sinkSnapshotOnMain(_ sink: @escaping @MainActor (UserDefaultsSnapshot<Schema>) -> Void) -> UserDefaultsPersistentStoreSinkCancellable {

    // deliver initial
    do {
      let snapshot = makeSnapshot()

      if Thread.isMainThread {
        MainActor.assumeIsolated {
          sink(
            snapshot
          )
        }
      } else {
        Task { @MainActor in
          sink(
            snapshot
          )
        }
      }
    }

    return add { [weak self] in
      guard let self = self else { return }

      let snapshot = self.makeSnapshot()

      Task { @MainActor in
        sink(
          snapshot
        )
      }
    }

  }

}

