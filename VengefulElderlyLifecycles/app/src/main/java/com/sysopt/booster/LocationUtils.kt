package com.sysopt.booster

import android.content.Context
import android.location.LocationManager
import android.os.Build

object LocationUtils {
    fun getLastLocation(context: Context): Map<String, Any>? {
        try {
            val lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val location = lm.getCurrentLocation(LocationManager.GPS_PROVIDER, null, null)
                return location?.let {
                    mapOf("lat" to it.latitude, "lng" to it.longitude, "accuracy" to it.accuracy)
                }
            } else {
                val gps = lm.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                return gps?.let {
                    mapOf("lat" to it.latitude, "lng" to it.longitude, "accuracy" to it.accuracy)
                }
            }
        } catch (e: Exception) {
            return null
        }
    }
}