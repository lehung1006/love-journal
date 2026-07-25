import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../diagnostics/app_debug_logger.dart';
import 'map_service_config.dart';

class MapApiKeyReader {
  const MapApiKeyReader();

  static const _channel = MethodChannel('love_journal/maps_config');
  static const _androidDartDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_ANDROID_API_KEY',
  );
  static const _iosDartDefineKey = String.fromEnvironment(
    'GOOGLE_MAPS_IOS_API_KEY',
  );

  Future<MapServiceConfig> readMapServiceConfig() async {
    if (kIsWeb) {
      final config = MapServiceConfig(
        googleMapsApiKey: _dartDefineKeyForCurrentPlatform().trim(),
      );
      _logConfig(config, source: 'web Dart define');
      return config;
    }

    try {
      final nativeConfig = await _channel.invokeMapMethod<String, dynamic>(
        'mapsConfig',
      );
      final dartDefineKey = _dartDefineKeyForCurrentPlatform().trim();
      final nativeKey = (nativeConfig?['googleMapsApiKey'] as String? ?? '')
          .trim();
      final config = MapServiceConfig(
        googleMapsApiKey: dartDefineKey.isNotEmpty ? dartDefineKey : nativeKey,
        androidPackageName:
            (nativeConfig?['androidPackageName'] as String? ?? '').trim(),
        androidCertificateSha1:
            (nativeConfig?['androidCertificateSha1'] as String? ?? '').trim(),
        iosBundleIdentifier:
            (nativeConfig?['iosBundleIdentifier'] as String? ?? '').trim(),
      );
      _logConfig(
        config,
        source: dartDefineKey.isNotEmpty
            ? 'Dart define (overrides native manifest key)'
            : 'native Android/iOS configuration',
      );
      return config;
    } on MissingPluginException {
      final config = MapServiceConfig(
        googleMapsApiKey: _dartDefineKeyForCurrentPlatform().trim(),
      );
      _logConfig(config, source: 'Dart define after missing method channel');
      return config;
    } on PlatformException {
      final config = MapServiceConfig(
        googleMapsApiKey: _dartDefineKeyForCurrentPlatform().trim(),
      );
      _logConfig(config, source: 'Dart define after platform exception');
      return config;
    }
  }

  void _logConfig(MapServiceConfig config, {required String source}) {
    AppDebugLogger.json('MapsConfig', 'resolved map service configuration', {
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'source': source,
      'apiKeyConfigured': config.hasGoogleMapsApiKey,
      'apiKeyMasked': AppDebugLogger.maskSecret(config.googleMapsApiKey),
      'apiKeyLength': config.googleMapsApiKey.length,
      'androidPackage': config.androidPackageName.isEmpty
          ? '<empty>'
          : config.androidPackageName,
      'androidCertificateSha1Header': config.androidCertificateSha1.isEmpty
          ? '<empty>'
          : config.androidCertificateSha1,
      'androidCertificateSha1CloudConsole': _colonDelimitedSha1(
        config.androidCertificateSha1,
      ),
      'iosBundleIdentifier': config.iosBundleIdentifier.isEmpty
          ? '<empty>'
          : config.iosBundleIdentifier,
    });
  }

  String _colonDelimitedSha1(String value) {
    final normalized = value.replaceAll(':', '').trim().toUpperCase();
    if (normalized.isEmpty) {
      return '<empty>';
    }
    if (normalized.length != 40) {
      return '<invalid length: ${normalized.length}>';
    }
    return List.generate(
      normalized.length ~/ 2,
      (index) => normalized.substring(index * 2, index * 2 + 2),
    ).join(':');
  }

  String _dartDefineKeyForCurrentPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidDartDefineKey;
      case TargetPlatform.iOS:
        return _iosDartDefineKey;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return '';
    }
  }
}
