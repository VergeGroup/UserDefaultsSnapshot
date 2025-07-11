@testable import UserDefaultsSnapshotLib
import XCTest

extension String: Error {}

struct ISO8601Date: UserDefaultValueType, Equatable {
  let date: Date

  typealias PrimitiveValue = String

  static func fromPrimitiveValue(_ value: String) -> Self? {
    return ISO8601DateFormatter().date(from: value)
      .map(Self.init(date:))
  }

  func toPrimitiveValue() -> String {
    return ISO8601DateFormatter().string(from: date)
  }
}



final class UserDefaultsBackingTests: XCTestCase {
  final class MyDefaults: UserDefaultsObject {
    @Property(key: "a") var count = 0
    @OptionalProperty(key: "b") var name: String?
    @OptionalProperty(key: "c") var date: ISO8601Date?
  }

  func testRead() {
    let dateString: String = ISO8601DateFormatter().string(from: .now)
    let date: Date = ISO8601DateFormatter().date(from: dateString)!
    do {
      let d = MyDefaults(snapshot: ["a": 3, "b": "hello", "c": dateString])

      XCTAssertEqual(d.count, 3)
      XCTAssertEqual(d.name, "hello")
      XCTAssertEqual(d.date?.date, date)
    }

    do {
      let d = MyDefaults(
        snapshot: [
          "a": Int?.none as Any,
          "b": String?.none as Any,
          "c": ISO8601Date?.none as Any,
        ]
      )

      XCTAssertEqual(d.count, 0)
      XCTAssertEqual(d.name, nil)
      XCTAssertEqual(d.date, nil)
    }
  }

  func testWrite() {
    let userDefaults = UserDefaults.init(suiteName: UUID().debugDescription)!

    let store = UserDefaultsPersistentStore<MyDefaults>(userDefaults: userDefaults)
    let dateString: String = ISO8601DateFormatter().string(from: .now)
    let date: Date = ISO8601DateFormatter().date(from: dateString)!
    store.write { d in
      d.name = "muukii"
      d.date = .init(date: date)
    }

    XCTAssertEqual(store.makeSnapshot().name, "muukii")
    XCTAssertEqual(userDefaults.string(forKey: "b"), "muukii")
    XCTAssertEqual(store.makeSnapshot().date?.date, date)
    XCTAssertEqual(userDefaults.string(forKey: "c"), dateString)

    store.write { d in
      d.name = nil
      d.date = nil
    }

    XCTAssertEqual(store.makeSnapshot().name, nil)
    XCTAssertEqual(userDefaults.string(forKey: "b"), nil)
    XCTAssertEqual(store.makeSnapshot().date, nil)
    XCTAssertEqual(userDefaults.string(forKey: "c"), nil)

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

    do {
      try store.write { d in
        d.date = .init(date: .now)
        throw "error!"
      }
    } catch {
      print(error)
    }
    XCTAssertEqual(store.makeSnapshot().date, nil)
    XCTAssertEqual(userDefaults.string(forKey: "c"), nil)
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


