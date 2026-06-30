# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Google Play Billing (removed deprecated Play Core rules)
-keep class com.android.billingclient.** { *; }
-keep class com.google.android.gms.** { *; }

# In-app purchase related classes
-keep class * implements com.android.billingclient.api.PurchasesUpdatedListener { *; }
-keep class * implements com.android.billingclient.api.BillingClientStateListener { *; }

# Suppress warnings for missing Play Core classes (deprecated)
-dontwarn com.google.android.play.core.**
-dontnote com.google.android.play.core.**

# Flutter deferred components - ignore missing Play Core classes
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication

# Keep your model classes if using JSON serialization
# -keep class com.memolingo.app.models.** { *; }
