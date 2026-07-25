import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../application/state/map_search_controller.dart';
import '../../domain/entities/place_search.dart';
import 'buttons_and_chips.dart';

class LocationPickerSurface extends StatelessWidget {
  const LocationPickerSurface({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.s),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class LocationSearchPanel extends StatelessWidget {
  const LocationSearchPanel({
    required this.controller,
    required this.focusNode,
    required this.state,
    required this.onClear,
    required this.onSuggestionTap,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final LocationSearchState state;
  final VoidCallback onClear;
  final ValueChanged<PlaceSearchSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasQuery = controller.text.trim().isNotEmpty;
    final shouldShowResults =
        state.isSearching ||
        state.isResolving ||
        state.errorMessage != null ||
        state.suggestions.isNotEmpty ||
        (state.query.trim().length >= 2 &&
            state.query.trim() != state.selectedPlace?.name.trim());

    return LocationPickerSurface(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.s),
                const Icon(Icons.search_rounded, color: AppColors.rose),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextField(
                    key: const ValueKey('location-picker-search-field'),
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: l10n.locationPickerSearchHint,
                    ),
                  ),
                ),
                if (hasQuery)
                  IconButton(
                    tooltip: l10n.locationPickerSearchClearTooltip,
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  )
                else
                  const SizedBox(width: AppSpacing.s),
              ],
            ),
          ),
          if (shouldShowResults)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 248),
              child: _SearchResults(
                state: state,
                onSuggestionTap: onSuggestionTap,
              ),
            ),
        ],
      ),
    );
  }
}

class LocationMapToolbar extends StatelessWidget {
  const LocationMapToolbar({
    required this.selectionMode,
    required this.hasSelection,
    required this.onSelectionModeChanged,
    required this.onReset,
    super.key,
  });

  final bool selectionMode;
  final bool hasSelection;
  final ValueChanged<bool> onSelectionModeChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LocationPickerSurface(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<bool>(
              key: const ValueKey('location-picker-map-mode-control'),
              segments: [
                ButtonSegment<bool>(
                  value: false,
                  label: _MapModeLabel(
                    icon: Icons.pan_tool_alt_rounded,
                    text: l10n.locationPickerMapBrowseMode,
                  ),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: _MapModeLabel(
                    icon: Icons.touch_app_rounded,
                    text: l10n.locationPickerMapSelectMode,
                  ),
                ),
              ],
              selected: {selectionMode},
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
                padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                ),
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                  AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w800),
                ),
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.roseDark
                      : AppColors.muted,
                ),
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppColors.surfaceWarm
                      : AppColors.surface,
                ),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: AppColors.line),
                ),
              ),
              onSelectionChanged: (selection) =>
                  onSelectionModeChanged(selection.single),
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: AppSpacing.xxs),
            SizedBox.square(
              dimension: 44,
              child: IconButton(
                key: const ValueKey('location-picker-map-reset'),
                tooltip: l10n.locationPickerMapReset,
                padding: EdgeInsets.zero,
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapModeLabel extends StatelessWidget {
  const _MapModeLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17),
          const SizedBox(width: AppSpacing.xxs),
          Text(text, maxLines: 1, softWrap: false),
        ],
      ),
    );
  }
}

class LocationMapBottomPanel extends StatelessWidget {
  const LocationMapBottomPanel({
    required this.state,
    required this.markerCoordinate,
    required this.selectionMode,
    required this.onCandidateTap,
    required this.onUseManualCoordinate,
    required this.onUseSelectedPlace,
    required this.onOpenGoogleMaps,
    required this.onOpenAttribution,
    super.key,
  });

  final LocationSearchState state;
  final GeoCoordinate? markerCoordinate;
  final bool selectionMode;
  final ValueChanged<NearbyPlaceCandidate> onCandidateTap;
  final VoidCallback onUseManualCoordinate;
  final VoidCallback onUseSelectedPlace;
  final VoidCallback onOpenGoogleMaps;
  final ValueChanged<PlaceAuthorAttribution> onOpenAttribution;

  @override
  Widget build(BuildContext context) {
    if (state.isResolving) {
      return LocationPickerSurface(
        child: _PanelStatus(
          loading: true,
          icon: Icons.place_rounded,
          title: context.l10n.locationPickerResolvingPlace,
        ),
      );
    }
    final selectedPlace = state.selectedPlace;
    if (selectedPlace != null) {
      return LocationPickerSurface(
        padding: EdgeInsets.zero,
        child: _SelectedPlacePreview(
          place: selectedPlace,
          photo: state.selectedPhoto,
          isLoadingPhoto: state.isLoadingPhoto,
          onUsePlace: onUseSelectedPlace,
          onOpenGoogleMaps: onOpenGoogleMaps,
          onOpenAttribution: onOpenAttribution,
        ),
      );
    }
    if (markerCoordinate == null) {
      return LocationPickerSurface(
        child: _PanelStatus(
          icon: selectionMode
              ? Icons.touch_app_rounded
              : Icons.pan_tool_alt_rounded,
          title: selectionMode
              ? context.l10n.locationPickerMapTapHelper
              : context.l10n.locationPickerMapBrowseHelper,
        ),
      );
    }
    return LocationPickerSurface(
      padding: EdgeInsets.zero,
      child: _NearbyPlacesPanel(
        state: state,
        markerCoordinate: markerCoordinate!,
        onCandidateTap: onCandidateTap,
        onUseManualCoordinate: onUseManualCoordinate,
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state, required this.onSuggestionTap});

  final LocationSearchState state;
  final ValueChanged<PlaceSearchSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget child;
    if (state.isSearching || state.isResolving) {
      child = _SearchStatus(
        icon: const SizedBox.square(
          dimension: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.rose,
          ),
        ),
        label: l10n.locationPickerSearchLoading,
      );
    } else if (state.errorMessage != null) {
      final errorMessage = state.errorMessage!;
      child = _SearchStatus(
        icon: const Icon(Icons.error_outline_rounded, color: AppColors.danger),
        label: errorMessage.toLowerCase().contains('permission')
            ? l10n.locationPickerSearchPermissionDenied
            : errorMessage,
      );
    } else if (state.suggestions.isEmpty) {
      child = _SearchStatus(
        icon: const Icon(Icons.search_off_rounded, color: AppColors.muted),
        label: l10n.locationPickerSearchEmpty,
      );
    } else {
      child = ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [
          for (final suggestion in state.suggestions)
            ListTile(
              dense: true,
              leading: const Icon(Icons.place_rounded, color: AppColors.rose),
              title: Text(
                suggestion.primaryText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: suggestion.secondaryText == null
                  ? null
                  : Text(
                      suggestion.secondaryText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () => onSuggestionTap(suggestion),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Text(
              l10n.locationPickerPoweredByGoogle,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.mutedLight,
                fontWeight: FontWeight.w700,
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

class _NearbyPlacesPanel extends StatelessWidget {
  const _NearbyPlacesPanel({
    required this.state,
    required this.markerCoordinate,
    required this.onCandidateTap,
    required this.onUseManualCoordinate,
  });

  final LocationSearchState state;
  final GeoCoordinate markerCoordinate;
  final ValueChanged<NearbyPlaceCandidate> onCandidateTap;
  final VoidCallback onUseManualCoordinate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final candidates = state.nearbyCandidates;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s,
            AppSpacing.s,
            AppSpacing.s,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.near_me_rounded,
                color: AppColors.teal,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  state.isSearchingNearby
                      ? l10n.locationPickerNearbyLoading
                      : l10n.locationPickerNearbyTitle,
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${markerCoordinate.latitude.toStringAsFixed(4)}, '
                '${markerCoordinate.longitude.toStringAsFixed(4)}',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.mutedLight,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.line),
        if (state.isSearchingNearby)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.l),
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.rose,
            ),
          )
        else if (state.nearbyErrorMessage != null || candidates.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Text(
              state.nearbyErrorMessage != null
                  ? l10n.locationPickerNearbyError
                  : l10n.locationPickerNearbyEmpty,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
            ),
          )
        else
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: candidates.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.line),
              itemBuilder: (context, index) {
                final candidate = candidates[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.teal.withValues(alpha: .12),
                    foregroundColor: AppColors.teal,
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.bodyS.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  title: Text(
                    candidate.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyM.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    candidate.formattedAddress ??
                        candidate.primaryTypeDisplayName ??
                        l10n.locationPickerNearbyAddressFallback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  onTap: () => onCandidateTap(candidate),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: SecondaryButton(
            label: l10n.locationPickerUseManualCoordinate,
            icon: Icons.my_location_rounded,
            onPressed: onUseManualCoordinate,
          ),
        ),
      ],
    );
  }
}

class _SelectedPlacePreview extends StatelessWidget {
  const _SelectedPlacePreview({
    required this.place,
    required this.photo,
    required this.isLoadingPhoto,
    required this.onUsePlace,
    required this.onOpenGoogleMaps,
    required this.onOpenAttribution,
  });

  final PlaceSearchResult place;
  final PlacePhotoData? photo;
  final bool isLoadingPhoto;
  final VoidCallback onUsePlace;
  final VoidCallback onOpenGoogleMaps;
  final ValueChanged<PlaceAuthorAttribution> onOpenAttribution;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final attribution = photo == null
        ? null
        : place.photos.firstOrNull?.authorAttributions.firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 116,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.s - 1),
            ),
            child: ColoredBox(
              color: AppColors.surfaceWarm,
              child: photo != null
                  ? Image.memory(
                      photo!.bytes,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  : Center(
                      child: isLoadingPhoto
                          ? const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.rose,
                            )
                          : const Icon(
                              Icons.location_city_rounded,
                              size: 34,
                              color: AppColors.rose,
                            ),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s,
            AppSpacing.s,
            AppSpacing.s,
            AppSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyL.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (place.primaryTypeDisplayName != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  place.primaryTypeDisplayName!,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.teal),
                ),
              ],
              if (place.formattedAddress != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  place.formattedAddress!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
                ),
              ],
              if (place.businessStatus != PlaceBusinessStatus.unknown) ...[
                const SizedBox(height: AppSpacing.xs),
                _BusinessStatusLabel(status: place.businessStatus),
              ],
              if (attribution != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                TextButton(
                  onPressed: attribution.uri == null
                      ? null
                      : () => onOpenAttribution(attribution),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.locationPickerPhotoAttribution(
                      attribution.displayName,
                    ),
                  ),
                ),
              ],
              Row(
                children: [
                  if (place.googleMapsUri != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onOpenGoogleMaps,
                        icon: const Icon(Icons.open_in_new_rounded, size: 17),
                        label: Text(l10n.locationPickerOpenGoogleMaps),
                      ),
                    ),
                  if (place.googleMapsUri != null)
                    const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: l10n.locationPickerUseSelectedPlace,
                      icon: Icons.check_rounded,
                      onPressed: onUsePlace,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BusinessStatusLabel extends StatelessWidget {
  const _BusinessStatusLabel({required this.status});

  final PlaceBusinessStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      PlaceBusinessStatus.operational => (
        context.l10n.locationPickerBusinessOperational,
        AppColors.success,
      ),
      PlaceBusinessStatus.closedTemporarily => (
        context.l10n.locationPickerBusinessClosedTemporarily,
        AppColors.warning,
      ),
      PlaceBusinessStatus.closedPermanently => (
        context.l10n.locationPickerBusinessClosedPermanently,
        AppColors.danger,
      ),
      PlaceBusinessStatus.unknown => ('', AppColors.muted),
    };
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PanelStatus extends StatelessWidget {
  const _PanelStatus({
    required this.icon,
    required this.title,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (loading)
          const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.rose,
            ),
          )
        else
          Icon(icon, color: AppColors.teal, size: 20),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _SearchStatus extends StatelessWidget {
  const _SearchStatus({required this.icon, required this.label});

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
