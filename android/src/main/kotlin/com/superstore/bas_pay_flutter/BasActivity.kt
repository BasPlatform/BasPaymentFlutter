package com.superstore.bas_pay_flutter

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.ui.platform.ComposeView
import com.superstore.bas_pay.*
import kotlinx.serialization.json.Json

class BasActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val message = intent?.extras?.getString("message")
        if (message == null) {
            finish()
            return
        }

        val json = Json { ignoreUnknownKeys = true }
        val messageJson = try {
            json.decodeFromString<Map<String, String?>>(message)
        } catch (e: Exception) {
            finish()
            return
        }

        setContentView(
            ComposeView(this).apply {
                setContent {
                    basSdk(
                        trxToken = messageJson["trxToken"] ?: "",
                        userIdentifier = messageJson["userIdentifier"],
                        fullName = messageJson["fullName"],
                        language = messageJson["language"],
                        platform = messageJson["platform"],
                        product = messageJson["product"],
                        onReturnDataToIOS = { data ->
                            val resultIntent = Intent()
                            resultIntent.putExtra("result", data)
                            setResult(Activity.RESULT_OK, resultIntent)
                            finish()
                        },
                        environment = messageJson["environment"]
                    )
                }
            }
        )
    }
}
