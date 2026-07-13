import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    this.selectedPlace,
    this.isSearching = false,
    this.isResolving = false,
    this.errorMessage,
  });

  final String query;
  final List<PlaceSearchSuggestion> suggestions;
  final PlaceSearchResult? selectedPlace;
  final bool isSearching;
  final bool isResolving;
  final String? errorMessage;

  LocationSearchState copyWith({
    String? query,
    List<PlaceSearchSuggestion>? suggestions,
    PlaceSearchResult? selectedPlace,
    bool clearSelectedPlace = false,
    bool? isSearching,
    bool? isResolving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationSearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      selectedPlace: clearSelectedPlace
          ? null
          : selectedPlace ?? this.selectedPlace,
      isSearching: isSearching ?? this.isSearching,
      isResolving: isResolving ?? this.isResolving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class LocationSearchController extends Notifier<LocationSearchState> {
  String _sessionToken = _newSessionToken();

  @override
  LocationSearchState build() {
    return const LocationSearchState();
  }

  Future<void> search(String query, {GeoCoordinate? locationBias}) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
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
      clearSelectedPlace: true,
      clearError: true,
    );

    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      final suggestions = await repository.autocompletePlaces(
        input: trimmed,
        sessionToken: _sessionToken,
        locationBias: locationBias,
      );
      if (state.query.trim() != trimmed) {
        return;
      }
      state = state.copyWith(
        suggestions: suggestions,
        isSearching: false,
        clearError: true,
      );
    } catch (error) {
      if (state.query.trim() != trimmed) {
        return;
      }
      state = state.copyWith(
        suggestions: const [],
        isSearching: false,
        errorMessage: '$error',
      );
    }
  }

  Future<PlaceSearchResult?> selectSuggestion(
    PlaceSearchSuggestion suggestion,
  ) async {
    state = state.copyWith(isResolving: true, clearError: true);
    try {
      final repository = await ref.read(placeSearchRepositoryProvider.future);
      final place = await repository.fetchPlaceDetails(
        googlePlaceId: suggestion.googlePlaceId,
        sessionToken: _sessionToken,
      );
      _sessionToken = _newSessionToken();
      state = state.copyWith(
        query: place.name,
        suggestions: const [],
        selectedPlace: place,
        isResolving: false,
        clearError: true,
      );
      return place;
    } catch (error) {
      state = state.copyWith(isResolving: false, errorMessage: '$error');
      return null;
    }
  }

  void clear() {
    state = const LocationSearchState();
    _sessionToken = _newSessionToken();
  }

  static String _newSessionToken() {
    return 'places-${DateTime.now().microsecondsSinceEpoch}';
  }
}
