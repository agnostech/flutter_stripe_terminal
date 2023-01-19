//
//  FlutterStripeTerminal.swift
//  flutter_stripe_terminal
//
//  Created by Vishal Dubey on 03/12/21.
//

import Foundation
import StripeTerminal
import Flutter
import Dispatch

class FlutterStripeTerminal {
    static let shared = FlutterStripeTerminal()
    
    var serverUrl: String?
    var authToken: String?
    var availableReaders: [Reader]?
    var discoverCancelable: Cancelable?
    
    func setConnectionTokenParams(serverUrl: String, authToken: String, result: FlutterResult) {
        self.serverUrl = serverUrl
        self.authToken = authToken
        Terminal.setTokenProvider(APIClient.shared)
        result(true)
    }
    
    func searchForReaders(result: @escaping FlutterResult) {
        let config = DiscoveryConfiguration(discoveryMethod: DiscoveryMethod.bluetoothScan, simulated: false)
        self.discoverCancelable = Terminal.shared.discoverReaders(config, delegate: FlutterStripeTerminalEventHandler.shared) { error in
            DispatchQueue.main.async {
                if let error = error {
                    result(FlutterError(code: "Search Error", message: "", details: ""))
                } else {
                    result(true)
                }
            }
        }
    }
    
    func connectToReader(readerSerialNumber: String, locationId: String, result: @escaping FlutterResult) {
        let selectedReaders = availableReaders?.filter { reader in
            return reader.serialNumber == readerSerialNumber
        }
       
        if (!selectedReaders!.isEmpty) {
            Terminal.shared.connectBluetoothReader(selectedReaders![0], delegate: FlutterStripeTerminalEventHandler.shared, connectionConfig: BluetoothConnectionConfiguration(locationId: locationId)) { _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "Connect Error", message: "", details: ""))
                    } else {
                        result(true)
                    }
                }
            }
        }
    }
    
    func processPayment(clientSecret: String, result: @escaping FlutterResult) {
        let terminal = Terminal.shared
        terminal.retrievePaymentIntent(clientSecret: clientSecret) { retrievedIntent, retrievedError in
            if let retrievedPaymentIntent = retrievedIntent {
                terminal.collectPaymentMethod(retrievedPaymentIntent) { processedIntent, processedError in
                    if let processedPaymentIntent = processedIntent {
                        terminal.processPayment(processedPaymentIntent) {finalIntent, finalError in
                            if let finalPaymentIntent = finalIntent {
                                result([
                                    "paymentIntentId": finalPaymentIntent.stripeId
                                ])
                            } else if let finalError = finalError {
                                DispatchQueue.main.async {
                                    result(FlutterError(code: "Final Intent Error", message: "", details: ""))
                                }
                            }
                        }
                    } else if let processedError = processedError {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "Processed Error", message: "", details: ""))
                        }
                    }
                }
            } else if let retrievedError = retrievedError {
                DispatchQueue.main.async {
                    result(FlutterError(code: "Retrived Error", message: "", details: ""))
                }
            }
        }
    }
    
    func disconnectReader(result: @escaping FlutterResult) {
        if(self.discoverCancelable == nil){
            Terminal.shared.disconnectReader() { error in
                DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "Disconnect Reader Error", message: "", details: ""))
                    } else {
                        result(true)
                    }
                }
            }
                    
        }else {
            self.discoverCancelable?.cancel() { error in
                Terminal.shared.disconnectReader() { error in
                    DispatchQueue.main.async {
                    if let error = error {
                        result(FlutterError(code: "Disconnect Reader Error", message: "", details: ""))
                    } else {
                        result(true)
                    }
                }
                }
            }
            
        }
    }
}
