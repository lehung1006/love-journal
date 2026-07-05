import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ui/modal_bottom_sheet.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_localizations.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    required this.memories,
    required this.tags,
    required this.onMemoryTap,
    required this.onAddMemory,
    required this.onEditMemory,
    required this.onDeleteMemory,
    required this.onFeatureMemory,
    super.key,
  });

  final List<Memory> memories;
  final List<MemoryTag> tags;
  final ValueChanged<Memory> onMemoryTap;
  final VoidCallback onAddMemory;
  final ValueChanged<Memory> onEditMemory;
  final ValueChanged<Memory> onDeleteMemory;
  final ValueChanged<Memory> onFeatureMemory;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  String? _selectedTagId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visibleMemories = widget.memories
        .where((memory) => !memory.isDeleted)
        .toList(growable: false);
    final filtered = _selectedTagId == null
        ? visibleMemories
        : visibleMemories
              .where((memory) => memory.effectiveTagId == _selectedTagId)
              .toList(growable: false);

    final phaseLabel = filtered.isEmpty
        ? l10n.timelineAllYears
        : relationshipPhaseLabel(l10n, filtered.first.phase);

    return AppScaffold(
      safeBottom: false,
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          112,
        ),
        children: [
          TopBar(
            kicker: l10n.timelineKicker,
            title: l10n.timelineTitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppCircleButton(
                  icon: Icons.search_rounded,
                  tooltip: l10n.timelineSearchTooltip,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.xs),
                AppCircleButton(
                  icon: Icons.add_rounded,
                  tooltip: l10n.timelineAddMemoryTooltip,
                  isActive: true,
                  onPressed: widget.onAddMemory,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          _TagChips(
            tags: widget.tags,
            selectedTagId: _selectedTagId,
            onSelected: (tagId) {
              setState(() => _selectedTagId = tagId);
            },
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            phaseLabel,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          if (visibleMemories.isEmpty)
            _TimelineEmptyState(
              title: l10n.timelineEmptyTitle,
              body: l10n.timelineEmptyBody,
              cta: l10n.timelineEmptyCta,
              onPressed: widget.onAddMemory,
            )
          else if (filtered.isEmpty)
            _TimelineEmptyState(
              title: l10n.timelineFilteredEmptyTitle,
              body: l10n.timelineFilteredEmptyBody,
              cta: l10n.timelineFilteredEmptyCta,
              onPressed: widget.onAddMemory,
            )
          else
            TimelineSpine(
              memories: filtered,
              onMemoryTap: widget.onMemoryTap,
              tagLabelForMemory: (memory) =>
                  memoryTagLabelById(l10n, widget.tags, memory),
              mediaSummaryForMemory: (memory) =>
                  memoryMediaSummary(l10n, memory),
              onMemoryMore: _showMemoryActions,
            ),
        ],
      ),
    );
  }

  void _showMemoryActions(Memory memory) {
    showUnfocusedModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenX,
            AppSpacing.m,
            AppSpacing.screenX,
            AppSpacing.m,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              Text(
                memory.title,
                style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.timelineMemoryActionHelper,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: AppSpacing.m),
              _ActionTile(
                icon: Icons.edit_rounded,
                title: context.l10n.timelineEditMemory,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onEditMemory(memory);
                },
              ),
              _ActionTile(
                icon: Icons.favorite_rounded,
                title: context.l10n.timelineFeatureMemory,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onFeatureMemory(memory);
                },
              ),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                title: context.l10n.timelineDeleteMemory,
                danger: true,
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(memory);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(Memory memory) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.l10n.timelineDeleteTitle),
          content: Text(context.l10n.timelineDeleteBody(memory.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancelAction),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDeleteMemory(memory);
              },
              child: Text(context.l10n.deleteAction),
            ),
          ],
        );
      },
    );
  }
}

class _TagChips extends StatelessWidget {
  const _TagChips({
    required this.tags,
    required this.selectedTagId,
    required this.onSelected,
  });

  final List<MemoryTag> tags;
  final String? selectedTagId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          AppFilterChip(
            label: l10n.timelineAllFilter,
            selected: selectedTagId == null,
            onTap: () => onSelected(null),
          ),
          for (final tag in tags) ...[
            const SizedBox(width: AppSpacing.xs),
            AppFilterChip(
              label: memoryTagLabel(l10n, tag),
              selected: selectedTagId == tag.id,
              onTap: () => onSelected(tag.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineEmptyState extends StatelessWidget {
  const _TimelineEmptyState({
    required this.title,
    required this.body,
    required this.cta,
    required this.onPressed,
  });

  final String title;
  final String body;
  final String cta;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .78),
        borderRadius: BorderRadius.circular(AppRadius.s),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 168,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.s),
              child: Stack(
                fit: StackFit.expand,
                children: const [
                  AssetCoverImage(imagePath: AppAssets.heroImage),
                  DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.photoOverlay),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            title,
            style: AppTextStyles.bodyL.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            body,
            style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.m),
          PrimaryButton(
            label: cta,
            icon: Icons.add_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: AppTextStyles.bodyM.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
      onTap: onTap,
    );
  }
}
