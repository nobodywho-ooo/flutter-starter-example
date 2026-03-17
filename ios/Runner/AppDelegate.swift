import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let controller = engineBridge.pluginRegistry as! FlutterViewController
    FlutterMethodChannel(name: "nobodywho/asset_copy", binaryMessenger: controller.binaryMessenger)
      .setMethodCallHandler { call, result in
        if call.method == "copyAsset" {
          let args = call.arguments as! [String: String]
          let assetPath = args["assetPath"]!
          let destPath = args["destPath"]!
          let destURL = URL(fileURLWithPath: destPath)
          if FileManager.default.fileExists(atPath: destPath) {
            result(nil)
            return
          }
          let bundleURL = Bundle.main.bundleURL.appendingPathComponent("flutter_assets").appendingPathComponent(assetPath)
          do {
            try FileManager.default.createDirectory(at: destURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: bundleURL, to: destURL)
            result(nil)
          } catch {
            result(FlutterError(code: "COPY_FAILED", message: error.localizedDescription, details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
  }
}
