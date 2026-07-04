abstract interface class ApiClient {
  Future<Object?> getJson(ApiRequest request);
}

class ApiRequest {
  const ApiRequest({required this.path, this.queryParameters = const {}});

  final String path;
  final Map<String, String> queryParameters;

  @override
  String toString() {
    if (queryParameters.isEmpty) {
      return path;
    }
    final query = Uri(queryParameters: queryParameters).query;
    return '$path?$query';
  }
}

class ApiException implements Exception {
  const ApiException({required this.message, this.request, this.cause});

  final String message;
  final ApiRequest? request;
  final Object? cause;

  @override
  String toString() {
    final requestText = request == null ? '' : ' (${request.toString()})';
    return 'ApiException: $message$requestText';
  }
}
