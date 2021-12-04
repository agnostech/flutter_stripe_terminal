import Flutter
import UIKit

public class SwiftFlutterStripeTerminalPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "flutter_stripe_terminal/methods", binaryMessenger: registrar.messenger())
    methodChannel.setMethodCallHandler(handleMethodCall)
      
    let eventChannel = FlutterEventChannel(name: "flutter_stripe_terminal/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(FlutterStripeTerminalEventHandler.shared)
  }
}
