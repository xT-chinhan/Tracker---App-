package vn.thuchi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import vn.thuchi.app.banknotif.BankNotificationChannels

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BankNotificationChannels.register(this, flutterEngine)
    }
}
