import 'dart:convert';

import 'package:flutter/services.dart';

import 'api_client.dart';

class AssetApiClient implements ApiClient {
  const AssetApiClient({
    required this.assetBundle,
    this.basePath = 'assets/data',
  });

  final AssetBundle assetBundle;
  final String basePath;

  @override
  Future<Object?> getJson(ApiRequest request) async {
    final normalizedBase = basePath.replaceAll(RegExp(r'/$'), '');
    final normalizedPath = request.path.replaceAll(RegExp(r'^/'), '');
    final assetPath = '$normalizedBase/$normalizedPath';

    try {
      final raw = await assetBundle.loadString(assetPath);
      return jsonDecode(raw) as Object?;
    } on FormatException catch (error) {
      throw ApiException(
        message: 'Invalid JSON response',
        request: request,
        cause: error,
      );
    } catch (error) {
      throw ApiException(
        message: 'Asset endpoint not found',
        request: request,
        cause: error,
      );
    }
  }
}
