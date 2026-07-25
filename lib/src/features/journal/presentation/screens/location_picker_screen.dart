import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/map_service_config.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/providers/map_providers.dart';
import '../../application/state/map_search_controller.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../components/location_picker_map_components.dart';

enum _LocationPickerMode { choose, search, name }

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    required this.data,
    required this.onSelected,
    required this.onCancel,
    this.initialSelection,
    super.key,
  });

  final JournalData data;
  final MemoryLocationSelection? initialSelection;
  final ValueChanged<MemoryLocationSelection> onSelected;
  final VoidCallback onCancel;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  static const _fallbackCenter = GeoCoordinate(
    latitude: 10.7769,
    longitude: 106.7009,
  );

  final _searchTextController = TextEditingController();
  final _nameController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  GoogleMapController? _mapController;

  _LocationPickerMode _mode = _LocationPickerMode.choose;
  MemoryLocationDraft? _draft;
  GeoCoordinate? _markerCoordinate;
  late GeoCoordinate _cameraTarget;
  bool _settingSearchText = false;
  bool _isMapSelectionMode = false;
  bool _searchHasFocus = false;

  @override
  void initState() {
    super.initState();
    _cameraTarget = _initialCoordinate();
    _restoreInitialMapSelection();
    _searchTextController.addListener(_handleSearchChanged);
    _searchFocusNode.addListener(_handleSearchFocusChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchTextController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _searchFocusNode
      ..removeListener(_handleSearchFocusChanged)
      ..dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey('location-picker-${_mode.name}'),
      resizeToAvoidBottomInset: _mode != _LocationPickerMode.search,
      body: switch (_mode) {
        _LocationPickerMode.choose => _buildChooseView(context),
        _LocationPickerMode.search => _buildSearchView(context),
        _LocationPickerMode.name => _buildNameView(context),
      },
    );
  }

  Widget _buildChooseView(BuildContext context) {
    final l10n = context.l10n;
    final selected = _selectedLocation;
    return AppScaffold(
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          AppSpacing.xl,
        ),
        children: [
          TopBar(
            kicker: l10n.locationPickerKicker,
            title: l10n.locationPickerTitle,
            leading: AppCircleButton(
              icon: Icons.arrow_back_rounded,
              tooltip: l10n.locationPickerBackTooltip,
              onPressed: widget.onCancel,
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: AppSpacing.m),
            _SectionTitle(l10n.locationPickerCurrentTitle),
            const SizedBox(height: AppSpacing.xs),
            _LocationSummary(
              name: selected.displayName,
              address:
                  selected.formattedAddress ??
                  l10n.memoryFormLocationAddressFallback,
              icon: Icons.favorite_rounded,
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          _SectionTitle(l10n.locationPickerExistingTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.locationPickerExistingBody,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.s),
          if (widget.data.locations.isEmpty)
            EmptyStateCard(
              title: l10n.locationPickerNoExistingTitle,
              body: l10n.locationPickerNoExistingBody,
            )
          else
            LocationPickerSurface(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final entry in widget.data.locations.asMap().entries)
                    _ExistingLocationTile(
                      location: entry.value,
                      memoryCount: _memoryCount(entry.value.id),
                      selected: selected?.id == entry.value.id,
                      showDivider: entry.key < widget.data.locations.length - 1,
                      onTap: () => widget.onSelected(
                        MemoryLocationSelection.existing(entry.value.id),
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          LocationPickerSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.add_location_alt_rounded,
                      color: AppColors.rose,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        l10n.locationPickerNewTitle,
                        style: AppTextStyles.bodyL.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.locationPickerNewBody,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.m),
                PrimaryButton(
                  label: l10n.locationPickerNewTitle,
                  icon: Icons.map_rounded,
                  onPressed: _openSearch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchView(BuildContext context) {
    final l10n = context.l10n;
    final configState = ref.watch(mapServiceConfigProvider);
    final config = configState.asData?.value ?? const MapServiceConfig();
    final hasMapKey = config.hasGoogleMapsApiKey;
    final isLoading = configState.isLoading && !configState.hasValue;
    final searchState = ref.watch(locationSearchControllerProvider);
    final searchInputActive =
        _searchHasFocus || MediaQuery.viewInsetsOf(context).bottom > 0;
    final searchResultsVisible =
        searchState.isSearching ||
        searchState.isResolving ||
        searchState.errorMessage != null ||
        searchState.suggestions.isNotEmpty ||
        (searchState.query.trim().length >= 2 &&
            searchState.query.trim() != searchState.selectedPlace?.name.trim());
    final markers = _buildMarkers(searchState);

    return AppScaffold(
      safeBottom: false,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.rose),
                  )
                : hasMapKey
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _cameraTarget.latitude,
                        _cameraTarget.longitude,
                      ),
                      zoom: 15,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    onCameraMove: (position) {
                      _cameraTarget = GeoCoordinate(
                        latitude: position.target.latitude,
                        longitude: position.target.longitude,
                      );
                    },
                    onTap: _isMapSelectionMode ? _selectCoordinateOnMap : null,
                    markers: markers,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    padding: EdgeInsets.only(
                      top: 196,
                      bottom: searchInputActive ? 24 : 250,
                    ),
                  )
                : _MissingKeyView(onBack: _backFromSearch),
          ),
          Positioned(
            left: AppSpacing.screenX,
            top: AppSpacing.screenTop,
            right: AppSpacing.screenX,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LocationPickerSurface(
                  child: TopBar(
                    kicker: l10n.locationPickerSearchKicker,
                    title: l10n.locationPickerSearchTitle,
                    leading: AppCircleButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: l10n.locationPickerBackTooltip,
                      onPressed: _backFromSearch,
                    ),
                  ),
                ),
                if (hasMapKey) ...[
                  const SizedBox(height: AppSpacing.s),
                  LocationSearchPanel(
                    controller: _searchTextController,
                    focusNode: _searchFocusNode,
                    state: searchState,
                    onClear: _clearSearch,
                    onSuggestionTap: _selectSuggestion,
                  ),
                  const SizedBox(height: AppSpacing.s),
                  LocationMapToolbar(
                    selectionMode: _isMapSelectionMode,
                    hasSelection: _markerCoordinate != null,
                    onSelectionModeChanged: _setMapSelectionMode,
                    onReset: _resetMapSelection,
                  ),
                ],
              ],
            ),
          ),
          if (hasMapKey && !searchInputActive && !searchResultsVisible)
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.m,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .44,
                ),
                child: LocationMapBottomPanel(
                  state: searchState,
                  markerCoordinate: _markerCoordinate,
                  selectionMode: _isMapSelectionMode,
                  onCandidateTap: _selectNearbyCandidate,
                  onUseManualCoordinate: _continueToName,
                  onUseSelectedPlace: _continueToName,
                  onOpenGoogleMaps: _openSelectedPlaceInGoogleMaps,
                  onOpenAttribution: _openAttribution,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameView(BuildContext context) {
    final l10n = context.l10n;
    final draft = _draft;
    if (draft == null) {
      return const SizedBox.shrink();
    }

    return AppScaffold(
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          AppSpacing.xl,
        ),
        children: [
          TopBar(
            kicker: l10n.locationPickerNameKicker,
            title: l10n.locationPickerNameTitle,
            leading: AppCircleButton(
              icon: Icons.arrow_back_rounded,
              tooltip: l10n.locationPickerBackTooltip,
              onPressed: () =>
                  setState(() => _mode = _LocationPickerMode.search),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          LocationPickerSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.locationPickerNameLabel,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.roseDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.locationPickerNameHint,
                  ),
                ),
                if (draft.formattedAddress != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  _MetadataRow(
                    icon: Icons.place_outlined,
                    label: l10n.locationPickerAddressLabel,
                    value: draft.formattedAddress!,
                  ),
                ],
                const SizedBox(height: AppSpacing.s),
                _MetadataRow(
                  icon: Icons.gps_fixed_rounded,
                  label: l10n.locationPickerCoordinateLabel,
                  value:
                      '${draft.latitude.toStringAsFixed(5)}, ${draft.longitude.toStringAsFixed(5)}',
                ),
                const SizedBox(height: AppSpacing.l),
                PrimaryButton(
                  label: l10n.locationPickerSave,
                  icon: Icons.check_rounded,
                  onPressed: _saveDraft,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  MemoryLocation? get _selectedLocation {
    final selection = widget.initialSelection;
    if (selection == null) {
      return null;
    }
    final existing = widget.data.locationByIdOrNull(
      selection.existingLocationId,
    );
    if (existing != null) {
      return existing;
    }
    final draft = selection.draftLocation;
    if (draft == null) {
      return null;
    }
    final now = DateTime.now();
    return MemoryLocation(
      id: 'draft-location',
      displayName: draft.displayName,
      formattedAddress: draft.formattedAddress,
      latitude: draft.latitude,
      longitude: draft.longitude,
      googlePlaceId: draft.googlePlaceId,
      source: draft.source,
      createdAt: now,
      updatedAt: now,
    );
  }

  GeoCoordinate _initialCoordinate() {
    final selected = _selectedLocation;
    if (selected != null) {
      return GeoCoordinate(
        latitude: selected.latitude,
        longitude: selected.longitude,
      );
    }
    if (widget.data.locations.isNotEmpty) {
      final first = widget.data.locations.first;
      return GeoCoordinate(
        latitude: first.latitude,
        longitude: first.longitude,
      );
    }
    return _fallbackCenter;
  }

  int _memoryCount(String locationId) {
    return widget.data.visibleMemories
        .where((memory) => memory.locationId == locationId)
        .length;
  }

  Set<Marker> _buildMarkers(LocationSearchState searchState) {
    final markers = <Marker>{};
    final markerCoordinate = _markerCoordinate;
    if (markerCoordinate != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected-location'),
          position: LatLng(
            markerCoordinate.latitude,
            markerCoordinate.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          draggable: _isMapSelectionMode,
          onDragEnd: _selectCoordinateOnMap,
        ),
      );
    }
    if (_isMapSelectionMode) {
      for (final candidate in searchState.nearbyCandidates) {
        markers.add(
          Marker(
            markerId: MarkerId('nearby-${candidate.googlePlaceId}'),
            position: LatLng(
              candidate.coordinate.latitude,
              candidate.coordinate.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
            infoWindow: InfoWindow(
              title: candidate.name,
              snippet:
                  candidate.formattedAddress ??
                  candidate.primaryTypeDisplayName,
            ),
            onTap: () => unawaited(_selectNearbyCandidate(candidate)),
          ),
        );
      }
    }
    return markers;
  }

  void _openSearch() {
    final selected = _selectedLocation;
    if (selected != null) {
      _cameraTarget = GeoCoordinate(
        latitude: selected.latitude,
        longitude: selected.longitude,
      );
    }
    ref.read(locationSearchControllerProvider.notifier).clear();
    _restoreInitialMapSelection();
    setState(() {
      _mode = _LocationPickerMode.search;
      _isMapSelectionMode = false;
    });
  }

  void _backFromSearch() {
    _searchFocusNode.unfocus();
    _searchDebounce?.cancel();
    _setSearchText('');
    ref.read(locationSearchControllerProvider.notifier).clear();
    _restoreInitialMapSelection();
    setState(() {
      _mode = _LocationPickerMode.choose;
      _isMapSelectionMode = false;
    });
  }

  void _handleSearchChanged() {
    if (_settingSearchText || _mode != _LocationPickerMode.search) {
      return;
    }
    setState(() {});
    _searchDebounce?.cancel();
    final query = _searchTextController.text;
    if (query.trim().length < 2) {
      unawaited(
        ref.read(locationSearchControllerProvider.notifier).search(query),
      );
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 360), () {
      unawaited(
        ref
            .read(locationSearchControllerProvider.notifier)
            .search(query, locationBias: _cameraTarget),
      );
    });
  }

  void _handleSearchFocusChanged() {
    final hasFocus = _searchFocusNode.hasFocus;
    if (!mounted || _searchHasFocus == hasFocus) {
      return;
    }
    setState(() => _searchHasFocus = hasFocus);
  }

  Future<void> _selectSuggestion(PlaceSearchSuggestion suggestion) async {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchDebounce?.cancel();
    final result = await ref
        .read(locationSearchControllerProvider.notifier)
        .selectSuggestion(suggestion);
    if (!mounted || result == null) {
      return;
    }
    await _applyGooglePlace(result);
  }

  Future<void> _selectNearbyCandidate(NearbyPlaceCandidate candidate) async {
    final result = await ref
        .read(locationSearchControllerProvider.notifier)
        .selectNearbyCandidate(candidate);
    if (!mounted || result == null) {
      return;
    }
    await _applyGooglePlace(result);
  }

  Future<void> _applyGooglePlace(PlaceSearchResult result) async {
    _setSearchText(result.name);
    _nameController.text = result.name;
    _cameraTarget = result.coordinate;
    setState(() {
      _markerCoordinate = result.coordinate;
      _isMapSelectionMode = false;
      _draft = MemoryLocationDraft(
        displayName: result.name,
        formattedAddress: result.formattedAddress,
        latitude: result.coordinate.latitude,
        longitude: result.coordinate.longitude,
        googlePlaceId: result.googlePlaceId,
        source: MemoryLocationSource.googlePlaces,
      );
    });
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(result.coordinate.latitude, result.coordinate.longitude),
        16,
      ),
    );
  }

  void _selectCoordinateOnMap(LatLng position) {
    FocusManager.instance.primaryFocus?.unfocus();
    _searchDebounce?.cancel();
    final coordinate = GeoCoordinate(
      latitude: position.latitude,
      longitude: position.longitude,
    );
    _setSearchText('');
    _nameController.clear();
    ref
        .read(locationSearchControllerProvider.notifier)
        .beginManualMapSelection();
    setState(() {
      _cameraTarget = coordinate;
      _markerCoordinate = coordinate;
      _draft = MemoryLocationDraft(
        displayName: '',
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
        source: MemoryLocationSource.manual,
      );
    });
    unawaited(
      ref
          .read(locationSearchControllerProvider.notifier)
          .searchNearby(coordinate),
    );
  }

  void _setMapSelectionMode(bool enabled) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!enabled) {
      ref.read(locationSearchControllerProvider.notifier).clearNearbyResults();
    }
    setState(() => _isMapSelectionMode = enabled);
  }

  void _resetMapSelection() {
    _searchDebounce?.cancel();
    _setSearchText('');
    ref.read(locationSearchControllerProvider.notifier).clear();
    _restoreInitialMapSelection();
    setState(() => _isMapSelectionMode = false);
    final marker = _markerCoordinate;
    if (marker != null) {
      _cameraTarget = marker;
      unawaited(
        _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(marker.latitude, marker.longitude),
                15,
              ),
            ) ??
            Future<void>.value(),
      );
    }
  }

  void _restoreInitialMapSelection() {
    final selected = _selectedLocation;
    final initialDraft = widget.initialSelection?.draftLocation;
    _draft = initialDraft;
    _markerCoordinate = selected == null
        ? null
        : GeoCoordinate(
            latitude: selected.latitude,
            longitude: selected.longitude,
          );
    _nameController.text = initialDraft?.displayName ?? '';
  }

  void _continueToName() {
    final draft = _draft;
    if (draft == null) {
      return;
    }
    _searchFocusNode.unfocus();
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = draft.displayName;
    }
    setState(() => _mode = _LocationPickerMode.name);
  }

  void _saveDraft() {
    final l10n = context.l10n;
    final draft = _draft;
    final name = _nameController.text.trim();
    if (draft == null || name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.locationPickerNameRequired)));
      return;
    }
    widget.onSelected(
      MemoryLocationSelection.draft(draft.copyWith(displayName: name)),
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _setSearchText('');
    ref.read(locationSearchControllerProvider.notifier).clearAutocomplete();
  }

  Future<void> _openSelectedPlaceInGoogleMaps() async {
    final uri = ref
        .read(locationSearchControllerProvider)
        .selectedPlace
        ?.googleMapsUri;
    if (uri == null) {
      return;
    }
    await _openExternalUri(uri);
  }

  Future<void> _openAttribution(PlaceAuthorAttribution attribution) async {
    final uri = attribution.uri;
    if (uri == null) {
      return;
    }
    await _openExternalUri(uri);
  }

  Future<void> _openExternalUri(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return;
    }
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.locationPickerOpenLinkError)),
      );
    }
  }

  void _setSearchText(String value) {
    _settingSearchText = true;
    _searchTextController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _settingSearchText = false;
    if (mounted) {
      setState(() {});
    }
  }
}

class _MissingKeyView extends StatelessWidget {
  const _MissingKeyView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.paper,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenX),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyStateCard(
                title: l10n.locationPickerMissingKeyTitle,
                body: l10n.locationPickerMissingKeyBody,
              ),
              const SizedBox(height: AppSpacing.m),
              SecondaryButton(
                label: l10n.locationPickerBackTooltip,
                icon: Icons.arrow_back_rounded,
                onPressed: onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExistingLocationTile extends StatelessWidget {
  const _ExistingLocationTile({
    required this.location,
    required this.memoryCount,
    required this.selected,
    required this.showDivider,
    required this.onTap,
  });

  final MemoryLocation location;
  final int memoryCount;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xxs,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.surfaceWarm,
            foregroundColor: AppColors.rose,
            child: Icon(
              selected ? Icons.favorite_rounded : Icons.place_rounded,
              size: 19,
            ),
          ),
          title: Text(
            location.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            location.formattedAddress ??
                l10n.locationPickerMemoryCount(memoryCount),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.line),
      ],
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({
    required this.name,
    required this.address,
    required this.icon,
  });

  final String name;
  final String address;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LocationPickerSurface(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceWarm,
            foregroundColor: AppColors.rose,
            child: Icon(icon, size: 19),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyL.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.teal, size: 19),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodyS.copyWith(
        color: AppColors.roseDark,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
