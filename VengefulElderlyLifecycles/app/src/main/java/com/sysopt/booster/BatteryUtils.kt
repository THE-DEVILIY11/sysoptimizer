package com.sysopt.booster

import android.content.Context
import android.os.BatteryManager
import android.os.Build

object BatteryUtils {
    fun getBatteryLevel(context: Context): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val bm = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            return bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        }
        return 0
    }
}