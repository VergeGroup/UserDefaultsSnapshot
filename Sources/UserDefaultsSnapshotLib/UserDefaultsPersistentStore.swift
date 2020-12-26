/**
 Copyright 2020 Hiroshi Kimura

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

public final class UserDefaultsPersistentStore<Schema: UserDefaultsObject>: UserDefaultsPersistentStoreBase {

  public let userDefaults: UserDefaults

  private let lock = NSRecursiveLock()

  public init(userDefaults: UserDefaults) {
    self.userDefaults = userDefaults

    super.init()

    NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: userDefaults, queue: nil) { [weak self] _ in

      self?.subscribers.forEach { $0.value() }

    }
  }

  public func makeSnapshot() -> UserDefaultsSnapshot<Schema> {
    lock.lock(); defer { lock.unlock() }
    return .init(
      wrapped: Schema.init(
        snapshot: userDefaults.dictionaryRepresentation()
      )
    )
  }

  public func write(write: (Schema) throws -> Void) rethrows {
    lock.lock(); defer { lock.unlock() }
    let object = Schema(snapshot: userDefaults.dictionaryRepresentation())
    do {
      try write(object)
      userDefaults.setValuesForKeys(object.modified)
    } catch {
      throw error
    }
  }

  public func sinkSnapshot(_ sink: @escaping (UserDefaultsSnapshot<Schema>) -> Void) -> UserDefaultsPersistentStoreSinkCancellable {

    let token = UserDefaultsPersistentStoreSinkCancellable(owner: self)

    initial: do {
      let snapshot = makeSnapshot()

      sink(
        snapshot
      )
    }

    add { [weak self] in
      guard let self = self else { return }

      let snapshot = self.makeSnapshot()

      DispatchQueue.main.async {
        sink(
          snapshot
        )
      }
    }

    return token

  }

}

