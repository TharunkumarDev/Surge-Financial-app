# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.** { *; }

# Keep text recognition models
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.latin.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Keep Isar
-keep class io.isar.** { *; }
-dontwarn io.isar.**

# Keep Telephony
-keep class com.shounakmulay.telephony.** { *; }
-dontwarn com.shounakmulay.telephony.**

# Broad warning suppression for problematic plugins
-dontwarn **
