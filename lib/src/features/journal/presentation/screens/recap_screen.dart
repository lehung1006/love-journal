import 'package:flutter/material.dart';

import '../../../../app/journal_app_config.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import '../components/journal_components.dart';
import '../journal_formatters.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({required this.data, required this.now, super.key});

  final JournalData data;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final loveDays = dayDifference(JournalAppConfig.loveStartedAt, now);
    final featured = data.featuredMemoryOrNull;
    final photoCount = data.visibleMemories.fold<int>(
      0,
      (count, memory) => count + memory.media.length,
    );

    return Scaffold(
      body: AppScaffold(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenX,
          AppSpacing.screenTop,
          AppSpacing.screenX,
          34,
        ),
        child: ListView(
          children: [
            Row(
              children: [
                AppCircleButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Quay lại',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            HeroMemoryCard(
              imagePath: featured?.coverMedia?.uri ?? AppAssets.heroImage,
              kicker: 'Kỷ niệm 3 năm',
              title: 'Mình đã đi qua thật nhiều.',
              subtitle: 'Và anh vẫn muốn đi tiếp cùng em.',
              height: 300,
            ),
            const SizedBox(height: AppSpacing.m),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.s,
              mainAxisSpacing: AppSpacing.s,
              childAspectRatio: 1.45,
              children: [
                StatCard(value: formatNumber(loveDays), label: 'ngày yêu'),
                StatCard(
                  value: formatNumber(data.places.length),
                  label: 'nơi đã qua',
                  accentColor: AppColors.teal,
                ),
                StatCard(
                  value: formatNumber(photoCount),
                  label: 'tấm ảnh',
                  accentColor: AppColors.amber,
                ),
                StatCard(
                  value: formatNumber(data.letters.length),
                  label: 'lá thư',
                  accentColor: AppColors.lavender,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.m),
            const QuoteBlock(
              quote:
                  'Ba năm không phải là điểm kết. Nó là bằng chứng rằng mình đã chọn nhau, rất nhiều lần.',
            ),
            const SizedBox(height: AppSpacing.m),
            PrimaryButton(
              label: 'Cùng anh viết tiếp nhé?',
              icon: Icons.favorite_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
