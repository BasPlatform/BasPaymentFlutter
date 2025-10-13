
package com.superstore.bas_pay_flutter

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.compose.ui.platform.ComposeView
import com.superstore.bas_pay.*
import android.content.Intent
import kotlinx.serialization.json.Json
//import android.util.Log

class BasActivity : ComponentActivity() {
//    private val basMain = BasMain()


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        val intent: Intent? = getIntent()
        val json: Json = Json

//        val inputMessage = intent?.getStringExtra(BasActivityContract.EXTRA_INPUT_MESSAGE) ?: "No input message"
        val message = intent?.getExtras()?.getString("message")
//        Log.d("message ::::", "${message}")
//        val messageJson = json.decodeFromString<Map<String, String?>>(inputMessage as String)
        val messageJson = json.decodeFromString<Map<String, String?>>(message as String)


        setContentView(
            ComposeView(this).apply {
                setContent {
                    basSdk(
                        messageJson["trxToken"] as String,
                        messageJson["userIdentifier"],
                        messageJson["fullName"],
                        messageJson["language"],
                        messageJson["platform"],
                        product = messageJson["product"],
                        onReturnDataToIOS = null,
                        environment = messageJson["environment"]
                    )
                }
            }
        )
    }

}