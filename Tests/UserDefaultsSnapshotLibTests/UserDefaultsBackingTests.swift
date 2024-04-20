@testable import UserDefaultsSnapshotLib
import XCTest

extension String: Error {}

final class UserDefaultsBackingTests: XCTestCase {
  final class MyDefaults: UserDefaultsObject {
    @Property(key: "a") var count = 0
    @OptionalProperty(key: "b") var name: String?
  }

  func testRead() {
    do {
      let d = MyDefaults(snapshot: ["a": 3, "b": "hello"])

      XCTAssertEqual(d.count, 3)
      XCTAssertEqual(d.name, "hello")
    }

    do {
      let d = MyDefaults(
        snapshot: [
          "a": Int?.none as Any,
          "b": String?.none as Any,
        ]
      )

      XCTAssertEqual(d.count, 0)
      XCTAssertEqual(d.name, nil)
    }
  }

  func testWrite() {
    let userDefaults = UserDefaults.init(suiteName: UUID().debugDescription)!

    let store = UserDefaultsPersistentStore<MyDefaults>(userDefaults: userDefaults)

    store.write { d in
      d.name = "muukii"
    }

    XCTAssertEqual(store.makeSnapshot().name, "muukii")
    XCTAssertEqual(userDefaults.string(forKey: "b"), "muukii")

    store.write { d in
      d.name = nil
    }

    XCTAssertEqual(store.makeSnapshot().name, nil)
    XCTAssertEqual(userDefaults.string(forKey: "b"), nil)

    do {
      try store.write { d in
        d.name = "revert"
        throw "error!"
      }
    } catch {
      print(error)
    }

    XCTAssertEqual(store.makeSnapshot().name, nil)
    XCTAssertEqual(userDefaults.string(forKey: "b"), nil)
  }

  func testSink() {
    let exp = expectation(description: "wait")

    let store = UserDefaultsPersistentStore<MyDefaults>(
      userDefaults: UserDefaults
        .init(suiteName: UUID().debugDescription)!
    )

    let token = store.sinkSnapshot { snap in

      XCTAssertEqual(snap.count, 0)
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1)

    withExtendedLifetime(token) {}
  }

  func testSinkUpdate() async {

    actor Storage {
      var results: [Int] = []
      var snapshots: [UserDefaultsSnapshot<UserDefaultsBackingTests.MyDefaults>] = []

      func perform(_ closure: @escaping (isolated Storage) -> ()) {
        closure(self)
      }
    }

    let exp = expectation(description: "wait")
    exp.expectedFulfillmentCount = 3

    let storage = Storage()

    let store = UserDefaultsPersistentStore<MyDefaults>(
      userDefaults: UserDefaults
        .init(suiteName: UUID().debugDescription)!
    )

    // Start:

    let token = store.sinkSnapshot { snap in

      Task {
        await storage.perform {
          $0.results.append(snap.count)
          $0.snapshots.append(snap)
        }
        exp.fulfill()
      }

    }

    store.write { d in
      d.count = 1
    }

    store.write { d in
      d.count = 2
    }

    wait(for: [exp], timeout: 1)

    let _results = await storage.results
    let _snapshots = await storage.snapshots

    XCTAssertEqual(_results, [0, 1, 2])

    XCTAssertEqual(_snapshots.map { $0.count }, [0, 1, 2])

    withExtendedLifetime(token) {}
  }
}


