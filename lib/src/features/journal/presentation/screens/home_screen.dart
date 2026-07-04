import 'package:flutter/material.dart';

import '../../../../app/journal_app_config.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.data,
    required this.now,
    required this.openedLetterIds,
    required this.onMemoryTap,
    required this.onLetterTap,
    required this.onRecapTap,
    super.key,
  });

  final JournalData data;
  final DateTime now;
  final Set<String> openedLetterIds;
  final ValueChanged<Memory> onMemoryTap;
  final ValueChanged<Letter> onLetterTap;
  final VoidCallback onRecapTap;

  @override
  Widget build(BuildContext context) {
    final loveDays = dayDifference(JournalAppConfig.loveStartedAt, now);
    final featured = data.featuredMemoryOrNull;
    final nextLetter = data.nextHomeLetter(now);
    final memoryCount = data.visibleMemories.length;

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
            kicker: 'Chào em',
            title: JournalAppConfig.title,
            large: true,
            trailing: AppCircleButton(
              icon: Icons.favorite_rounded,
              tooltip: 'Kỷ niệm 3 năm',
              onPressed: onRecapTap,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          HeroMemoryCard(
            imagePath: featured?.coverMedia?.uri ?? AppAssets.heroImage,
            kicker: 'Kỷ niệm của tụi mình',
            title: '${formatNumber(loveDays)} ngày yêu',
            subtitle: 'Và anh vẫn muốn đi tiếp cùng em.',
            onTap: onRecapTap,
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  value: formatNumber(memoryCount),
                  label: 'kỷ niệm đã viết',
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: StatCard(
                  value: formatNumber(data.places.length),
                  label: 'nơi mình đã qua',
                  accentColor: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          const SectionHeader(title: 'Kỷ niệm nổi bật'),
          const SizedBox(height: AppSpacing.s),
          if (featured == null)
            const EmptyStateCard(
              title: 'Chưa có kỷ niệm nổi bật',
              body:
                  'Khi thêm kỷ niệm đầu tiên, Home sẽ giữ lại khoảnh khắc đáng nhớ nhất ở đây.',
            )
          else
            MemoryListCard(
              memory: featured,
              onTap: () => onMemoryTap(featured),
            ),
          const SizedBox(height: AppSpacing.l),
          const SectionHeader(title: 'Lá thư tiếp theo'),
          const SizedBox(height: AppSpacing.s),
          if (nextLetter == null)
            const EmptyStateCard(
              title: 'Chưa có lá thư nào',
              body: 'Khi có thư mới, Home sẽ luôn giữ một lời nhắn gần nhất.',
            )
          else
            LetterCard(
              letter: nextLetter,
              now: now,
              opened: openedLetterIds.contains(nextLetter.id),
              onTap: () => onLetterTap(nextLetter),
            ),
          const SizedBox(height: AppSpacing.l),
          PrimaryButton(
            label: 'Xem recap ba năm',
            icon: Icons.auto_stories_rounded,
            onPressed: onRecapTap,
          ),
        ],
      ),
    );
  }
}
