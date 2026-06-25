import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/journal_models.dart';
import '../components/journal_components.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({
    required this.memories,
    required this.onMemoryTap,
    super.key,
  });

  final List<Memory> memories;
  final ValueChanged<Memory> onMemoryTap;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  MemoryCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == null
        ? widget.memories
        : widget.memories
              .where((memory) => memory.category == _selectedCategory)
              .toList(growable: false);

    final phaseLabel = filtered.isEmpty
        ? 'Tất cả năm'
        : filtered.first.phase.label;

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
            kicker: 'Theo dòng thời gian',
            title: 'Timeline',
            trailing: AppCircleButton(
              icon: Icons.search_rounded,
              tooltip: 'Tìm kỷ niệm',
              onPressed: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AppFilterChip(
                  label: 'Tất cả',
                  selected: _selectedCategory == null,
                  onTap: () => _selectCategory(null),
                ),
                for (final category in MemoryCategory.values) ...[
                  const SizedBox(width: AppSpacing.xs),
                  AppFilterChip(
                    label: category.label,
                    selected: _selectedCategory == category,
                    onTap: () => _selectCategory(category),
                  ),
                ],
              ],
            ),
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
          TimelineSpine(memories: filtered, onMemoryTap: widget.onMemoryTap),
        ],
      ),
    );
  }

  void _selectCategory(MemoryCategory? category) {
    setState(() {
      _selectedCategory = category;
    });
  }
}
