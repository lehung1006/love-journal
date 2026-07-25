import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_love_journal/src/core/config/map_service_config.dart';
import 'package:flutter_love_journal/src/features/journal/data/data_sources/google_places_data_source.dart';

void main() {
  test('sends only REST-supported authentication headers', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"suggestions": []}', 200);
    });
    final dataSource = GooglePlacesApiDataSource(
      client: client,
      config: const MapServiceConfig(
        googleMapsApiKey: 'test-key',
        androidPackageName: 'vn.hung.le.lovejournal',
        androidCertificateSha1: '00112233445566778899AABBCCDDEEFF00112233',
      ),
    );

    await dataSource.autocompletePlaces(
      input: 'Da Lat',
      sessionToken: 'session-1',
    );

    expect(capturedRequest.headers['X-Goog-Api-Key'], 'test-key');
    expect(capturedRequest.headers, isNot(contains('X-Android-Package')));
    expect(capturedRequest.headers, isNot(contains('X-Android-Cert')));
    expect(capturedRequest.headers, isNot(contains('X-Ios-Bundle-Identifier')));
  });

  test('sends a distance-ranked Nearby Search request', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response('{"places": []}', 200);
    });
    final dataSource = GooglePlacesApiDataSource(
      client: client,
      config: const MapServiceConfig(googleMapsApiKey: 'test-key'),
    );

    await dataSource.searchNearby(
      latitude: 10.7769,
      longitude: 106.7009,
      radiusMeters: 150,
      maxResults: 8,
    );

    expect(capturedRequest.method, 'POST');
    expect(capturedRequest.url.path, '/v1/places:searchNearby');
    final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
    expect(body['rankPreference'], 'DISTANCE');
    expect(body['maxResultCount'], 8);
    expect(body['languageCode'], 'vi');
    expect(body['regionCode'], 'VN');
    final restriction = body['locationRestriction'] as Map<String, dynamic>;
    final circle = restriction['circle'] as Map<String, dynamic>;
    expect(circle['radius'], 150);
    expect(
      capturedRequest.headers['X-Goog-FieldMask'],
      contains('places.primaryTypeDisplayName.text'),
    );
  });

  test('omits the session token for non-autocomplete Place Details', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response.bytes(
        utf8.encode(
          '{"id":"place-1","displayName":{"text":"Hồ Gươm"},'
          '"location":{"latitude":21.0,"longitude":105.0}}',
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final dataSource = GooglePlacesApiDataSource(
      client: client,
      config: const MapServiceConfig(googleMapsApiKey: 'test-key'),
    );

    await dataSource.fetchPlaceDetails(googlePlaceId: 'place-1');

    expect(
      capturedRequest.url.queryParameters,
      isNot(contains('sessionToken')),
    );
    expect(capturedRequest.url.queryParameters['languageCode'], 'vi');
    expect(
      capturedRequest.headers['X-Goog-FieldMask'],
      allOf(contains('googleMapsUri'), contains('photos.authorAttributions')),
    );
  });

  test('returns bytes from the Place Photo media endpoint', () async {
    late http.Request capturedRequest;
    final expected = Uint8List.fromList([1, 2, 3, 4]);
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response.bytes(
        expected,
        200,
        headers: {'content-type': 'image/jpeg'},
      );
    });
    final dataSource = GooglePlacesApiDataSource(
      client: client,
      config: const MapServiceConfig(googleMapsApiKey: 'test-key'),
    );

    final bytes = await dataSource.fetchPlacePhoto(
      photoName: 'places/place-1/photos/photo-1',
      maxWidthPx: 640,
    );

    expect(capturedRequest.url.path, '/v1/places/place-1/photos/photo-1/media');
    expect(capturedRequest.url.queryParameters['maxWidthPx'], '640');
    expect(bytes, expected);
  });
}
