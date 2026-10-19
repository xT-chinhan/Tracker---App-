package vn.thuchi.app.banknotif

import android.app.Activity
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** Kênh Flutter ↔ Android cho tính năng "Ghi từ thông báo ngân hàng" (lib/features/bank_notifications). */
object BankNotificationChannels {
    private const val METHODS = "vn.thuchi.app/bank_notifications/methods"
    private const val EVENTS = "vn.thuchi.app/bank_notifications/events"

    fun register(activity: Activity, engine: FlutterEngine) {
        val ctx = activity.applicationContext
        MethodChannel(engine.dartExecutor.binaryMessenger, METHODS).setMethodCallHandler { call, result ->
            when (call.method) {
                "isPermissionGranted" -> result.success(isPermissionGranted(activity))
                "openPermissionSettings" -> result.success(open(activity, permissionIntent(activity)))
                // Android 13+: app không cài từ CH Play phải mở "Cài đặt bị hạn chế" ở trang thông tin ứng dụng
                "openAppDetails" -> result.success(open(activity, Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", activity.packageName, null))))
                // Danh sách tối ưu pin để người dùng tự chọn (không cần quyền REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                "openBatterySettings" -> result.success(open(activity, Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)))
                "isIgnoringBatteryOptimizations" -> {
                    val pm = activity.getSystemService(PowerManager::class.java)
                    result.success(pm?.isIgnoringBatteryOptimizations(activity.packageName) ?: false)
                }
                "isEnabled" -> result.success(BankNotificationListener.isEnabled(ctx))
                "setEnabled" -> {
                    BankNotificationListener.setEnabled(ctx, call.argument<Boolean>("enabled") == true)
                    result.success(true)
                }
                "getSavedNotifications" -> result.success(BankNotificationListener.stored(ctx))
                "clearSavedNotifications" -> {
                    BankNotificationListener.clear(ctx)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        EventChannel(engine.dartExecutor.binaryMessenger, EVENTS).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                BankNotificationListener.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                BankNotificationListener.eventSink = null
            }
        })
    }

    private fun isPermissionGranted(activity: Activity): Boolean {
        val flat = Settings.Secure.getString(activity.contentResolver, "enabled_notification_listeners") ?: return false
        val me = ComponentName(activity, BankNotificationListener::class.java)
        return flat.split(':').mapNotNull { ComponentName.unflattenFromString(it) }.any { it == me }
    }

    private fun permissionIntent(activity: Activity): Intent =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Mở thẳng trang bật quyền của Thu Chi
            Intent(Settings.ACTION_NOTIFICATION_LISTENER_DETAIL_SETTINGS).putExtra(
                Settings.EXTRA_NOTIFICATION_LISTENER_COMPONENT_NAME,
                ComponentName(activity, BankNotificationListener::class.java).flattenToString(),
            )
        } else {
            Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
        }

    private fun open(activity: Activity, intent: Intent): Boolean = try {
        activity.startActivity(intent)
        true
    } catch (_: Exception) {
        try {
            activity.startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
            true
        } catch (_: Exception) {
            false
        }
    }
}
