import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import 'memory_composer_components.dart';

class MemoryComposerDatePicker extends StatefulWidget {
  const MemoryComposerDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onSelected,
    required this.onCancel,
    super.key,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelected;
  final VoidCallback onCancel;

  @override
  State<MemoryComposerDatePicker> createState() =>
      _MemoryComposerDatePickerState();
}

class _MemoryComposerDatePickerState extends State<MemoryComposerDatePicker> {
  static const _monthNames = [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12',
  ];

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  bool get _canGoPrevious {
    final firstMonth = DateTime(widget.firstDate.year, widget.firstDate.month);
    return _visibleMonth.isAfter(firstMonth);
  }

  bool get _canGoNext {
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    return _visibleMonth.isBefore(lastMonth);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final canSelectToday =
        !today.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
        !today.isAfter(DateUtils.dateOnly(widget.lastDate));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenX,
        AppSpacing.m,
        AppSpacing.screenX,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ComposerSheetHandle(),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chọn ngày',
                  style: AppTextStyles.titleL.copyWith(color: AppColors.ink),
                ),
              ),
              IconButton(
                tooltip: 'Đóng',
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              IconButton(
                tooltip: 'Tháng trước',
                onPressed: _canGoPrevious ? () => _moveMonth(-1) : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[_visibleMonth.month - 1]} ${_visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleM.copyWith(color: AppColors.ink),
                ),
              ),
              IconButton(
                tooltip: 'Tháng sau',
                onPressed: _canGoNext ? () => _moveMonth(1) : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (final weekday in _weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      weekday,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 44,
            ),
            itemCount: 42,
            itemBuilder: (context, index) => _buildDay(index, today),
          ),
          const SizedBox(height: AppSpacing.s),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: canSelectToday ? () => widget.onSelected(today) : null,
              icon: const Icon(Icons.today_rounded, size: 18),
              label: const Text('Hôm nay'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDay(int index, DateTime today) {
    final firstWeekdayOffset = _visibleMonth.weekday - DateTime.monday;
    final day = index - firstWeekdayOffset + 1;
    final daysInMonth = DateUtils.getDaysInMonth(
      _visibleMonth.year,
      _visibleMonth.month,
    );
    if (day < 1 || day > daysInMonth) {
      return const SizedBox.shrink();
    }

    final date = DateTime(_visibleMonth.year, _visibleMonth.month, day);
    final enabled =
        !date.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
        !date.isAfter(DateUtils.dateOnly(widget.lastDate));
    final selected = DateUtils.isSameDay(date, widget.initialDate);
    final isToday = DateUtils.isSameDay(date, today);

    return Center(
      child: Material(
        color: selected ? AppColors.roseDark : Colors.transparent,
        shape: CircleBorder(
          side: isToday && !selected
              ? const BorderSide(color: AppColors.rose)
              : BorderSide.none,
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? () => widget.onSelected(date) : null,
          child: SizedBox.square(
            dimension: 38,
            child: Center(
              child: Text(
                '$day',
                style: AppTextStyles.bodyM.copyWith(
                  color: selected
                      ? Colors.white
                      : enabled
                      ? AppColors.inkSoft
                      : AppColors.mutedLight,
                  fontWeight: selected || isToday
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _moveMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
    });
  }
}
