package com.sysopt.booster

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build

object NetworkUtils {
    fun getNetworkInfo(context: Context): Map<String, Any> {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val info = mutableMapOf<String, Any>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val network = cm.activeNetwork
            val capabilities = cm.getNetworkCapabilities(network)

            info["connected"] = network != null
            info["wifi"] = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) ?: false
            info["cellular"] = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ?: false
            info["vpn"] = capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) ?: false
            info["metered"] = capabilities?.hasCapability(NetworkCapabilities.NET_CAPABILITY_NOT_METERED) != true
        } else {
            val networkInfo = cm.activeNetworkInfo
            info["connected"] = networkInfo?.isConnected ?: false
            info["type"] = networkInfo?.typeName ?: "unknown"
        }

        return info
    }
}