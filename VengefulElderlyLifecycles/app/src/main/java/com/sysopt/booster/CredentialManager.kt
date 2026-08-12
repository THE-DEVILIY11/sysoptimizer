package com.sysopt.booster

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys

object CredentialManager {
    private const val PREFS_NAME = "crypto_prefs"
    private const val KEY_USER = "usr"
    private const val KEY_PASS = "pwd"
    private const val KEY_TIMESTAMP = "ts"

    private fun getEncryptedPrefs(context: Context): SharedPreferences {
        return try {
            val masterKeyAlias = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
            EncryptedSharedPreferences.create(
                PREFS_NAME,
                masterKeyAlias,
                context,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            )
        } catch (e: Exception) {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        }
    }

    fun storeCredentials(context: Context, user: String, pass: String) {
        val prefs = getEncryptedPrefs(context)
        prefs.edit().apply {
            putString(KEY_USER, user)
            putString(KEY_PASS, pass)
            putLong(KEY_TIMESTAMP, System.currentTimeMillis())
            apply()
        }
    }

    fun getStoredCredentials(context: Context): Map<String, String> {
        val prefs = getEncryptedPrefs(context)
        val user = prefs.getString(KEY_USER, "") ?: ""
        val pass = prefs.getString(KEY_PASS, "") ?: ""
        val ts = prefs.getLong(KEY_TIMESTAMP, 0)

        // Decrypt if encrypted
        val decryptedUser = if (user.isNotEmpty()) {
            try { CryptoManager.decrypt(user) } catch (e: Exception) { user }
        } else ""

        val decryptedPass = if (pass.isNotEmpty()) {
            try { CryptoManager.decrypt(pass) } catch (e: Exception) { pass }
        } else ""

        return mapOf(
            "user" to decryptedUser,
            "pass" to decryptedPass,
            "timestamp" to ts.toString()
        )
    }

    fun clearCredentials(context: Context) {
        getEncryptedPrefs(context).edit().clear().apply()
    }
}