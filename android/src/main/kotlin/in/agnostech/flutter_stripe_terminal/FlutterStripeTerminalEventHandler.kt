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
                "readerConnectionStatus" to status.name
            ))
        }
    }

    override fun onPaymentStatusChange(status: PaymentStatus) {
        super.onPaymentStatusChange(status)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerPaymentStatus" to status.name
            ))
        }
    }

    override fun onUnexpectedReaderDisconnect(reader: Reader) {
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerConnectionStatus" to "DISCONNECTED"
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
                "readerUpdateStatus" to "FINISHED_UPDATE_INSTALLATION"
            ))
        }
    }

    override fun onReportAvailableUpdate(update: ReaderSoftwareUpdate) {
        super.onReportAvailableUpdate(update)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerUpdateStatus" to "UPDATE_AVAILABLE"
            ))
        }
    }

    override fun onReportLowBatteryWarning() {
        super.onReportLowBatteryWarning()
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerEvent" to "LOW_BATTERY"
            ))
        }
    }

    override fun onReportReaderEvent(event: ReaderEvent) {
        super.onReportReaderEvent(event)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerEvent" to event.name
            ))
        }
    }

    override fun onReportReaderSoftwareUpdateProgress(progress: Float) {
        super.onReportReaderSoftwareUpdateProgress(progress)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerUpdateStatus" to "SOFTWARE_UPDATE_IN_PROGRESS"
            ))
        }
    }

    override fun onRequestReaderDisplayMessage(message: ReaderDisplayMessage) {
        super.onRequestReaderDisplayMessage(message)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerEvent" to message.name
            ))
        }
    }

    override fun onRequestReaderInput(options: ReaderInputOptions) {
        super.onRequestReaderInput(options)
        Log.d("READER INPUT REQUEST", options.toString())
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerEvent" to options
            ))
        }
    }

    override fun onStartInstallingUpdate(update: ReaderSoftwareUpdate, cancelable: Cancelable?) {
        super.onStartInstallingUpdate(update, cancelable)
        Handler(Looper.getMainLooper()).post {
            eventSink.success(mapOf(
                "readerUpdateStatus" to "STARTING_UPDATE_INSTALLATION"
            ))
        }
    }
}