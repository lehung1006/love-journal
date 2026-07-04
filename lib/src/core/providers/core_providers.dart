import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/asset_api_client.dart';
import '../storage/key_value_store.dart';
import '../storage/shared_preferences_key_value_store.dart';

final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

final apiClientProvider = Provider<ApiClient>((ref) {
  return AssetApiClient(assetBundle: ref.watch(assetBundleProvider));
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final keyValueStoreProvider = FutureProvider<KeyValueStore>((ref) async {
  final preferences = await ref.watch(sharedPreferencesProvider.future);
  return SharedPreferencesKeyValueStore(preferences);
});
