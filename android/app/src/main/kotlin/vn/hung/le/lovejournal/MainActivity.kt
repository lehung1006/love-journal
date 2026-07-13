package vn.hung.le.lovejournal

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.Locale

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "love_journal/maps_config",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "googleMapsApiKey" -> result.success(readGoogleMapsApiKey())
                "mapsConfig" -> result.success(readMapsConfig())
                else -> result.notImplemented()
            }
        }
    }

    private fun readMapsConfig(): Map<String, String> {
        return mapOf(
            "googleMapsApiKey" to readGoogleMapsApiKey(),
            "androidPackageName" to packageName,
            "androidCertificateSha1" to readSigningCertificateSha1(),
            "iosBundleIdentifier" to "",
        )
    }

    private fun readGoogleMapsApiKey(): String {
        val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getApplicationInfo(
                packageName,
                PackageManager.ApplicationInfoFlags.of(PackageManager.GET_META_DATA.toLong()),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
        }

        return appInfo.metaData?.getString("com.google.android.geo.API_KEY").orEmpty()
    }

    private fun readSigningCertificateSha1(): String {
        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val packageInfo = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNING_CERTIFICATES,
            )
            packageInfo.signingInfo?.apkContentsSigners
        } else {
            @Suppress("DEPRECATION")
            packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES,
            ).signatures
        }

        val certificate = signatures?.firstOrNull() ?: return ""
        val digest = MessageDigest.getInstance("SHA-1").digest(certificate.toByteArray())
        return digest.joinToString(separator = "") { byte ->
            String.format(Locale.US, "%02X", byte.toInt() and 0xFF)
        }
    }
}
