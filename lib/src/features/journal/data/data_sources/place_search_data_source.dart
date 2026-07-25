import 'dart:typed_data';

abstract interface class PlaceSearchDataSource {
  Future<List<Map<String, dynamic>>> autocompletePlaces({
    required String input,
    required String sessionToken,
    double? biasLatitude,
    double? biasLongitude,
  });

  Future<List<Map<String, dynamic>>> searchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required int maxResults,
  });

  Future<Map<String, dynamic>> fetchPlaceDetails({
    required String googlePlaceId,
    String? sessionToken,
  });

  Future<Uint8List> fetchPlacePhoto({
    required String photoName,
    required int maxWidthPx,
  });

  Future<void> clearSession(String sessionToken);
}

class PlaceSearchException implements Exception {
  const PlaceSearchException({required this.statusCode, required this.body});

  final int statusCode;
  final Object? body;

  @override
  String toString() {
    String? message;
    if (body case final Map<String, dynamic> responseBody) {
      final error = responseBody['error'];
      if (error is Map<String, dynamic>) {
        message = error['message'] as String?;
      }
    }
    return message != null && message.isNotEmpty
        ? message
        : 'Place search request failed ($statusCode).';
  }
}
