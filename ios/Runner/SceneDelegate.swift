import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        // Files that launch the app arrive through connection options.
        let app = UIApplication.shared.delegate as? AppDelegate
        for context in connectionOptions.urlContexts {
            app?.handleIncomingFile(context.url)
        }
    }

    override func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        let app = UIApplication.shared.delegate as? AppDelegate
        let unhandled = URLContexts.filter { app?.handleIncomingFile($0.url) != true }
        if !unhandled.isEmpty {
            super.scene(scene, openURLContexts: Set(unhandled))
        }
    }
}
