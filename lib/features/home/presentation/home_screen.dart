import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/living_cat_avatar.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/widgets/cat_speech_bubble.dart';
import '../../../shared/widgets/lottie_cat_avatar.dart';
import 'insights_sheet.dart';
import 'feeding_station.dart';
import 'widgets/meow_of_the_day.dart';
import '../../promise/presentation/the_promise_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../mood_engine/mood_provider.dart';
import '../../mood_engine/mood_engine.dart';
import '../../../core/health/health_snapshot.dart';
import '../../focus/presentation/focus_mode_screen.dart';
import '../../relief/presentation/purr_box_screen.dart';
import '../../../core/identity/cat_name_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

class PromiseMadeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _init();
    return false;
  }
  
  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPromiseDateStr = prefs.getString('last_promise_date');
    if (lastPromiseDateStr != null) {
      final lastDate = DateTime.parse(lastPromiseDateStr);
      final now = DateTime.now();
      if (lastDate.year == now.year && lastDate.month == now.month && lastDate.day == now.day) {
        state = true;
        return;
      }
    }
    state = false;
  }
  
  Future<void> markPromised() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_promise_date', DateTime.now().toIso8601String());
  }
}

final promiseMadeProvider = NotifierProvider<PromiseMadeNotifier, bool>(() {
  return PromiseMadeNotifier();
});
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthSnapshotAsync = ref.watch(healthSnapshotProvider);
    final currentTier = ref.watch(moodTierProvider);
    final catName = ref.watch(catNameProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // ignore: unused_result
            ref.refresh(healthSnapshotProvider);
            ref.invalidate(meowQuoteProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      const MeowOfTheDay().animate().fade(duration: 400.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
                      // Top spacing
                      const SizedBox(height: 6),
                      // Dynamic Content Area
                      healthSnapshotAsync.when(
                        data: (snapshot) {
                          final hasHighScreenTime = snapshot.screenTimeHours > 4.0;
                          final promiseMade = ref.watch(promiseMadeProvider);
                          final isSad = hasHighScreenTime && !promiseMade;

                          final diaryText = isSad 
                              ? "You've been staring at the glowing rectangle all day... *sniffle*" 
                              : MoodEngine.generateDiaryEntry(snapshot, currentTier, catName);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // The interactive Avatar
                              Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        if (isSad) {
                                          final madePromise = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (_) => const ThePromiseScreen()),
                                          );
                                          if (madePromise == true) {
                                            ref.read(promiseMadeProvider.notifier).markPromised();
                                          }
                                        } else {
                                          InsightsSheet.show(context, snapshot, catName);
                                        }
                                      },
                                      child: LottieCatAvatar(
                                        size: 240,
                                        assetPath: isSad ? 'assets/animations/sad_cat.json' : 'assets/animations/cat_default.json',
                                      ),
                                    ),
                                    Positioned(
                                        top: 20,
                                        right: -20,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFC94C), // butter
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
                                            boxShadow: const [
                                              BoxShadow(color: Color(0xFF3A3532), offset: Offset(2, 3)),
                                            ],
                                          ),
                                          child: const Text(
                                            'Click me!',
                                            style: TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Color(0xFF3A3532), // ink
                                            ),
                                          ),
                                        ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 1.seconds),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              CatSpeechBubble(text: diaryText).animate().fade(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                              const SizedBox(height: 32),
                              _buildMetrics(context, snapshot).animate().fade(delay: 100.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                              _buildFocusModeCard(context).animate().fade(delay: 350.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                              _buildPurrBoxCard(context).animate().fade(delay: 375.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                              const SizedBox(height: 16),
                              FeedingStation(snapshot: snapshot).animate().fade(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                              const SizedBox(height: 40),
                            ],
                          );
                        },
                        loading: () => Center(
                          child: CircularProgressIndicator(color: colorScheme.primary),
                        ),
                        error: (e, st) => Text(
                          'Unable to read reflection.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics(BuildContext context, HealthSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              icon: '👣',
              label: 'Steps',
              value: '${snapshot.stepCount}',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MetricItem(
              icon: '📱',
              label: 'Screen',
              value: '${snapshot.screenTimeHours.toStringAsFixed(1)}h',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusModeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FocusModeScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3532), // AppColors.ink
          border: Border.all(color: const Color(0xFF3A3532), width: 2),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF5F7568), // AppColors.sageDeep
              offset: Offset(4, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF4A443F),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🌙', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Cat Nap Timer',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFFFFFDF9), // AppColors.white
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Focus while I nap',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFC9C0B4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFC94C), // AppColors.butter
                border: Border.all(color: const Color(0xFFB89A2E), width: 1.5),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                '+25 ⭐',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Color(0xFF3A3532), // AppColors.ink
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurrBoxCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PurrBoxScreen.show(context);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9), // white
          border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDCD0BC), // line
              offset: Offset(4, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFEFC94C).withValues(alpha: 0.15), // butter transparent
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🧘', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'The Purr Box',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF3A3532), // ink
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Breathe & Relax',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF6B625B), // inkSoft
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C9082), // sage
                border: Border.all(color: const Color(0xFF3A3532), width: 1.5),
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF5F7568), // sageDeep
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: const Text(
                'Start',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Color(0xFFFFFDF9), // white
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: -0.2, // ~ -12 degrees
                  child: const Text('🐾', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 6),
                Text(
                  'Purrist',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    letterSpacing: -0.02 * 22,
                    color: const Color(0xFFD66B44), // AppColors.marmaladeDeep
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF9), // AppColors.white
                  border: Border.all(color: const Color(0xFFDCD0BC), width: 1.5), // AppColors.line
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFDCD0BC), offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      '1 day',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: const Color(0xFFD66B44),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDF9), // AppColors.white
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
                    boxShadow: const [
                      BoxShadow(color: Color(0xFFDCD0BC), offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.settings_rounded, size: 20, color: Color(0xFF3A3532)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _MetricItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // AppColors.white
        border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCD0BC), // AppColors.line
            offset: Offset(3, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF3A3532), // AppColors.ink
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.06 * 11,
                  color: Color(0xFF6B625B), // AppColors.inkSoft
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
