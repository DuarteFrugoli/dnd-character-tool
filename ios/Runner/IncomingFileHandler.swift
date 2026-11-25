import Foundation

/// Serial background reads; queue state and Flutter notifications stay on main.
final class IncomingFileHandler {
  typealias Executor = (@escaping () -> Void) -> Void

  var onFileReceived: ((String) -> Void)?
  private let readFile: (URL) throws -> String
  private let dispatchRead: Executor
  private let dispatchMain: Executor
  private var pending: [String] = []
  private var listenerReady = false

  init(
    readFile: @escaping (URL) throws -> String = IncomingFileHandler.readDocument,
    dispatchRead: Executor? = nil,
    dispatchMain: @escaping Executor = { DispatchQueue.main.async(execute: $0) }
  ) {
    let queue = DispatchQueue(label: "dnd.character.file-import", qos: .userInitiated)
    self.readFile = readFile
    self.dispatchRead = dispatchRead ?? { queue.async(execute: $0) }
    self.dispatchMain = dispatchMain
  }

  @discardableResult
  func open(_ url: URL) -> Bool {
    guard url.isFileURL,
      ["dndchar", "dndbackup"].contains(url.pathExtension.lowercased())
    else { return false }

    dispatchRead { [weak self] in
      guard let self = self,
        let content = try? self.readFile(url),
        content.contains("\"character\"") || content.contains("\"characters\"")
      else { return }
      self.dispatchMain { [weak self] in
        guard let self = self else { return }
        self.pending.append(content)
        self.deliverPendingFiles()
      }
    }
    return true
  }

  func takePendingFile() -> String? {
    listenerReady = true
    guard !pending.isEmpty else { return nil }
    let first = pending.removeFirst()
    if !pending.isEmpty {
      // The first file goes in the channel reply, before further notifications.
      dispatchMain { [weak self] in self?.deliverPendingFiles() }
    }
    return first
  }

  private func deliverPendingFiles() {
    guard listenerReady, let notify = onFileReceived else { return }
    while !pending.isEmpty { notify(pending.removeFirst()) }
  }

  static func readDocument(_ url: URL) throws -> String {
    let scoped = url.startAccessingSecurityScopedResource()
    defer { if scoped { url.stopAccessingSecurityScopedResource() } }

    // Files/iCloud providers may download or coordinate access here. Keep all
    // of this on the read queue, including permission access and UTF-8 decoding.
    var coordinationError: NSError?
    var result: Result<String, Error>?
    NSFileCoordinator().coordinate(readingItemAt: url, options: [], error: &coordinationError) { coordinatedURL in
      result = Result { try String(contentsOf: coordinatedURL, encoding: .utf8) }
    }
    if let error = coordinationError { throw error }
    guard let value = result else { throw CocoaError(.fileReadUnknown) }
    return try value.get()
  }
}
