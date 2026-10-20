package vn.thuchi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import vn.thuchi.app.banknotif.BankNotificationChannels
import vn.thuchi.app.sms.SmsChannel

class MainActivity : FlutterActivity() {
    private val sms = SmsChannel(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BankNotificationChannels.register(this, flutterEngine)
        sms.register(flutterEngine)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (!sms.onRequestPermissionsResult(requestCode)) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }
}
