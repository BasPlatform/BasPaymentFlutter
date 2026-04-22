package com.superstore.bas_pay_flutter

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

/** BasPayFlutterPlugin */
class BasPayFlutterPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener  {
    /// The MethodChannel that will handle the communication between Flutter and native Android

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: MethodChannel.Result? = null

    companion object {
        private const val DEFAULT_REQUEST_CODE = 1001
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "bas_pay_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "callBasPay") {
            if (activity == null) {
                result.error("NO_ACTIVITY", "Activity is null", null)
                return
            }
            if (pendingResult != null) {
                result.error("IN_PROGRESS", "Previous BasPay call still pending", null)
                return
            }

            val args = call.arguments as? Map<String, Any?>
            if (args == null) {
                result.error("BAD_ARGS", "Arguments must be a Map", null)
                return
            }

            val trxToken = args["trxToken"] as? String
            if (trxToken.isNullOrBlank()) {
                result.error("MISSING_TOKEN", "trxToken is required", null)
                return
            }

            pendingResult = result

            try {
                val intent = Intent(activity, BasActivity::class.java)
                // Filter nulls and convert everything to String for simplicity in this bridge
                val stringArgs = args.filterValues { it != null }.mapValues { it.value.toString() }
                val jsonString = Json.encodeToString(stringArgs)
                intent.putExtra("message", jsonString)
                activity?.startActivityForResult(intent, DEFAULT_REQUEST_CODE)
            } catch (e: Exception) {
                pendingResult = null
                result.error("LAUNCH_ERROR", e.message, null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == DEFAULT_REQUEST_CODE) {
            val output = data?.getStringExtra("result") ?: "null-result"
            pendingResult?.success(output)
            pendingResult = null
            return true
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
