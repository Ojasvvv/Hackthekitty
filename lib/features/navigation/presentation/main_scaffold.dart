import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/presentation/home_screen.dart';
import '../../challenges/presentation/toy_box_screen.dart';
import '../../chat/presentation/chat_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/health/health_repository.dart';
import '../../../core/economy/treat_repository.dart';

import '../../../shared/widgets/paws_background.dart';

import '../../relief/presentation/purr_box_screen.dart';

import '../../tasks/presentation/scratchpad_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPreviousDayScreentime();
    });
  }

  Future<void> _checkPreviousDayScreentime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final yesterdayDateString = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);
    
    final lastRewarded = prefs.getString('last_screentime_reward_date');
    if (lastRewarded == yesterdayDateString) return; // already rewarded

    final healthRepo = HealthRepository();
    final previousHours = await healthRepo.getPreviousDayScreenTimeHours();
    if (previousHours != null && previousHours < 3.0) {
      ref.read(treatCountProvider.notifier).addTreats(50);
      await prefs.setString('last_screentime_reward_date', yesterdayDateString);
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScratchpadScreen(),
    const ToyBoxScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBody: false,
      body: Stack(
        children: [
          const PawsBackground(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _screens[_currentIndex],
          ),
        ],
      ),
      // FAB removed for Neobrutalist design
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 18),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: theme.colorScheme.onSurface, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDCD0BC), // AppColors.line
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(0, '🏠', 'Home'),
              const SizedBox(width: 4),
              _buildNavItem(1, '📝', 'Tasks'),
              const SizedBox(width: 4),
              _buildNavItem(2, '⭐', 'Mart'),
              const SizedBox(width: 4),
              _buildNavItem(3, '💬', 'Chat'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildNavItem(int index, String emoji, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : const Color(0xFF6B625B), // AppColors.inkSoft
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
