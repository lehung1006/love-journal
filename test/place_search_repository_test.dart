import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_love_journal/src/features/journal/data/data_sources/place_search_data_source.dart';
import 'package:flutter_love_journal/src/features/journal/data/repositories/place_search_repository_impl.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/memory_location.dart';
import 'package:flutter_love_journal/src/features/journal/domain/entities/place_search.dart';

void main() {
  test(
    'maps Nearby Search and Place Details into immutable domain data',
    () async {
      final dataSource = _FakePlaceSearchDataSource();
      final repository = PlaceSearchRepositoryImpl(dataSource);

      final nearby = await repository.searchNearby(
        center: const GeoCoordinate(latitude: 10, longitude: 106),
      );
      final details = await repository.fetchPlaceDetails(
        googlePlaceId: 'place-1',
      );
      final photo = await repository.fetchPlacePhoto(
        photo: details.photos.single,
      );

      expect(nearby, hasLength(1));
      expect(nearby.single.name, 'Nhà hát Thành phố');
      expect(nearby.single.businessStatus, PlaceBusinessStatus.operational);
      expect(details.primaryTypeDisplayName, 'Nhà hát');
      expect(details.googleMapsUri, 'https://maps.google.com/place-1');
      expect(details.photos.single.authorAttributions.single.displayName, 'An');
      expect(photo.bytes, Uint8List.fromList([4, 3, 2, 1]));
      expect(dataSource.lastDetailsSessionToken, isNull);
    },
  );

  test('manual coordinate changes can clear stale Google metadata', () {
    const draft = MemoryLocationDraft(
      displayName: 'Hồ Gươm',
      formattedAddress: 'Hoàn Kiếm, Hà Nội',
      latitude: 21.0287,
      longitude: 105.8522,
      googlePlaceId: 'place-1',
      source: MemoryLocationSource.googlePlaces,
    );

    final manual = draft.copyWith(
      latitude: 10.7769,
      longitude: 106.7009,
      source: MemoryLocationSource.manual,
      clearFormattedAddress: true,
      clearGooglePlaceId: true,
    );

    expect(manual.formattedAddress, isNull);
    expect(manual.googlePlaceId, isNull);
    expect(manual.source, MemoryLocationSource.manual);
  });
}

class _FakePlaceSearchDataSource implements PlaceSearchDataSource {
  String? lastDetailsSessionToken;

  @override
  Future<List<Map<String, dynamic>>> autocompletePlaces({
    required String input,
    required String sessionToken,
    double? biasLatitude,
    double? biasLongitude,
  }) async {
    return const [];
  }

  @override
  Future<void> clearSession(String sessionToken) async {}

  @override
  Future<Map<String, dynamic>> fetchPlaceDetails({
    required String googlePlaceId,
    String? sessionToken,
  }) async {
    lastDetailsSessionToken = sessionToken;
    return {
      'id': googlePlaceId,
      'displayName': {'text': 'Nhà hát Thành phố'},
      'formattedAddress': '7 Công trường Lam Sơn',
      'location': {'latitude': 10.7764, 'longitude': 106.7031},
      'primaryTypeDisplayName': {'text': 'Nhà hát'},
      'businessStatus': 'OPERATIONAL',
      'googleMapsUri': 'https://maps.google.com/place-1',
      'photos': [
        {
          'name': 'places/place-1/photos/photo-1',
          'widthPx': 1200,
          'heightPx': 800,
          'authorAttributions': [
            {'displayName': 'An', 'uri': 'https://maps.google.com/contributor'},
          ],
        },
      ],
    };
  }

  @override
  Future<Uint8List> fetchPlacePhoto({
    required String photoName,
    required int maxWidthPx,
  }) async {
    return Uint8List.fromList([4, 3, 2, 1]);
  }

  @override
  Future<List<Map<String, dynamic>>> searchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required int maxResults,
  }) async {
    return [
      {
        'id': 'place-1',
        'displayName': {'text': 'Nhà hát Thành phố'},
        'formattedAddress': '7 Công trường Lam Sơn',
        'location': {'latitude': 10.7764, 'longitude': 106.7031},
        'primaryTypeDisplayName': {'text': 'Nhà hát'},
        'businessStatus': 'OPERATIONAL',
      },
    ];
  }
}
