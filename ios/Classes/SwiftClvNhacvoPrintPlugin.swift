import Flutter
import UIKit

public class SwiftClvNhacvoPrintPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "clv_nhacvo_print", binaryMessenger: registrar.messenger())
    let instance = SwiftClvNhacvoPrintPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
