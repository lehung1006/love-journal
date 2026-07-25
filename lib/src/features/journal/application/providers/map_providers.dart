import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/map_api_key_reader.dart';
import '../../../../core/config/map_service_config.dart';
import '../../data/data_sources/google_places_data_source.dart';
import '../../data/data_sources/place_search_data_source.dart';
import '../../data/repositories/place_search_repository_impl.dart';
import '../../domain/repositories/place_search_repository.dart';

final mapApiKeyReaderProvider = Provider<MapApiKeyReader>((ref) {
  return const MapApiKeyReader();
});

final mapServiceConfigProvider = FutureProvider<MapServiceConfig>((ref) async {
  return ref.watch(mapApiKeyReaderProvider).readMapServiceConfig();
});

final placesHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final placeSearchDataSourceProvider = FutureProvider<PlaceSearchDataSource>((
  ref,
) async {
  final config = await ref.watch(mapServiceConfigProvider.future);
  return GooglePlacesApiDataSource(
    client: ref.watch(placesHttpClientProvider),
    config: config,
  );
});

final placeSearchRepositoryProvider = FutureProvider<PlaceSearchRepository>((
  ref,
) async {
  final dataSource = await ref.watch(placeSearchDataSourceProvider.future);
  return PlaceSearchRepositoryImpl(dataSource);
});
