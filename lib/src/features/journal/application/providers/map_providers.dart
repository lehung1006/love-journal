import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/map_service_config.dart';
import '../../data/data_sources/google_places_data_source.dart';
import '../../data/repositories/place_search_repository_impl.dart';
import '../../domain/repositories/place_search_repository.dart';

final mapServiceConfigProvider = Provider<MapServiceConfig>((ref) {
  return const MapServiceConfig();
});

final placesHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final googlePlacesDataSourceProvider = Provider<GooglePlacesDataSource>((ref) {
  return GooglePlacesApiDataSource(
    client: ref.watch(placesHttpClientProvider),
    config: ref.watch(mapServiceConfigProvider),
  );
});

final placeSearchRepositoryProvider = Provider<PlaceSearchRepository>((ref) {
  return PlaceSearchRepositoryImpl(ref.watch(googlePlacesDataSourceProvider));
});
