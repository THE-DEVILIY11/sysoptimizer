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
                null,
                null,
                null
            )

            cursor?.use { c ->
                while (c.moveToNext()) {
                    val name = c.getString(c.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                    val number = c.getString(c.getColumnIndexOrThrow(ContactsContract.CommonDataKinds.Phone.NUMBER))
                    contacts.add(mapOf("name" to name, "number" to number))
                }
            }
        } catch (e: Exception) {
            // Permission denied
        }

        return contacts
    }
}