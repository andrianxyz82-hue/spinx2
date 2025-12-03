# OkHttp
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# Okio
-keep class okio.** { *; }

# javax.annotation
-dontwarn javax.annotation.Nullable
-keep class javax.annotation.Nullable

# Conscrypt
-dontwarn org.conscrypt.**
-keep class org.conscrypt.** { *; }

# Prevent removing SSL Provider
-keep class com.google.android.gms.org.conscrypt.** { *; }
