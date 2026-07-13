import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:flutter_love_journal/src/core/config/map_service_config.dart';
import 'package:flutter_love_journal/src/features/journal/data/data_sources/google_places_data_source.dart';

void main() {
  test('sends Android application identity with Places requests', () async {
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
    expect(
      capturedRequest.headers['X-Android-Package'],
      'vn.hung.le.lovejournal',
    );
    expect(
      capturedRequest.headers['X-Android-Cert'],
      '00112233445566778899AABBCCDDEEFF00112233',
    );
  });
}
