import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
      return MapServiceConfig(
        googleMapsApiKey: _dartDefineKeyForCurrentPlatform().trim(),
      );
    }

    try {
      final nativeConfig = await _channel.invokeMapMethod<String, dynamic>(
        'mapsConfig',
      );
      final dartDefineKey = _dartDefineKeyForCurrentPlatform().trim();
      return MapServiceConfig(
        googleMapsApiKey: dartDefineKey.isNotEmpty
            ? dartDefineKey
            : (nativeConfig?['googleMapsApiKey'] as String? ?? '').trim(),
        androidPackageName:
            (nativeConfig?['androidPackageName'] as String? ?? '').trim(),
        androidCertificateSha1:
            (nativeConfig?['androidCertificateSha1'] as String? ?? '').trim(),
        iosBundleIdentifier:
            (nativeConfig?['iosBundleIdentifier'] as String? ?? '').trim(),
      );
    } on MissingPluginException {
      return MapServiceConfig(
        googleMapsApiKey: _dartDefineKeyForCurrentPlatform().trim(),
      );
    } on PlatformException {
      return MapServiceConfig(
        googleMapsApiKey: _dartDefineKeyForCurrentPlatform().trim(),
      );
    }
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
