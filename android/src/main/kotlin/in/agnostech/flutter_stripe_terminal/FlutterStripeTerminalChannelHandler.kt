package `in`.agnostech.flutter_stripe_terminal

import android.content.Context
import com.androidnetworking.AndroidNetworking
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlutterStripeTerminalChannelHandler(context: Context): MethodChannel.MethodCallHandler {

    init {
        AndroidNetworking.initialize(context)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when(call.method) {
            "setConnectionTokenParams" -> FlutterStripeTerminal.setConnectionTokenParams(call.argument<String?>("serverUrl")!!, call.argument<String?>("authToken")!!, result)
            "searchForReaders" -> FlutterStripeTerminal.searchForReaders(result)
            "connectToReader" -> FlutterStripeTerminal.connectToReader(call.argument<String>("readerSerialNumber")!!, call.argument<String>("locationId")!!, result)
            "processPayment" -> FlutterStripeTerminal.processPayment(call.argument<String>("clientSecret")!!, result)
        }
    }

}