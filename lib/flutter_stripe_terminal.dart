import 'dart:async';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe_terminal/reader.dart';
import 'package:flutter_stripe_terminal/utils.dart';
import 'package:rxdart/subjects.dart';

export 'package:flutter_stripe_terminal/utils.dart';
export 'package:flutter_stripe_terminal/reader.dart';

class FlutterStripeTerminal {
  static const MethodChannel _channel =
      const MethodChannel('flutter_stripe_terminal/methods');

  static const EventChannel _eventChannel =
      const EventChannel('flutter_stripe_terminal/events');

  static BehaviorSubject<ReaderConnectionStatus> readerConnectionStatus =
      BehaviorSubject<ReaderConnectionStatus>();
  static BehaviorSubject<ReaderPaymentStatus> readerPaymentStatus =
      BehaviorSubject<ReaderPaymentStatus>();
  static BehaviorSubject<ReaderUpdateStatus> readerUpdateStatus =
      BehaviorSubject<ReaderUpdateStatus>();
  static BehaviorSubject<ReaderEvent> readerEvent =
      BehaviorSubject<ReaderEvent>();
  static BehaviorSubject<String> readerInputEvent = BehaviorSubject<String>();
  static BehaviorSubject<List<Reader>> readersList = BehaviorSubject<List<Reader>>();

  static Future<T?> _invokeMethod<T>(
    String method, {
    Map<String, Object> arguments = const {},
  }) {
    return _channel.invokeMethod<T>(method, arguments);
  }

  static Future<bool> setConnectionTokenParams(
      String serverUrl, String authToken) async {
    return await _invokeMethod("setConnectionTokenParams",
        arguments: {"serverUrl": serverUrl, "authToken": authToken});
  }

  static Future<bool> searchForReaders() async {
    return await _invokeMethod("searchForReaders");
  }

  static Future<bool> connectToReader(String readerSerialNumber, String locationId) async {
    return await _invokeMethod("connectToReader", arguments: {
      "readerSerialNumber": readerSerialNumber,
      "locationId": locationId
    });
  }

  static Future<String> processPayment(String clientSecret) async {
    return Map<String, String>.from(await _invokeMethod('processPayment', arguments: {
      "clientSecret": clientSecret
    }))["paymentIntentId"]!;
  }

  static void startTerminalEventStream() {
    _eventChannel.receiveBroadcastStream().listen((event) {
      print(event);
      final eventData = Map<String, dynamic>.from(event);
      final eventKey = eventData.keys.first;
      switch (eventKey) {
        case "readerConnectionStatus":
          readerConnectionStatus.add(
              EnumToString.fromString<ReaderConnectionStatus>(
                  ReaderConnectionStatus.values, eventData[eventKey])!);
          break;
        case "readerPaymentStatus":
          readerPaymentStatus.add(EnumToString.fromString(
              ReaderPaymentStatus.values, eventData[eventKey])!);
          break;
        case "readerUpdateStatus":
          readerUpdateStatus.add(EnumToString.fromString(
              ReaderUpdateStatus.values, eventData[eventKey])!);
          break;
        case "readerEvent":
          readerEvent.add(EnumToString.fromString(
              ReaderEvent.values, eventData[eventKey])!);
          break;
        case "readerInputEvent":
          readerInputEvent.add(eventData[eventKey]);
          break;
        case "deviceList":
          readersList.add(List<Reader>.from(eventData[eventKey].map((reader) => Reader.fromJson(Map<String, String>.from(reader)))).toList());
          break;

      }
    });
  }

  void dispose() {
    readerConnectionStatus.close();
    readerPaymentStatus.close();
    readerUpdateStatus.close();
    readerEvent.close();
    readersList.close();
    readerInputEvent.close();
  }
}
