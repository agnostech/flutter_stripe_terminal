
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterStripeTerminal {
  static const MethodChannel _channel =
      const MethodChannel('flutter_stripe_terminal/methods');

  static const EventChannel _eventChannel = 
      const EventChannel('flutter_stripe_terminal/events');

  static Future<T?> _invokeMethod<T>(
    String method, {
    Map<String, Object> arguments = const {},
  }) {
    return _channel.invokeMethod<T>(method, arguments);
  }

  static Future<bool> setConnectionTokenParams(String serverUrl, String authToken) async {
    return await _invokeMethod('setConnectionTokenParams', arguments: {
      "serverUrl": serverUrl,
      "authToken": authToken
    });
  }

  static Future<bool> searchForReaders() async {
    return await _invokeMethod("searchForReaders");
  }

  static void startEventStream() {
    _eventChannel.receiveBroadcastStream()
    .listen((event) {
      print(event);
    });
  }

}
