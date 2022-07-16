package `in`.agnostech.flutter_stripe_terminal

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.Cancelable
import com.stripe.stripeterminal.external.callable.PaymentIntentCallback
import com.stripe.stripeterminal.external.callable.ReaderCallback
import com.stripe.stripeterminal.external.models.*
import io.flutter.plugin.common.MethodChannel

class FlutterStripeTerminal {
    companion object {
        lateinit var serverUrl: String
        lateinit var authToken: String
        var availableReadersList: List<Reader>? = null
        var flutterStripeTerminalEventHandler: FlutterStripeTerminalEventHandler? = null
        var cancelDiscovery: Cancelable? = null;

        fun setConnectionTokenParams(
            serverUrl: String,
            authToken: String,
            result: MethodChannel.Result
        ) {
            this.serverUrl = serverUrl
            this.authToken = authToken
            result.success(true)
        }

        fun disconnectReader(result: MethodChannel.Result) {
            cancelDiscovery?.cancel(object: Callback {
                override fun onFailure(e: TerminalException) {
                    Handler(Looper.getMainLooper()).post {
                        result.error(e.errorCode.toLogString(), e.message, null)
                    }
                }

                override fun onSuccess() {
                    Handler(Looper.getMainLooper()).post {
                        Log.d("STRIPE TERMINAL", "reader discovery cancelled")
                    }
                }

            })
            Terminal.getInstance().disconnectReader(object: Callback {
                override fun onFailure(e: TerminalException) {
                    Handler(Looper.getMainLooper()).post {
                        result.error(e.errorCode.toLogString(), e.message, null)
                    }
                }

                override fun onSuccess() {
                    Handler(Looper.getMainLooper()).post {
                        result.success(true)
                    }
                }

            })
        }

        fun searchForReaders(result: MethodChannel.Result) {
            val config = DiscoveryConfiguration(
                discoveryMethod = DiscoveryMethod.BLUETOOTH_SCAN
            )
            cancelDiscovery = Terminal.getInstance().discoverReaders(
                config,
                flutterStripeTerminalEventHandler!!.getDiscoveryListener(),
                object : Callback {
                    override fun onSuccess() {
                        Handler(Looper.getMainLooper()).post {
                            result.success(true)
                        }
                    }

                    override fun onFailure(e: TerminalException) {
                        Handler(Looper.getMainLooper()).post {
                            result.error(e.errorCode.toLogString(), e.message, null)
                        }
                    }
                })
        }

        fun connectToReader(readerSerialNumber: String, locationId: String, result: MethodChannel.Result) {

            val reader = availableReadersList!!.filter {
                it.serialNumber == readerSerialNumber
            }

            if (reader.isNotEmpty()) {
                Terminal.getInstance().connectBluetoothReader(reader[0],
                    ConnectionConfiguration.BluetoothConnectionConfiguration(locationId),
                    flutterStripeTerminalEventHandler!!.getBluetoothReaderListener(),
                    object : ReaderCallback {
                        override fun onFailure(e: TerminalException) {
                            Handler(Looper.getMainLooper()).post {
                                result.error(e.errorCode.toLogString(), e.message, null)
                            }
                        }

                        override fun onSuccess(reader: Reader) {
                            Handler(Looper.getMainLooper()).post {
                                result.success(true)
                            }
                        }
                    })
            }
        }

        fun processPayment(clientSecret: String, result: MethodChannel.Result) {
            val terminal = Terminal.getInstance()
            terminal.retrievePaymentIntent(clientSecret, object: PaymentIntentCallback {
                override fun onFailure(e: TerminalException) {
                    Handler(Looper.getMainLooper()).post {
                        result.error(e.errorCode.toLogString(), e.message, null)
                    }
                }

                override fun onSuccess(paymentIntent: PaymentIntent) {
                    Log.d("STRIPE TERMINAL", "payment intent retrieved");
                    Handler(Looper.getMainLooper()).post {
                        terminal.collectPaymentMethod(paymentIntent, object: PaymentIntentCallback {
                            override fun onFailure(e: TerminalException) {
                                Handler(Looper.getMainLooper()).post {
                                    result.error(e.errorCode.toLogString(), e.message, null)
                                }
                            }

                            override fun onSuccess(paymentIntent: PaymentIntent) {
                                terminal.processPayment(paymentIntent, object: PaymentIntentCallback {
                                    override fun onFailure(e: TerminalException) {
                                        Handler(Looper.getMainLooper()).post {
                                            result.error(e.errorCode.toLogString(), e.message, null)
                                        }
                                    }

                                    override fun onSuccess(paymentIntent: PaymentIntent) {
                                        Handler(Looper.getMainLooper()).post {
                                            result.success(mapOf(
                                                "paymentIntentId" to paymentIntent.id
                                            ))
                                        }
                                    }

                                })
                            }

                        })
                    }
                }

            })
        }
    }
}