##------------------ Firebase ------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

##------------------ Flutter ------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

##------------------ Dart/Flutter (general) ------------------
-keep class com.example.skillswap.** { *; }

##------------------ FlutterFire ------------------
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

##------------------ Google Sign-In ------------------
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

##------------------ Supabase / OkHttp ------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

##------------------ Keep annotations ------------------
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes EnclosingMethod
-keepattributes InnerClasses
