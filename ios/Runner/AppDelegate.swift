import Flutter
import UIKit
import GoogleMaps  // 추가
import flutter_config  // 추가

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey(FlutterConfigPlugin.env(for: "GOOGLE_MAPS_API_KEY"))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
} nh
