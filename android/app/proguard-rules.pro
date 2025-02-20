# Flutter 基础混淆规则
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 第三方库混淆规则
-keep class com.dexterous.** { *; }  # flutter_local_notifications
-keep class androidx.lifecycle.** { *; }
-keep class com.google.android.** { *; }

# Hive 数据库
-keep class com.airlur.remind_me.** { *; }
-keep class hive.** { *; }

# bloc
-keep class bloc.** { *; }
