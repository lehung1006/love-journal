import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/modal_bottom_sheet.dart';
import '../../application/providers/map_providers.dart';
import '../../application/state/map_search_controller.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({required this.data, required this.onMemoryTap, super.key});

  final JournalData data;
  final ValueChanged<Memory> onMemoryTap;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  GoogleMapController? _mapController;
  bool _isSettingSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final config = ref.watch(mapServiceConfigProvider);
    final searchState = ref.watch(mapSearchControllerProvider);
    final hasMapKey = config.hasGoogleMapsApiKey;

    return AppScaffold(
      safeBottom: false,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: hasMapKey
                ? _GoogleJourneyMap(
                    places: widget.data.places,
                    selectedPlace: searchState.selectedPlace,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onPlaceTap: _showPlace,
                  )
                : _MapKeyFallback(
                    places: widget.data.places,
                    onPlaceTap: _showPlace,
                  ),
          ),
          Positioned(
            left: AppSpacing.screenX,
            top: AppSpacing.screenTop,
            right: AppSpacing.screenX,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapHeader(onRecenter: hasMapKey ? _recenterMap : null),
                const SizedBox(height: AppSpacing.s),
                _MapSearchPanel(
                  controller: _searchController,
                  enabled: hasMapKey,
                  state: searchState,
                  onClear: _clearSearch,
                  onSubmit: _searchNow,
                  onSuggestionTap: _selectSuggestion,
                ),
              ],
            ),
          ),
          if (!hasMapKey)
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: 112,
              child: EmptyStateCard(
                title: l10n.mapApiKeyMissingTitle,
                body: l10n.mapApiKeyMissingBody,
              ),
            )
          else if (searchState.selectedPlace != null)
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: 96,
              child: _SelectedPlaceCard(
                place: searchState.selectedPlace!,
                onClose: _clearSearch,
              ),
            )
          else
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: 96,
              child: _SavedPlacesRail(
                data: widget.data,
                onPlaceTap: (place) {
                  _animateTo(
                    GeoCoordinate(
                      latitude: place.latitude,
                      longitude: place.longitude,
                    ),
                    zoom: 13,
                  );
                  _showPlace(place);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _handleSearchChanged() {
    if (_isSettingSearchText) {
      return;
    }
    setState(() {});
    _searchDebounce?.cancel();
    final query = _searchController.text;
    if (query.trim().length < 2) {
      unawaited(ref.read(mapSearchControllerProvider.notifier).search(query));
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 360), () {
      _searchNow(query);
    });
  }

  void _searchNow([String? value]) {
    final query = value ?? _searchController.text;
    if (query.trim().length < 2) {
      return;
    }
    unawaited(
      ref
          .read(mapSearchControllerProvider.notifier)
          .search(query, locationBias: _placesCenter()),
    );
  }

  Future<void> _selectSuggestion(PlaceSearchSuggestion suggestion) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchDebounce?.cancel();
    final place = await ref
        .read(mapSearchControllerProvider.notifier)
        .selectSuggestion(suggestion);
    if (!mounted || place == null) {
      return;
    }
    _setSearchText(place.name);
    await _animateTo(place.coordinate, zoom: 15);
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _setSearchText('');
    ref.read(mapSearchControllerProvider.notifier).clear();
  }

  void _setSearchText(String text) {
    _isSettingSearchText = true;
    _searchController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _isSettingSearchText = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _recenterMap() {
    final places = widget.data.places;
    return _animateTo(_placesCenter(), zoom: places.length <= 1 ? 13 : 6.4);
  }

  Future<void> _animateTo(
    GeoCoordinate coordinate, {
    required double zoom,
  }) async {
    final controller = _mapController;
    if (controller == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(coordinate.latitude, coordinate.longitude),
        zoom,
      ),
    );
  }

  GeoCoordinate _placesCenter() {
    final places = widget.data.places;
    if (places.isEmpty) {
      return const GeoCoordinate(latitude: 10.7769, longitude: 106.7009);
    }

    final latitude =
        places.fold<double>(0, (sum, place) => sum + place.latitude) /
        places.length;
    final longitude =
        places.fold<double>(0, (sum, place) => sum + place.longitude) /
        places.length;

    return GeoCoordinate(latitude: latitude, longitude: longitude);
  }

  void _showPlace(Place place) {
    final memories = widget.data.memoriesForPlace(place);

    showUnfocusedModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return PlacePreviewSheet(
          place: place,
          memories: memories,
          onOpen: () {
            Navigator.of(context).pop();
            if (memories.isNotEmpty) {
              widget.onMemoryTap(memories.first);
            }
          },
        );
      },
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.onRecenter});

  final VoidCallback? onRecenter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FloatingSurface(
      child: TopBar(
        kicker: l10n.mapKicker,
        title: l10n.mapTitle,
        trailing: AppCircleButton(
          icon: Icons.my_location_rounded,
          tooltip: l10n.mapRecenterTooltip,
          onPressed: onRecenter,
        ),
      ),
    );
  }
}

class _MapSearchPanel extends StatelessWidget {
  const _MapSearchPanel({
    required this.controller,
    required this.enabled,
    required this.state,
    required this.onClear,
    required this.onSubmit,
    required this.onSuggestionTap,
  });

  final TextEditingController controller;
  final bool enabled;
  final MapSearchState state;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmit;
  final ValueChanged<PlaceSearchSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasQuery = controller.text.trim().isNotEmpty;
    final shouldShowResults =
        enabled &&
        (state.isSearching ||
            state.isResolving ||
            state.errorMessage != null ||
            state.suggestions.isNotEmpty ||
            (state.query.trim().length >= 2 &&
                !state.isSearching &&
                state.selectedPlace == null));

    return _FloatingSurface(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.s),
                Icon(
                  Icons.search_rounded,
                  color: enabled ? AppColors.rose : AppColors.mutedLight,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSubmit,
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: enabled
                          ? l10n.mapSearchHint
                          : l10n.mapSearchDisabledHint,
                      hintStyle: AppTextStyles.bodyM.copyWith(
                        color: AppColors.mutedLight,
                      ),
                    ),
                  ),
                ),
                if (hasQuery)
                  IconButton(
                    tooltip: l10n.mapSearchClearTooltip,
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.muted,
                  )
                else
                  const SizedBox(width: AppSpacing.s),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: shouldShowResults
                ? _SearchResults(state: state, onSuggestionTap: onSuggestionTap)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onSuggestionTap});

  final MapSearchState state;
  final ValueChanged<PlaceSearchSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    Widget child;
    if (state.isSearching || state.isResolving) {
      child = _SearchMessage(
        icon: const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.rose,
          ),
        ),
        label: l10n.mapSearchLoading,
      );
    } else if (state.errorMessage != null) {
      child = _SearchMessage(
        icon: const Icon(
          Icons.error_outline_rounded,
          color: AppColors.danger,
          size: 18,
        ),
        label: l10n.mapSearchError,
      );
    } else if (state.suggestions.isEmpty) {
      child = _SearchMessage(
        icon: const Icon(
          Icons.search_off_rounded,
          color: AppColors.muted,
          size: 18,
        ),
        label: l10n.mapSearchEmpty,
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final suggestion in state.suggestions)
            _SuggestionTile(
              suggestion: suggestion,
              onTap: () => onSuggestionTap(suggestion),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s,
              AppSpacing.xs,
              AppSpacing.s,
              AppSpacing.s,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.mapSearchPoweredByGoogle,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.mutedLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: child,
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.suggestion, required this.onTap});

  final PlaceSearchSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: AppColors.rose,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.primaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (suggestion.secondaryText != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        suggestion.secondaryText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  const _SearchMessage({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s),
      child: Row(
        children: [
          icon,
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleJourneyMap extends StatelessWidget {
  const _GoogleJourneyMap({
    required this.places,
    required this.selectedPlace,
    required this.onMapCreated,
    required this.onPlaceTap,
  });

  final List<Place> places;
  final PlaceSearchResult? selectedPlace;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<Place> onPlaceTap;

  @override
  Widget build(BuildContext context) {
    final center = _centerForPlaces(places);
    final selected = selectedPlace;

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: places.length <= 1 ? 13 : 6.4,
      ),
      markers: {
        for (final place in places)
          Marker(
            markerId: MarkerId('place-${place.id}'),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(title: place.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(342),
            onTap: () => onPlaceTap(place),
          ),
        if (selected != null)
          Marker(
            markerId: MarkerId('search-${selected.placeId}'),
            position: LatLng(
              selected.coordinate.latitude,
              selected.coordinate.longitude,
            ),
            infoWindow: InfoWindow(
              title: selected.name,
              snippet: selected.formattedAddress,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(196),
          ),
      },
      onMapCreated: onMapCreated,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  LatLng _centerForPlaces(List<Place> places) {
    if (places.isEmpty) {
      return const LatLng(10.7769, 106.7009);
    }

    final latitude =
        places.fold<double>(0, (sum, place) => sum + place.latitude) /
        places.length;
    final longitude =
        places.fold<double>(0, (sum, place) => sum + place.longitude) /
        places.length;

    return LatLng(latitude, longitude);
  }
}

class _MapKeyFallback extends StatelessWidget {
  const _MapKeyFallback({required this.places, required this.onPlaceTap});

  final List<Place> places;
  final ValueChanged<Place> onPlaceTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7EFE9),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _MapWashPainter()),
          for (final entry in places.asMap().entries)
            _PlacePin(
              place: entry.value,
              alignment: _pinAlignment(entry.key),
              onTap: () => onPlaceTap(entry.value),
            ),
        ],
      ),
    );
  }

  Alignment _pinAlignment(int index) {
    const positions = [
      Alignment(-.54, -.36),
      Alignment(.24, -.12),
      Alignment(-.16, .28),
      Alignment(.56, .46),
    ];
    return positions[index % positions.length];
  }
}

class _SavedPlacesRail extends StatelessWidget {
  const _SavedPlacesRail({required this.data, required this.onPlaceTap});

  final JournalData data;
  final ValueChanged<Place> onPlaceTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final places = data.places;
    if (places.isEmpty) {
      return EmptyStateCard(
        title: l10n.mapNoPlacesTitle,
        body: l10n.mapNoPlacesBody,
      );
    }

    return _FloatingSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.mapSavedPlacesTitle,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.roseDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final place = places[index];
                final memories = data.memoriesForPlace(place);
                return _SavedPlaceChip(
                  place: place,
                  memoryCount: memories.length,
                  onTap: () => onPlaceTap(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPlaceChip extends StatelessWidget {
  const _SavedPlaceChip({
    required this.place,
    required this.memoryCount,
    required this.onTap,
  });

  final Place place;
  final int memoryCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surfaceWarm,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.rose.withValues(alpha: .16)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_rounded,
                color: AppColors.rose,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    l10n.mapSavedPlaceMemoryCount(memoryCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedPlaceCard extends StatelessWidget {
  const _SelectedPlaceCard({required this.place, required this.onClose});

  final PlaceSearchResult place;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _FloatingSurface(
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.place_rounded,
              color: AppColors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.mapSelectedPlaceTitle,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.roseDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  place.formattedAddress ??
                      l10n.mapSelectedPlaceAddressFallback,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.mapSelectedPlaceBody,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.mutedLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AppCircleButton(
            icon: Icons.close_rounded,
            tooltip: l10n.mapSelectedPlaceCloseTooltip,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _FloatingSurface extends StatelessWidget {
  const _FloatingSurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: .94),
          border: Border.all(color: AppColors.line),
          boxShadow: AppShadows.card,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _PlacePin extends StatelessWidget {
  const _PlacePin({
    required this.place,
    required this.alignment,
    required this.onTap,
  });

  final Place place;
  final Alignment alignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.rose,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.rose.withValues(alpha: .28),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              constraints: const BoxConstraints(maxWidth: 132),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .86),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                place.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapWashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x6BFFFFFF), Color(0x3D3F7B84)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final routePaint = Paint()
      ..color = AppColors.rose.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final route = Path()
      ..moveTo(size.width * .18, size.height * .28)
      ..cubicTo(
        size.width * .76,
        size.height * .05,
        size.width * .68,
        size.height * .52,
        size.width * .36,
        size.height * .55,
      )
      ..cubicTo(
        size.width * .1,
        size.height * .58,
        size.width * .52,
        size.height * .78,
        size.width * .72,
        size.height * .72,
      );
    canvas.drawPath(route, routePaint);

    final softLinePaint = Paint()
      ..color = AppColors.teal.withValues(alpha: .2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    canvas.drawLine(
      Offset(size.width * -.08, size.height * .18),
      Offset(size.width * .94, size.height * .9),
      softLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
