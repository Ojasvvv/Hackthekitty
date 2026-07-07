import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_typography.dart';

final meowQuoteProvider = Provider.autoDispose<String>((ref) {
  final quotes = [
    "Remember to stretch today. I recommend the downward dog. Wait, no — the upward cat.",
    "Breathe in the calm. Breathe out the dog energy.",
    "A 16-hour nap is technically self-care. Don't let anyone tell you otherwise.",
    "Hydration is key. Stare at your water glass until someone fills it.",
    "You are purr-fect just the way you are. Unless you forgot my treats.",
  ];
  return quotes[math.Random().nextInt(quotes.length)];
});

class MeowOfTheDay extends ConsumerStatefulWidget {
  const MeowOfTheDay({super.key});

  @override
  ConsumerState<MeowOfTheDay> createState() => _MeowOfTheDayState();
}

class _MeowOfTheDayState extends ConsumerState<MeowOfTheDay> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final dailyQuote = ref.watch(meowQuoteProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperColor = isDark ? AppColors.darkPaper : AppColors.paper;
    
    return Container(
      margin: const EdgeInsets.only(top: 18, left: 20, right: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.ink, width: 2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.marmalade,
                  offset: Offset(4, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.sage,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'MEOW OF THE DAY',
                      style: AppTypography.headlineMedium.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.09 * 11, // 0.09em
                        color: AppColors.sageDeep,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 24), // Avoid close button
                  child: Text(
                    dailyQuote,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.42,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => setState(() => _isVisible = false),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.paperDeep,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '✕',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.inkSoft,
                      height: 1, // Fix centering
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tag hole punch
          Positioned(
            left: -9,
            top: 22,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: paperColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
