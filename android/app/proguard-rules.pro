# Flutter engine / embedding
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play services (Google Sign-In, etc.)
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Gson / JSON reflection used by many payment + networking SDKs
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Kotlin metadata (needed for reflection-based libraries)
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# WebView-based payment SDKs (Paystack / Flutterwave checkout webviews)
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
