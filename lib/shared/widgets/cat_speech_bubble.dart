import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'dart:math' as math;

class CatSpeechBubble extends StatelessWidget {
  final String text;

  const CatSpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 14, left: 20, right: 20),
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
          decoration: BoxDecoration(
            color: AppColors.marmalade,
            border: Border.all(color: AppColors.ink, width: 2),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: AppColors.ink,
                offset: Offset(5, 6),
              ),
            ],
          ),
          child: Text(
            text,
            style: theme.textTheme.headlineMedium?.copyWith(
              height: 1.36,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // The little upward pointing tail on the left
        Positioned(
          top: 3,
          left: 58,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: AppColors.marmalade,
                border: Border(
                  left: BorderSide(color: AppColors.ink, width: 2),
                  top: BorderSide(color: AppColors.ink, width: 2),
                ),
              ),
            ),
          ),
        ),
        // The Favorite Button
        Positioned(
          right: 40,
          bottom: -22,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.ink,
                  offset: Offset(3, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_rounded,
                color: AppColors.marmaladeDeep,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
