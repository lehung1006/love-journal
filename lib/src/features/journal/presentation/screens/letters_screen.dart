import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class LettersScreen extends StatelessWidget {
  const LettersScreen({
    required this.letters,
    required this.now,
    required this.openedLetterIds,
    required this.onLetterTap,
    super.key,
  });

  final List<Letter> letters;
  final DateTime now;
  final Set<String> openedLetterIds;
  final ValueChanged<Letter> onLetterTap;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeBottom: false,
      padding: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          112,
        ),
        itemCount: letters.length + 1,
        separatorBuilder: (_, index) {
          return SizedBox(height: index == 0 ? AppSpacing.l : AppSpacing.s);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return TopBar(
              kicker: 'Dành cho em',
              title: 'Những lá thư',
              trailing: AppCircleButton(
                icon: Icons.mail_rounded,
                tooltip: 'Thư',
                onPressed: () {},
              ),
            );
          }

          final letter = letters[index - 1];
          final opened = openedLetterIds.contains(letter.id);
          return LetterCard(
            letter: letter,
            now: now,
            opened: opened,
            onTap: () {
              if (letter.isLocked(now)) {
                _showLockedLetterSheet(context, letter);
                return;
              }
              onLetterTap(letter);
            },
          );
        },
      ),
    );
  }

  void _showLockedLetterSheet(BuildContext context, Letter letter) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final unlockAt = letter.unlockAt;
        final unlockText = unlockAt == null
            ? 'Một ngày được để dành'
            : formatDate(unlockAt);
        final remaining = unlockAt == null ? null : daysUntil(unlockAt, now);

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Row(
                  children: [
                    EnvelopeMark(style: letter.coverStyle, size: 58),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            letter.title,
                            style: AppTextStyles.titleM.copyWith(
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Mở vào $unlockText',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  remaining == null
                      ? 'Lá thư này đang được giữ lại cho đúng khoảnh khắc.'
                      : 'Còn $remaining ngày nữa lá thư này mới mở được.',
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.l),
                PrimaryButton(
                  label: 'Đã hiểu',
                  icon: Icons.lock_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
