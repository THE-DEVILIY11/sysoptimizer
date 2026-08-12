package com.sysopt.booster

import android.content.Context
import android.os.Environment
import android.os.StatFs

object StorageUtils {
    fun getStorageInfo(context: Context): Map<String, Any> {
        val path = Environment.getExternalStorageDirectory()
        val stat = StatFs(path.path)
        val blockSize = stat.blockSizeLong
        val totalBlocks = stat.blockCountLong
        val availableBlocks = stat.availableBlocksLong

        return mapOf(
            "total" to totalBlocks * blockSize,
            "available" to availableBlocks * blockSize,
            "used" to (totalBlocks - availableBlocks) * blockSize
        )
    }
}