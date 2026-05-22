import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let url = URLContexts.first?.url else { return }
        guard url.pathExtension == "dndchar" else { return }
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return }
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(
            name: "dnd.character/file_import",
            binaryMessenger: controller.binaryMessenger
        )
        channel.invokeMethod("onFileReceived", arguments: content)
    }
}
