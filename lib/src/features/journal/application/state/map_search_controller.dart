import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/diagnostics/app_debug_logger.dart';
import '../../domain/entities/place_search.dart';
import '../providers/map_providers.dart';

final locationSearchControllerProvider =
    NotifierProvider<LocationSearchController, LocationSearchState>(
      LocationSearchController.new,
    );

class LocationSearchState {
  const LocationSearchState({
    this.query = '',
    this.suggestions = const [],
    this.nearbyCandidates = const [],
    this.selectedPlace,
    this.selectedPhoto,
    this.isSearching = false,
    this.isSearchingNearby = false,
    this.isResolving = false,
    this.isLoadingPhoto = false,
    this.errorMessage,
    this.nearbyErrorMessage,
    this.photoErrorMessage,
  });

  final String query;
  final List<PlaceSearchSuggestion> suggestions;
  final List<NearbyPlaceCandidate> nearbyCandidates;
  final PlaceSearchResult? selectedPlace;
  final PlacePhotoData? selectedPhoto;
  final bool isSearching;
  final bool isSearchingNearby;
  final bool isResolving;
  final bool isLoadingPhoto;
  final String? errorMessage;
  final String? nearbyErrorMessage;
  final String? photoErrorMessage;

  LocationSearchState copyWith({
    String? query,
    List<PlaceSearchSuggestion>? suggestions,
    List<NearbyPlaceCandidate>? nearbyCandidates,
    PlaceSearchResult? selectedPlace,
    bool clearSelectedPlace = false,
    PlacePhotoData? selectedPhoto,
    bool clearSelectedPhoto = false,
    bool? isSearching,
    bool? isSearchingNearby,
    bool? isResolving,
    bool? isLoadingPhoto,
    String? errorMessage,
    bool clearError = false,
    String? nearbyErrorMessage,
    bool clearNearbyError = false,
    String? photoErrorMessage,
    bool clearPhotoError = false,
  }) {
    return LocationSearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      nearbyCandidates: nearbyCandidates ?? this.nearbyCandidates,
      selectedPlace: clearSelectedPlace
          ? null
          : selectedPlace ?? this.selectedPlace,
      selectedPhoto: clearSelectedPhoto
          ? null
          : selectedPhoto ?? this.selectedPhoto,
      isSearching: isSearching ?? this.isSearching,
      isSearchingNearby: isSearchingNearby ?? this.isSearchingNearby,
      isResolving: isResolving ?? this.isResolving,
      isLoadingPhoto: isLoadingPhoto ?? this.isLoadingPhoto,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      nearbyErrorMessage: clearNearbyError
          ? null
          : nearbyErrorMessage ?? this.nearbyErrorMessage,
      photoErrorMessage: clearPhotoError
          ? null
          : photoErrorMessage ?? this.photoErrorMessage,
    );
  }
}

class LocationSearchController extends Notifier<LocationSearchState> {
  String _sessionToken = _newSessionToken();
  int _autocompleteRequest = 0;
  int _nearbyRequest = 0;
  int _detailsRequest = 0;
  int _photoRequest = 0;

  @override
  LocationSearchState build() {
    return const LocationSearchState();
  }

  Future<void> search(String query, {GeoCoordinate? locationBias}) async {
    final request = ++_autocompleteRequest;
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      AppDebugLogger.info(
        'LocationSearch',
        'Search ignored because the query has fewer than 2 characters.',
      );
      state = state.copyWith(
        query: query,
        suggestions: const [],
        isSearching: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      query: query,
      isSearching: true,
      suggestions: const [],
      clearError: true,
    );

    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      final suggestions = await repository.autocompletePlaces(
        input: trimmed,
        sessionToken: _sessionToken,
        locationBias: locationBias,
      );
      if (request != _autocompleteRequest || state.query.trim() != trimmed) {
        return;
      }
      state = state.copyWith(
        suggestions: suggestions,
        isSearching: false,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (request != _autocompleteRequest || state.query.trim() != trimmed) {
        return;
      }
      AppDebugLogger.error(
        'LocationSearch',
        'Autocomplete failed for query="$trimmed".',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        suggestions: const [],
        isSearching: false,
        errorMessage: '$error',
      );
    }
  }

  Future<void> searchNearby(GeoCoordinate center) async {
    final request = ++_nearbyRequest;
    _detailsRequest++;
    _photoRequest++;
    state = state.copyWith(
      nearbyCandidates: const [],
      isSearchingNearby: true,
      isResolving: false,
      isLoadingPhoto: false,
      clearSelectedPlace: true,
      clearSelectedPhoto: true,
      clearNearbyError: true,
      clearPhotoError: true,
      clearError: true,
    );

    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      final candidates = await repository.searchNearby(center: center);
      if (request != _nearbyRequest) {
        return;
      }
      state = state.copyWith(
        nearbyCandidates: candidates,
        isSearchingNearby: false,
        clearNearbyError: true,
      );
    } catch (error, stackTrace) {
      if (request != _nearbyRequest) {
        return;
      }
      AppDebugLogger.error(
        'LocationSearch',
        'Nearby Search failed for '
            '${center.latitude},${center.longitude}.',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        nearbyCandidates: const [],
        isSearchingNearby: false,
        nearbyErrorMessage: '$error',
      );
    }
  }

  Future<PlaceSearchResult?> selectSuggestion(
    PlaceSearchSuggestion suggestion,
  ) async {
    final sessionToken = _sessionToken;
    final place = await _resolvePlace(
      googlePlaceId: suggestion.googlePlaceId,
      sessionToken: sessionToken,
    );
    if (place != null && sessionToken == _sessionToken) {
      _sessionToken = _newSessionToken();
    }
    return place;
  }

  Future<PlaceSearchResult?> selectNearbyCandidate(
    NearbyPlaceCandidate candidate,
  ) {
    return _resolvePlace(googlePlaceId: candidate.googlePlaceId);
  }

  void beginManualMapSelection() {
    _detailsRequest++;
    _photoRequest++;
    state = state.copyWith(
      query: '',
      suggestions: const [],
      clearSelectedPlace: true,
      clearSelectedPhoto: true,
      isResolving: false,
      isLoadingPhoto: false,
      clearError: true,
      clearPhotoError: true,
    );
  }

  void clearNearbyResults() {
    _nearbyRequest++;
    state = state.copyWith(
      nearbyCandidates: const [],
      isSearchingNearby: false,
      clearNearbyError: true,
    );
  }

  void clearAutocomplete() {
    final abandonedSessionToken = _sessionToken;
    _autocompleteRequest++;
    _sessionToken = _newSessionToken();
    state = state.copyWith(
      query: '',
      suggestions: const [],
      isSearching: false,
      clearError: true,
    );
    unawaited(_clearSession(abandonedSessionToken));
  }

  void clear() {
    final abandonedSessionToken = _sessionToken;
    _autocompleteRequest++;
    _nearbyRequest++;
    _detailsRequest++;
    _photoRequest++;
    state = const LocationSearchState();
    _sessionToken = _newSessionToken();
    unawaited(_clearSession(abandonedSessionToken));
  }

  Future<PlaceSearchResult?> _resolvePlace({
    required String googlePlaceId,
    String? sessionToken,
  }) async {
    final request = ++_detailsRequest;
    _photoRequest++;
    state = state.copyWith(
      isResolving: true,
      isLoadingPhoto: false,
      suggestions: const [],
      clearSelectedPlace: true,
      clearSelectedPhoto: true,
      clearError: true,
      clearPhotoError: true,
    );
    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      final place = await repository.fetchPlaceDetails(
        googlePlaceId: googlePlaceId,
        sessionToken: sessionToken,
      );
      if (request != _detailsRequest) {
        return null;
      }
      state = state.copyWith(
        query: place.name,
        nearbyCandidates: const [],
        selectedPlace: place,
        isResolving: false,
        clearError: true,
      );
      unawaited(_loadFirstPhoto(place));
      return place;
    } catch (error, stackTrace) {
      if (request != _detailsRequest) {
        return null;
      }
      AppDebugLogger.error(
        'LocationSearch',
        'Place Details failed for placeId=$googlePlaceId.',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(isResolving: false, errorMessage: '$error');
      return null;
    }
  }

  Future<void> _loadFirstPhoto(PlaceSearchResult place) async {
    if (place.photos.isEmpty) {
      return;
    }
    final request = ++_photoRequest;
    state = state.copyWith(
      isLoadingPhoto: true,
      clearSelectedPhoto: true,
      clearPhotoError: true,
    );
    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      final photo = await repository.fetchPlacePhoto(photo: place.photos.first);
      if (request != _photoRequest ||
          state.selectedPlace?.googlePlaceId != place.googlePlaceId) {
        return;
      }
      state = state.copyWith(
        selectedPhoto: photo,
        isLoadingPhoto: false,
        clearPhotoError: true,
      );
    } catch (error, stackTrace) {
      if (request != _photoRequest ||
          state.selectedPlace?.googlePlaceId != place.googlePlaceId) {
        return;
      }
      AppDebugLogger.error(
        'LocationSearch',
        'Place Photo failed for placeId=${place.googlePlaceId}.',
        error: error,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoadingPhoto: false,
        photoErrorMessage: '$error',
      );
    }
  }

  Future<void> _clearSession(String sessionToken) async {
    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      await repository.clearSession(sessionToken);
    } catch (error, stackTrace) {
      AppDebugLogger.error(
        'LocationSearch',
        'Failed to release an abandoned autocomplete session.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static String _newSessionToken() {
    return 'places-${DateTime.now().microsecondsSinceEpoch}';
  }
}
