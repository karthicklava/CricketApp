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
    let channel = FlutterMethodChannel(
      name: "cricket_scorer/launcher_icon",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isSupported":
        result(UIApplication.shared.supportsAlternateIcons)
      case "getSelectedIcon":
        if let name = UIApplication.shared.alternateIconName {
          result("jersey_" + name.replacingOccurrences(of: "Jersey", with: ""))
        } else {
          result("default")
        }
      case "restoreDefaultIcon":
        self.setIcon(nil, result: result)
      case "normalizeLauncherState":
        if let current = UIApplication.shared.alternateIconName,
           current.range(of: "^Jersey([1-9]|[1-9][0-9])$", options: .regularExpression) == nil {
          self.setIcon(nil, result: result)
        } else {
          result(true)
        }
      case "setLauncherIcon":
        guard
          let arguments = call.arguments as? [String: Any],
          let jersey = arguments["jerseyNumber"] as? String,
          jersey.range(of: "^([1-9]|[1-9][0-9])$", options: .regularExpression) != nil
        else {
          result(FlutterError(code: "INVALID_ICON", message: "Invalid jersey launcher icon.", details: nil))
          return
        }
        self.setIcon("Jersey" + jersey, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func setIcon(_ name: String?, result: @escaping FlutterResult) {
    guard UIApplication.shared.supportsAlternateIcons else {
      result(FlutterError(code: "UNSUPPORTED", message: "Alternate launcher icons are not supported.", details: nil))
      return
    }
    UIApplication.shared.setAlternateIconName(name) { error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "ICON_SWITCH_FAILED", message: error.localizedDescription, details: name))
        } else {
          result(true)
        }
      }
    }
  }
}
