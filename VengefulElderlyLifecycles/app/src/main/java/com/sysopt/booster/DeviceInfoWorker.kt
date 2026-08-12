package com.sysopt.booster

import android.content.Context
import android.os.Build
import androidx.work.Worker
import androidx.work.WorkerParameters

class DeviceInfoWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    override fun doWork(): Result {
        WebhookClient.sendDeviceInfo(applicationContext)
        return Result.success()
    }
}