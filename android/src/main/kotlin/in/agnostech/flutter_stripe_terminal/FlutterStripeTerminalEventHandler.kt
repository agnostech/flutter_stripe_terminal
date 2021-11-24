package `in`.agnostech.flutter_stripe_terminal

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.stripe.stripeterminal.Terminal
import com.stripe.stripeterminal.external.callable.*
import com.stripe.stripeterminal.external.models.*
import com.stripe.stripeterminal.log.LogLevel
import io.flutter.plugin.common.EventChannel

class FlutterStripeTerminalEventHandler(private val context: Context): EventChannel.StreamHandler, TerminalListener, DiscoveryListener, BluetoothReaderListener {

    private lateinit var eventSink: EventChannel.EventSink

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        Log.d("STRIPE TERMINAL", "event listener called")
        this.eventSink = events
        val logLevel = LogLevel.VERBOSE
        val tokenProvider = TokenProvider()
        if (!Terminal.isInitialized()) {
            Terminal.initTerminal(context, logLevel, tokenProvider, this)
        }
    }

    fun getDiscoveryListener(): DiscoveryListener {
        return this
    }

    fun getBluetoothReaderListener(): BluetoothReaderListener {
        return this
    }

    override fun onCancel(arguments: Any?) {

    }

    override fun onConnectionStatusChange(status: ConnectionStatus) {
        super.onConnectionStatusChange(status)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "connectionStatus" to status.name
            ))
        }
    }

    override fun onPaymentStatusChange(status: PaymentStatus) {
        super.onPaymentStatusChange(status)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "paymentStatus" to status.name
            ))
        }
    }

    override fun onUnexpectedReaderDisconnect(reader: Reader) {
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "connectionStatus" to "DISCONNECTED"
            ))
        }
    }

    override fun onUpdateDiscoveredReaders(readers: List<Reader>) {
        FlutterStripeTerminal.availableReadersList = readers

        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "deviceList" to readers.map {
                    mapOf(
                        "id" to it.serialNumber,
                        "deviceName" to it.deviceType.name
                    )
                }
            ))
        }
    }

    override fun onFinishInstallingUpdate(update: ReaderSoftwareUpdate?, e: TerminalException?) {
        super.onFinishInstallingUpdate(update, e)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to "FINISHED UPDATE INSTALLATION"
            ))
        }
    }

    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) {
        super.onReportAvailableUpdate(update)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to "UPDATE AVAILABLE"
            ))
        }
    }

    override fun onReportLowBatteryWarning() {
        super.onReportLowBatteryWarning()
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to "LOW BATTERY"
            ))
        }
    }

    override fun onReportReaderEvent(event: ReaderEvent) {
        super.onReportReaderEvent(event)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to event.name
            ))
        }
    }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) {
        super.onReportReaderSoftwareUpdateProgress(progress)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to "SOFTWARE UPDATE IN PROGRESS"
            ))
        }
    }

    override fun onRequestReaderDisplayMessage(message: ReaderDisplayMessage) {
        super.onRequestReaderDisplayMessage(message)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to message.name
            ))
        }
    }

    override fun onRequestReaderInput(options: ReaderInputOptions) {
        super.onRequestReaderInput(options)
        Log.d("READER INPUT REQUEST", options.toString())
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerInputOptions" to options
            ))
        }
    }

    override fun onStartInstallingUpdate(update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        super.onStartInstallingUpdate(update, cancelable)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerStatus" to "STARTING UPDATE INSTALLATION"
            ))
        }
    }
}