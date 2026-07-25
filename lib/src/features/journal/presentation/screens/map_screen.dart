import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/map_service_config.dart';
import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/modal_bottom_sheet.dart';
import '../../application/providers/map_providers.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../components/location_memory_list_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    required this.data,
    required this.onMemoryTap,
    required this.onAddMemory,
    super.key,
  });

  final JournalData data;
  final ValueChanged<Memory> onMemoryTap;
  final VoidCallback onAddMemory;

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final configState = ref.watch(mapServiceConfigProvider);
    final config = configState.asData?.value ?? const MapServiceConfig();
    final hasMapKey = config.hasGoogleMapsApiKey;
    final isResolvingMapKey = configState.isLoading && !configState.hasValue;
    final groups = widget.data.mapLocationGroups;

    return AppScaffold(
      safeBottom: false,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned.fill(
            child: isResolvingMapKey
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.rose),
                  )
                : hasMapKey
                ? _GoogleMemoryMap(
                    groups: groups,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onLocationTap: _showLocation,
                  )
                : _MapKeyFallback(groups: groups, onLocationTap: _showLocation),
          ),
          Positioned(
            left: AppSpacing.screenX,
            top: AppSpacing.screenTop,
            right: AppSpacing.screenX,
            child: _FloatingSurface(
              child: TopBar(
                kicker: l10n.mapKicker,
                title: l10n.mapTitle,
                trailing: AppCircleButton(
                  icon: Icons.my_location_rounded,
                  tooltip: l10n.mapRecenterTooltip,
                  onPressed: hasMapKey && groups.isNotEmpty
                      ? _recenterMap
                      : null,
                ),
              ),
            ),
          ),
          if (!isResolvingMapKey && !hasMapKey)
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: 112,
              child: EmptyStateCard(
                title: l10n.mapApiKeyMissingTitle,
                body: l10n.mapApiKeyMissingBody,
              ),
            )
          else if (!isResolvingMapKey && groups.isEmpty)
            Positioned(
              left: AppSpacing.screenX,
              right: AppSpacing.screenX,
              bottom: 96,
              child: _FloatingSurface(
                child: Column(
                  children: [
                    EmptyStateCard(
                      title: l10n.mapLocatedEmptyTitle,
                      body: l10n.mapLocatedEmptyBody,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    PrimaryButton(
                      label: l10n.mapLocatedEmptyCta,
                      icon: Icons.add_rounded,
                      onPressed: widget.onAddMemory,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _recenterMap() async {
    final groups = widget.data.mapLocationGroups;
    final controller = _mapController;
    if (controller == null || groups.isEmpty) {
      return;
    }
    final center = _centerForGroups(groups);
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(center, groups.length == 1 ? 14 : 6.4),
    );
  }

  void _showLocation(MemoryLocationGroup group) {
    showUnfocusedModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetContext) {
        return LocationMemoryListSheet(
          group: group,
          onMemoryTap: (memory) {
            Navigator.of(sheetContext).pop();
            widget.onMemoryTap(memory);
          },
        );
      },
    );
  }
}

class _GoogleMemoryMap extends StatelessWidget {
  const _GoogleMemoryMap({
    required this.groups,
    required this.onMapCreated,
    required this.onLocationTap,
  });

  final List<MemoryLocationGroup> groups;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<MemoryLocationGroup> onLocationTap;

  @override
  Widget build(BuildContext context) {
    final center = _centerForGroups(groups);
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: center,
        zoom: groups.length <= 1 ? 13 : 6.4,
      ),
      markers: {
        for (final group in groups)
          Marker(
            markerId: MarkerId('location-${group.location.id}'),
            position: LatLng(group.location.latitude, group.location.longitude),
            infoWindow: InfoWindow(
              title: group.location.displayName,
              snippet: context.l10n.locationPickerMemoryCount(
                group.memories.length,
              ),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(342),
            onTap: () => onLocationTap(group),
          ),
      },
      onMapCreated: onMapCreated,
      compassEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}

class _MapKeyFallback extends StatelessWidget {
  const _MapKeyFallback({required this.groups, required this.onLocationTap});

  final List<MemoryLocationGroup> groups;
  final ValueChanged<MemoryLocationGroup> onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7EFE9),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _MapWashPainter()),
          for (final entry in groups.asMap().entries)
            Align(
              alignment: _pinAlignment(entry.key),
              child: _LocationPin(
                group: entry.value,
                onTap: () => onLocationTap(entry.value),
              ),
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

class _LocationPin extends StatelessWidget {
  const _LocationPin({required this.group, required this.onTap});

  final MemoryLocationGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            child: Center(
              child: Text(
                '${group.memories.length}',
                style: AppTextStyles.bodyS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
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
              color: Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              group.location.displayName,
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
    );
  }
}

class _FloatingSurface extends StatelessWidget {
  const _FloatingSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Padding(padding: const EdgeInsets.all(AppSpacing.s), child: child),
    );
  }
}

LatLng _centerForGroups(List<MemoryLocationGroup> groups) {
  if (groups.isEmpty) {
    return const LatLng(10.7769, 106.7009);
  }
  final latitude =
      groups.fold<double>(0, (sum, group) => sum + group.location.latitude) /
      groups.length;
  final longitude =
      groups.fold<double>(0, (sum, group) => sum + group.location.longitude) /
      groups.length;
  return LatLng(latitude, longitude);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
