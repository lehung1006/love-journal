import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_love_journal/src/features/journal/application/providers/map_providers.dart';
import 'package:flutter_love_journal/src/features/journal/application/state/map_search_controller.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/place_search.dart';
import 'package:flutter_love_journal/src/features/journal/domain/repositories/place_search_repository.dart';

void main() {
  test('ignores a stale Nearby response after a newer map selection', () async {
    final repository = _DeferredPlaceSearchRepository();
    final container = ProviderContainer(
      overrides: [
        placeSearchRepositoryProvider.overrideWith((ref) async => repository),
      ],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      locationSearchControllerProvider.notifier,
    );

    final first = controller.searchNearby(
      const GeoCoordinate(latitude: 10, longitude: 106),
    );
    await Future<void>.delayed(Duration.zero);
    final second = controller.searchNearby(
      const GeoCoordinate(latitude: 11, longitude: 107),
    );
    await Future<void>.delayed(Duration.zero);

    repository.requests[1].completer.complete([
      _candidate('new-place', 11, 107),
    ]);
    await second;
    repository.requests[0].completer.complete([
      _candidate('old-place', 10, 106),
    ]);
    await first;

    final state = container.read(locationSearchControllerProvider);
    expect(state.nearbyCandidates.single.googlePlaceId, 'new-place');
  });
}

NearbyPlaceCandidate _candidate(String id, double latitude, double longitude) {
  return NearbyPlaceCandidate(
    googlePlaceId: id,
    name: id,
    coordinate: GeoCoordinate(latitude: latitude, longitude: longitude),
  );
}

class _NearbyRequest {
  _NearbyRequest(this.center);

  final GeoCoordinate center;
  final Completer<List<NearbyPlaceCandidate>> completer = Completer();
}

class _DeferredPlaceSearchRepository implements PlaceSearchRepository {
  final List<_NearbyRequest> requests = [];

  @override
  Future<List<PlaceSearchSuggestion>> autocompletePlaces({
    required String input,
    required String sessionToken,
    GeoCoordinate? locationBias,
  }) async {
    return const [];
  }

  @override
  Future<void> clearSession(String sessionToken) async {}

  @override
  Future<PlaceSearchResult> fetchPlaceDetails({
    required String googlePlaceId,
    String? sessionToken,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PlacePhotoData> fetchPlacePhoto({
    required PlacePhotoReference photo,
    int maxWidthPx = 640,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<NearbyPlaceCandidate>> searchNearby({
    required GeoCoordinate center,
    double radiusMeters = 150,
    int maxResults = 8,
  }) {
    final request = _NearbyRequest(center);
    requests.add(request);
    return request.completer.future;
  }
}
