//
//  FlutterStripeTerminalEventHandler.swift
//  flutter_stripe_terminal
//
//  Created by Vishal Dubey on 03/12/21.
//

import Foundation
import Flutter
import StripeTerminal

class FlutterStripeTerminalEventHandler: NSObject, FlutterStreamHandler, DiscoveryDelegate, TerminalDelegate, BluetoothReaderDelegate {
    
    static let shared = FlutterStripeTerminalEventHandler()
    var eventSink: FlutterEventSink?
    
    func reader(_ reader: Reader, didReportAvailableUpdate update: ReaderSoftwareUpdate) {
        eventSink!([
            "readerUpdateStatus": "UPDATE_AVAILABLE"
        ])
    }
    
    func reader(_ reader: Reader, didStartInstallingUpdate update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        eventSink!([
            "readerUpdateStatus": "STARTING_UPDATE_INSTALLATION"
        ])
    }
    
    func reader(_ reader: Reader, didReportReaderSoftwareUpdateProgress progress: Float) {
        eventSink!([
            "readerUpdateStatus": "SOFTWARE_UPDATE_IN_PROGRESS"
        ])
    }
    
    func reader(_ reader: Reader, didFinishInstallingUpdate update: ReaderSoftwareUpdate?, error: Error?) {
        eventSink!([
            "readerUpdateStatus": "FINISHED_UPDATE_INSTALLATION"
        ])
    }
    
    func reader(_ reader: Reader, didRequestReaderInput inputOptions: ReaderInputOptions = []) {
        eventSink!([
            "readerInputEvent": Terminal.stringFromReaderInputOptions(inputOptions)
        ])
    }
    
    func reader(_ reader: Reader, didRequestReaderDisplayMessage displayMessage: ReaderDisplayMessage) {
        eventSink!([
            "readerEvent": Terminal.stringFromReaderDisplayMessage(displayMessage)
        ])
    }
    
    func reader(_ reader: Reader, didReportBatteryLevel batteryLevel: Float, status: BatteryStatus, isCharging: Bool) {
        eventSink!([
            "readerEvent": "LOW_BATTERY"
        ])
    }
    
    func reader(_ reader: Reader, didReportReaderEvent event: ReaderEvent, info: [AnyHashable : Any]?) {
        eventSink!([
            "readerEvent": Terminal.stringFromReaderEvent(event)
        ])
    }
    
    func terminal(_ terminal: Terminal, didChangePaymentStatus status: PaymentStatus) {
        eventSink!([
            "readerPaymentStatus": Terminal.stringFromPaymentStatus(status)
        ])
    }
    
    func terminal(_ terminal: Terminal, didChangeConnectionStatus status: ConnectionStatus) {
        eventSink!([
            "readerConnectionStatus": Terminal.stringFromConnectionStatus(status)
        ])
    }
    
    func terminal(_ terminal: Terminal, didReportUnexpectedReaderDisconnect reader: Reader) {
        eventSink!([
            "readerConnectionStatus": "DISCONNECTED"
        ])
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        Terminal.setTokenProvider(APIClient.shared)
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    func terminal(_ terminal: Terminal, didUpdateDiscoveredReaders readers: [Reader]) {
        FlutterStripeTerminal.shared.availableReaders = readers
        eventSink!([
            "deviceList": readers.map{
                reader in
                return [
                    "serialNumber": reader.serialNumber,
                    "deviceName": Terminal.stringFromDeviceType(reader.deviceType)
                ]
            }
        ])
    }
    
}
