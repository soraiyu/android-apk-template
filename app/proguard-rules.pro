# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.

# Keep application class names
-keepattributes *Annotation*

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
