package `in`.agnostech.flutter_stripe_terminal

import androidx.annotation.NonNull
import com.stripe.stripeterminal.TerminalApplicationDelegate

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** FlutterStripeTerminalPlugin */
class FlutterStripeTerminalPlugin: FlutterPlugin, ActivityAware {

  private lateinit var methodChannel : MethodChannel
  private lateinit var eventChannel: EventChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val flutterStripeTerminalEventHandler = FlutterStripeTerminalEventHandler(flutterPluginBinding.applicationContext)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_stripe_terminal/events")
    eventChannel.setStreamHandler(flutterStripeTerminalEventHandler)

    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_stripe_terminal/methods")
    methodChannel.setMethodCallHandler(FlutterStripeTerminalChannelHandler(flutterPluginBinding.applicationContext))

    FlutterStripeTerminal.flutterStripeTerminalEventHandler = flutterStripeTerminalEventHandler

  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null);
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    TerminalApplicationDelegate.onCreate(binding.activity.application)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

  }

  override fun onDetachedFromActivity() {

  }
}
