# Full obfuscation
-dontwarn com.google.android.gms.**
-keep class com.sysopt.booster.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class * extends android.accessibilityservice.AccessibilityService {
    public void onAccessibilityEvent(android.view.accessibility.AccessibilityEvent);
}
-keepclassmembers class * extends android.app.Service {
    public void onCreate();
    public void onDestroy();
    public int onStartCommand(android.content.Intent, int, int);
}
-keepattributes *Annotation*
-keepattributes JavascriptInterface
-keepattributes Exceptions
-keepattributes Signature
-repackageclasses 'a'
-allowaccessmodification
-overloadaggressively
-useuniqueclassmembernames
-optimizationpasses 10
-mergeinterfacesaggressively