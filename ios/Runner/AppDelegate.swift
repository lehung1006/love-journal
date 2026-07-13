import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String,
       !apiKey.isEmpty,
       !apiKey.hasPrefix("$(") {
      GMSServices.provideAPIKey(apiKey)
    }
    configureMapsConfigChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func configureMapsConfigChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "love_journal/maps_config",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "googleMapsApiKey":
        result(self.readGoogleMapsApiKey())
      case "mapsConfig":
        result([
          "googleMapsApiKey": self.readGoogleMapsApiKey(),
          "androidPackageName": "",
          "androidCertificateSha1": "",
          "iosBundleIdentifier": Bundle.main.bundleIdentifier ?? ""
        ])
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func readGoogleMapsApiKey() -> String {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleMapsApiKey") as? String,
          !apiKey.isEmpty,
          !apiKey.hasPrefix("$(") else {
      return ""
    }

    return apiKey
  }
}
