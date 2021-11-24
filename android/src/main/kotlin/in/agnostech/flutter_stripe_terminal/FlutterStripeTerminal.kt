package `in`.agnostech.flutter_stripe_terminal

import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.Callback
import com.stripe.stripeterminal.external.callable.ReaderCallback
import com.stripe.stripeterminal.external.models.*
import io.flutter.plugin.common.MethodChannel

class FlutterStripeTerminal {
    companion object {
        lateinit var serverUrl: String
        lateinit var authToken: String
        var availableReadersList: List<Reader>? = null
        var flutterStripeTerminalEventHandler: FlutterStripeTerminalEventHandler? = null;

        fun setConnectionTokenParams(
            serverUrl: String,
            authToken: String,
            result: MethodChannel.Result
        ) {
            this.serverUrl = serverUrl
            this.authToken = authToken
            result.success(true)
        }

        fun searchForReaders(result: MethodChannel.Result) {
            val config = DiscoveryConfiguration(
                discoveryMethod = DiscoveryMethod.BLUETOOTH_SCAN
            )
            Terminal.getInstance().discoverReaders(
                config,
                flutterStripeTerminalEventHandler!!.getDiscoveryListener(),
                object : Callback {
                    override fun onSuccess() {
                        result.success(true)
                    }

                    override fun onFailure(e: TerminalException) {
                        result.error(e.errorCode.toLogString(), e.message, null)
                    }
                })
        }

        fun connectToReader(readerSerialNumber: String, result: MethodChannel.Result) {
            val reader = availableReadersList!!.filter {
                it.serialNumber == readerSerialNumber
            }

            if (reader.isNotEmpty()) {
                Terminal.getInstance().connectBluetoothReader(reader[0],
                    ConnectionConfiguration.BluetoothConnectionConfiguration(""),
                    flutterStripeTerminalEventHandler!!.getBluetoothReaderListener(),
                    object : ReaderCallback {
                        override fun onFailure(e: TerminalException) {
                            result.error(e.errorCode.toLogString(), e.message, null)
                        }

                        override fun onSuccess(reader: Reader) {
                            result.success(true)
                        }
                    })
            }
        }
    }
}