package vn.thuchi.app.banknotif

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/**
 * Đọc thông báo biến động số dư của app ngân hàng / ví (dựa trên module mobile/modules/bank_notification_listener).
 *
 * Khác bản gốc để đúng chính sách Google Play:
 * - Chỉ giữ thông báo của app ngân hàng / ví đã biết, hoặc có dạng số tiền; mọi thông báo khác bị bỏ qua, không lưu.
 * - Chỉ chạy khi người dùng bật trong app (cờ `enabled`); tắt thì không lưu gì và xóa bộ đệm.
 * - Không foreground service, không BootReceiver, không xin miễn tối ưu pin: hệ thống tự gắn lại
 *   NotificationListenerService khi máy khởi động (người dùng đã cấp quyền "Truy cập thông báo").
 * - Nội dung chỉ lưu trên máy (tối đa [MAX_ITEMS] mục) cho tới khi app đọc và người dùng xác nhận / bỏ qua.
 */
class BankNotificationListener : NotificationListenerService() {

    companion object {
        private const val PREFS = "thuchi_bank_notifications"
        private const val KEY_ENABLED = "enabled"
        private const val KEY_ITEMS = "items"
        private const val MAX_ITEMS = 100

        /** Gói app ngân hàng / ví tại Việt Nam (đồng bộ với `_bankPackageNames` trong bank_notification_parser.dart). */
        val BANK_PACKAGES = setOf(
            "com.vcb", "com.vietcombank", "com.vcb.digibank", "com.mbmobile", "com.mbbank",
            "com.techcombank.mobile", "com.techcombank.bb.omb", "vn.com.techcombank.bb.app",
            "com.vnpay.vpbankonline", "com.vpb.vpbankonline", "vn.vpbank.online", "mobile.acb.com.vn", "com.acb.mobile",
            "com.tpb.mb.gprsandroid", "com.tpbank.mobile", "com.vnpay.bidv", "com.bidv.smartbanking",
            "com.mservice.momotransfer", "vn.com.vng.zalopay", "com.vietinbank.ipay", "com.vnpay.agribank", "vn.timo.app",
            "com.vnpay.sacombank", "com.vib.vibmobile", "com.ocb.omni.app", "com.shb.mobile", "com.hdbank.mobile",
            "com.viettel.viettelpay", "vn.com.seabank.mb1", "com.msb.smartbanking", "com.vccb",
        )

        /** Số tiền kèm đơn vị: "+200,000VND", "50.000 đ", "1.500.000 VNĐ" */
        private val MONEY = Regex("[+\\-]?\\s*\\d[\\d.,]*\\s*(vnd|vnđ|đ|dong|đồng)", RegexOption.IGNORE_CASE)

        @Volatile var eventSink: EventChannel.EventSink? = null
        private val mainHandler = Handler(Looper.getMainLooper())

        private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

        fun isEnabled(context: Context) = prefs(context).getBoolean(KEY_ENABLED, false)

        fun setEnabled(context: Context, enabled: Boolean) {
            prefs(context).edit().putBoolean(KEY_ENABLED, enabled).apply()
            if (!enabled) clear(context)
        }

        fun isFinancial(packageName: String, text: String) =
            BANK_PACKAGES.contains(packageName.lowercase()) || MONEY.containsMatchIn(text)

        @Synchronized
        fun save(context: Context, item: Map<String, Any>) {
            val old = JSONArray(prefs(context).getString(KEY_ITEMS, "[]") ?: "[]")
            val next = JSONArray().put(JSONObject(item))
            for (i in 0 until minOf(old.length(), MAX_ITEMS - 1)) next.put(old.getJSONObject(i))
            prefs(context).edit().putString(KEY_ITEMS, next.toString()).apply()
        }

        @Synchronized
        fun stored(context: Context): List<Map<String, Any>> {
            val arr = JSONArray(prefs(context).getString(KEY_ITEMS, "[]") ?: "[]")
            return (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                o.keys().asSequence().associateWith { k -> o.get(k) }
            }
        }

        @Synchronized
        fun clear(context: Context) {
            prefs(context).edit().remove(KEY_ITEMS).apply()
        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null || sbn.packageName == packageName) return
        if (!isEnabled(applicationContext)) return
        val extras = sbn.notification?.extras ?: return
        val title = (extras.getCharSequence(Notification.EXTRA_TITLE) ?: extras.getCharSequence(Notification.EXTRA_TITLE_BIG))?.toString() ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString()
        val body = if (bigText != null && bigText.length > text.length) bigText else text
        val subText = (extras.getCharSequence(Notification.EXTRA_SUB_TEXT) ?: extras.getCharSequence(Notification.EXTRA_INFO_TEXT))?.toString() ?: ""
        if (title.isEmpty() && body.isEmpty()) return
        // Quyền riêng tư: thông báo không phải tài chính (tin nhắn, mạng xã hội…) bị bỏ qua hoàn toàn
        if (!isFinancial(sbn.packageName, "$title $body $subText")) return

        val item = mapOf<String, Any>(
            "id" to UUID.randomUUID().toString(),
            "packageName" to sbn.packageName,
            "title" to title,
            "text" to body,
            "subText" to subText,
            "timestamp" to sbn.postTime,
        )
        save(applicationContext, item)
        mainHandler.post { eventSink?.success(item) }
    }

    override fun onListenerDisconnected() {
        // Bị hệ thống ngắt (thường do tiết kiệm pin của hãng): xin gắn lại
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            requestRebind(ComponentName(this, BankNotificationListener::class.java))
        }
    }
}
