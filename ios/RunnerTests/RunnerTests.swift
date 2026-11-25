import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  private let character = "{\"character\":{\"name\":\"Hero\"}}"
  private let backup = "{\"characters\":[]}"

  private final class Harness {
    var reads: [() -> Void] = []
    var callbacks: [() -> Void] = []
    var files: [String: String] = [:]
    var received: [String] = []
    lazy var handler: IncomingFileHandler = {
      let value = IncomingFileHandler(
        readFile: { [unowned self] url in
          guard let content = self.files[url.lastPathComponent] else {
            throw CocoaError(.fileReadNoSuchFile)
          }
          return content
        },
        dispatchRead: { [unowned self] in self.reads.append($0) },
        dispatchMain: { [unowned self] in self.callbacks.append($0) }
      )
      value.onFileReceived = { [weak self] in self?.received.append($0) }
      return value
    }()
    func drainReads() { while !reads.isEmpty { reads.removeFirst()() } }
    func drainCallbacks() { while !callbacks.isEmpty { callbacks.removeFirst()() } }
    func finish() { drainReads(); drainCallbacks() }
  }

  func testColdStartQueuesBeforeFlutterIsReady() {
    let h = Harness()
    h.files["hero.dndchar"] = character
    XCTAssertTrue(h.handler.open(URL(fileURLWithPath: "/hero.dndchar")))
    h.finish()
    XCTAssertTrue(h.received.isEmpty)
    XCTAssertEqual(h.handler.takePendingFile(), character)
    XCTAssertNil(h.handler.takePendingFile())
    XCTAssertTrue(h.received.isEmpty)
  }

  func testSlowColdStartDeliversAfterFlutterIsReady() {
    let h = Harness()
    h.files["all.dndbackup"] = backup
    XCTAssertTrue(h.handler.open(URL(fileURLWithPath: "/all.dndbackup")))
    XCTAssertNil(h.handler.takePendingFile())
    h.drainReads()
    XCTAssertTrue(h.received.isEmpty)
    h.drainCallbacks()
    XCTAssertEqual(h.received, [backup])
    XCTAssertNil(h.handler.takePendingFile())
  }

  func testWarmStartSupportsBothTypesAndUppercaseExtensions() {
    let h = Harness()
    h.files = ["hero.DNDCHAR": character, "all.DNDBACKUP": backup]
    XCTAssertNil(h.handler.takePendingFile())
    XCTAssertTrue(h.handler.open(URL(fileURLWithPath: "/hero.DNDCHAR")))
    XCTAssertTrue(h.handler.open(URL(fileURLWithPath: "/all.DNDBACKUP")))
    h.finish()
    XCTAssertEqual(h.received, [character, backup])
  }

  func testPendingAndNewResultsKeepTheirOrder() {
    let h = Harness()
    h.files = ["one.dndchar": character, "two.dndbackup": backup, "three.dndchar": character]
    h.handler.open(URL(fileURLWithPath: "/one.dndchar"))
    h.handler.open(URL(fileURLWithPath: "/two.dndbackup"))
    h.finish()
    h.handler.open(URL(fileURLWithPath: "/three.dndchar"))
    h.drainReads()
    XCTAssertEqual(h.handler.takePendingFile(), character)
    h.drainCallbacks()
    XCTAssertEqual(h.received, [backup, character])
    XCTAssertNil(h.handler.takePendingFile())
  }

  func testUnrelatedURLsAreNotClaimed() {
    let h = Harness()
    XCTAssertFalse(h.handler.open(URL(string: "https://example.com/hero.dndchar")!))
    XCTAssertFalse(h.handler.open(URL(fileURLWithPath: "/other.pdf")))
    XCTAssertTrue(h.reads.isEmpty)
  }

  func testUnreadableAndInvalidFilesDoNotBlockLaterImports() {
    let h = Harness()
    h.files = ["invalid.dndchar": "not a character", "valid.dndchar": character]
    _ = h.handler.takePendingFile()
    h.handler.open(URL(fileURLWithPath: "/missing.dndchar"))
    h.handler.open(URL(fileURLWithPath: "/invalid.dndchar"))
    h.handler.open(URL(fileURLWithPath: "/valid.dndchar"))
    h.finish()
    XCTAssertEqual(h.received, [character])
  }

  func testReadsRunInBackgroundAndNotificationsRunOnMain() {
    let read = expectation(description: "read off main")
    let received = expectation(description: "notify on main")
    let handler = IncomingFileHandler(readFile: { _ in
      XCTAssertFalse(Thread.isMainThread)
      read.fulfill()
      return self.character
    })
    handler.onFileReceived = { content in
      XCTAssertTrue(Thread.isMainThread)
      XCTAssertEqual(content, self.character)
      received.fulfill()
    }
    XCTAssertNil(handler.takePendingFile())
    handler.open(URL(fileURLWithPath: "/hero.dndchar"))
    wait(for: [read, received], timeout: 5)
  }

  func testRealUTF8FileCanBeReadInsideTheSandbox() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("hero.dndchar")
    let payload = "{\"character\":{\"name\":\"Mágico\"},\"imageData\":\"AQID\"}"
    try payload.write(to: url, atomically: true, encoding: .utf8)
    XCTAssertEqual(try IncomingFileHandler.readDocument(url), payload)
  }
}
