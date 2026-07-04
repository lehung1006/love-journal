import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

abstract interface class JournalApiDataSource {
  Future<List<Map<String, dynamic>>> fetchMemories();
  Future<List<Map<String, dynamic>>> fetchLetters();
  Future<List<Map<String, dynamic>>> fetchPlaces();
}

class JournalAssetApiDataSource implements JournalApiDataSource {
  const JournalAssetApiDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<Map<String, dynamic>>> fetchMemories() {
    return _fetchList(ApiEndpoints.memories);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchLetters() {
    return _fetchList(ApiEndpoints.letters);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPlaces() {
    return _fetchList(ApiEndpoints.places);
  }

  Future<List<Map<String, dynamic>>> _fetchList(String endpoint) async {
    final response = await _apiClient.getJson(ApiRequest(path: endpoint));
    if (response is! List<dynamic>) {
      throw ApiException(
        message: 'Expected a JSON list response',
        request: ApiRequest(path: endpoint),
        cause: response,
      );
    }

    return response
        .map((item) => item as Map<String, dynamic>)
        .toList(growable: false);
  }
}
