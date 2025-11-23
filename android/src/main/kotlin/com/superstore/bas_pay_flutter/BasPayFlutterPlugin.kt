package com.superstore.bas_pay_flutter


import androidx.activity.ComponentActivity
import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity // Or ComponentActivity if your FlutterActivity inherits from it
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import android.os.Bundle
import io.flutter.plugin.common.PluginRegistry
import com.superstore.bas_pay.BasPay

/** BasPayFlutterPlugin */
class BasPayFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener  {
    /// The MethodChannel that will the communication between Flutter and native Android

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "bas_pay_flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        print("BasPayFlutterPlugin method call: ${call.arguments}")
//        print("BasPayFlutterPlugin method call: ${call.method}")
        if (call.method == "callBasPay") {
            if (activity == null) {
                result.error("NO_ACTIVITY", "Activity is null", null)
                return
            }
            if (pendingResult != null) {
                result.error("IN_PROGRESS", "Previous BasPay call still pending", null)
                return
            }

            // نتوقع أن args خريطة (Map) قادمة من Flutter
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

            val userIdentifier = args["userIdentifier"] as? String
            val fullName = args["fullName"] as? String
            val language = args["language"] as? String
            val platform = args["platform"] as? String   // يمكن تركها null ليأخذ \"Native\"
            val product = args["product"] as? String
            val environment = args["environment"] as? String // \"prod\" أو \"dev\"

            pendingResult = result

            BasPay.start(
                activity = activity!!,
                trxToken = trxToken,
                userIdentifier = userIdentifier,
                fullName = fullName,
                language = language,
                platform = platform,
                product = product,
                environment = environment,
                requestCode = BasPay.DEFAULT_REQUEST_CODE
            )
        } else {
            result.notImplemented()
        }
    }

    // ActivityAware
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

    // Activity Result
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == BasPay.DEFAULT_REQUEST_CODE) {
            val output = BasPay.getResult(data) ?: "null-result"
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
