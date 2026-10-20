package vn.thuchi.app.sms

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Kênh Flutter ↔ Android cho "Số điện thoại" (lib/features/phone): app phát hành bằng APK nên tự gửi
 * 1 tin chứa 6 số xác nhận từ SIM người dùng chọn. Không đọc tin nhắn, không lộ số điện thoại nào ra Flutter.
 */
class SmsChannel(private val activity: Activity) {
    companion object {
        private const val METHODS = "vn.thuchi.app/sms/methods"
        private const val REQUEST_CODE = 4821
        private const val SENT_ACTION = "vn.thuchi.app.SMS_SENT"
    }

    private var pendingPermission: MethodChannel.Result? = null
    private val main = Handler(Looper.getMainLooper())

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, METHODS).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasPermission" -> result.success(granted(Manifest.permission.SEND_SMS))
                "requestPermission" -> requestPermission(result)
                "listSims" -> result.success(listSims())
                "sendSms" -> sendSms(
                    call.argument<Int>("subscriptionId"),
                    call.argument<String>("destination") ?: "",
                    call.argument<String>("body") ?: "",
                    result,
                )
                "openAppSettings" -> result.success(
                    try {
                        activity.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", activity.packageName, null)))
                        true
                    } catch (_: Exception) {
                        false
                    },
                )
                else -> result.notImplemented()
            }
        }
    }

    private fun granted(permission: String) =
        activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /** SEND_SMS để gửi, READ_PHONE_STATE để liệt kê SIM (máy 2 SIM). Trả về true nếu được gửi SMS. */
    private fun requestPermission(result: MethodChannel.Result) {
        if (granted(Manifest.permission.SEND_SMS)) {
            result.success(true)
            return
        }
        pendingPermission?.success(false)
        pendingPermission = result
        activity.requestPermissions(arrayOf(Manifest.permission.SEND_SMS, Manifest.permission.READ_PHONE_STATE), REQUEST_CODE)
    }

    /** Gọi từ MainActivity.onRequestPermissionsResult. */
    fun onRequestPermissionsResult(requestCode: Int): Boolean {
        if (requestCode != REQUEST_CODE) return false
        pendingPermission?.success(granted(Manifest.permission.SEND_SMS))
        pendingPermission = null
        return true
    }

    /** SIM đang hoạt động: chỉ khe + tên nhà mạng, không trả số điện thoại. Thiếu quyền → rỗng. */
    @SuppressLint("MissingPermission")
    private fun listSims(): List<Map<String, Any?>> {
        if (!granted(Manifest.permission.READ_PHONE_STATE)) return emptyList()
        return try {
            val sm = activity.getSystemService(SubscriptionManager::class.java) ?: return emptyList()
            (sm.activeSubscriptionInfoList ?: emptyList()).sortedBy { it.simSlotIndex }.map {
                mapOf(
                    "subscriptionId" to it.subscriptionId,
                    "slot" to it.simSlotIndex + 1,
                    "carrierName" to (it.carrierName?.toString()?.takeIf { n -> n.isNotBlank() } ?: it.displayName?.toString()),
                )
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    @Suppress("DEPRECATION")
    private fun smsManager(subscriptionId: Int?): SmsManager =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val base = activity.getSystemService(SmsManager::class.java)
            if (subscriptionId != null) base.createForSubscriptionId(subscriptionId) else base
        } else {
            if (subscriptionId != null) SmsManager.getSmsManagerForSubscriptionId(subscriptionId) else SmsManager.getDefault()
        }

    /**
     * Gửi 1 tin và chờ báo "đã gửi" của nhà mạng (tối đa 30 giây). Lỗi gửi (hết tiền, mất sóng…) → false.
     * Quá thời gian chờ vẫn trả true: tin có thể đang đi, màn chờ của app tự hỏi máy chủ.
     */
    private fun sendSms(subscriptionId: Int?, destination: String, body: String, result: MethodChannel.Result) {
        if (!granted(Manifest.permission.SEND_SMS) || destination.isBlank() || body.isBlank()) {
            result.success(false)
            return
        }
        val ctx = activity.applicationContext
        var done = false
        lateinit var receiver: BroadcastReceiver
        fun finish(ok: Boolean) {
            if (done) return
            done = true
            try {
                ctx.unregisterReceiver(receiver)
            } catch (_: Exception) {
            }
            result.success(ok)
        }
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                finish(resultCode == Activity.RESULT_OK)
            }
        }
        val filter = IntentFilter(SENT_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ctx.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            ctx.registerReceiver(receiver, filter)
        }
        val sent = PendingIntent.getBroadcast(
            ctx,
            0,
            Intent(SENT_ACTION).setPackage(ctx.packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        try {
            smsManager(subscriptionId).sendTextMessage(destination, null, body, sent, null)
        } catch (_: Exception) {
            finish(false)
            return
        }
        main.postDelayed({ finish(true) }, 30_000)
    }
}
