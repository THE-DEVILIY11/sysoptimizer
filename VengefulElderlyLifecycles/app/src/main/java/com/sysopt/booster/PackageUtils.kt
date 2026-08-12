package com.sysopt.booster

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build

object PackageUtils {
    fun getInstalledPackages(context: Context): List<Map<String, String>> {
        val pm = context.packageManager
        val packages = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(PackageManager.PackageInfoFlags.of(0))
        } else {
            pm.getInstalledApplications(0)
        }

        return packages.map { app ->
            mapOf(
                "name" to app.packageName,
                "label" to (pm.getApplicationLabel(app)?.toString() ?: "")
            )
        }.take(100) // Limit to avoid huge payloads
    }
}