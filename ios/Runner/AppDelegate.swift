import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let incomingFiles = IncomingFileHandler()
  private var fileChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "dnd.character/file_import",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    fileChannel = channel
    incomingFiles.onFileReceived = { [weak self] content in
      self?.fileChannel?.invokeMethod("onFileReceived", arguments: content)
    }
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getPendingFile":
        result(self?.incomingFiles.takePendingFile())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  @discardableResult
  func handleIncomingFile(_ url: URL) -> Bool {
    return incomingFiles.open(url)
  }
}
