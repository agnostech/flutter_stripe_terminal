package `in`.agnostech.flutter_stripe_terminal

import android.util.Log
import com.androidnetworking.AndroidNetworking
import com.androidnetworking.error.ANError
import com.androidnetworking.interfaces.JSONObjectRequestListener
import com.stripe.stripeterminal.external.callable.ConnectionTokenCallback
import com.stripe.stripeterminal.external.callable.ConnectionTokenProvider
import com.stripe.stripeterminal.external.models.ConnectionTokenException
import org.json.JSONObject

class TokenProvider: ConnectionTokenProvider {
    override fun fetchConnectionToken(callback: ConnectionTokenCallback) {
        try {
            AndroidNetworking.get(FlutterStripeTerminal.serverUrl)
                    .addHeaders(mapOf("Authorization" to "Bearer ${FlutterStripeTerminal.authToken}"))
                    .build()
                    .getAsJSONObject(object: JSONObjectRequestListener {
                        override fun onResponse(response: JSONObject) {
                            callback.onSuccess(response["secret"] as String)
                        }

                        override fun onError(anError: ANError) {
                            callback.onFailure(ConnectionTokenException("Couldn't fetch token from the server", anError))
                        }
                    })
        } catch (e: Exception) {
            callback.onFailure(
                    ConnectionTokenException("Failed to fetch connection token", e)
            );
        }
    }
}