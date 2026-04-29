# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter Play Store Split (optional, not used)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# AMap Location SDK
-keep class com.amap.api.location.** { *; }
-keep class com.amap.api.fence.** { *; }
-keep class com.loc.** { *; }
-keep class com.amap.api.** { *; }
-keep class com.autonavi.** { *; }
-keep class com.amap.ams.** { *; }
-keep class net.jafama.** { *; }

# Ignore warnings for missing optional dependencies
-dontwarn com.amap.ams.gnss.**
-dontwarn net.jafama.**
-dontwarn com.amap.api.**
-dontwarn com.loc.**
-dontwarn com.autonavi.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
