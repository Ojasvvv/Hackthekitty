import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/paws_background.dart';
import '../../../shared/widgets/lottie_cat_avatar.dart';

class PurrBoxScreen extends ConsumerStatefulWidget {
  const PurrBoxScreen({super.key});

  static void show(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PurrBoxScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  ConsumerState<PurrBoxScreen> createState() => _PurrBoxScreenState();
}

class _PurrBoxScreenState extends ConsumerState<PurrBoxScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  String _currentPhase = "Breathe In";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 19), // 4 in + 7 hold + 8 out = 19s
    )..repeat();

    _controller.addListener(_updatePhase);
  }

  void _updatePhase() {
    final t = _controller.value;
    if (t < 4 / 19) {
      if (_currentPhase != "Breathe In") setState(() => _currentPhase = "Breathe In");
    } else if (t < 11 / 19) {
      if (_currentPhase != "Hold") setState(() => _currentPhase = "Hold");
    } else {
      if (_currentPhase != "Breathe Out") setState(() => _currentPhase = "Breathe Out");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Smooth custom physics curve for the breathing animation
    // Instead of linear, we use AnimatedBuilder with flutter_animate's curves logic
    // but flutter_animate is better for distinct states. For a continuous cycle, 
    // a TweenSequence or custom builder is best. We will use TweenSequence.

    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDC), // AppColors.paperDeep
      body: Stack(
        children: [
          const PawsBackground(),
          SafeArea(
            child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  'The Purr Box',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: const Color(0xFF3A3532), // AppColors.ink
                  ),
                ).animate().fade(duration: 800.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                Text(
                  'Follow the rhythm to relax.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: const Color(0xFF6B625B), // AppColors.inkSoft
                  ),
                ).animate().fade(delay: 200.ms, duration: 800.ms),
                const Spacer(),
                // Breathing Circle
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated background circle
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double scale = 1.0;
                          final t = _controller.value;
                          
                          if (t < 4 / 19) {
                            // Inhale: 4s ease-out
                            final progress = t / (4 / 19);
                            final curvedProgress = Curves.easeInOutSine.transform(progress);
                            scale = 1.0 + (curvedProgress * 0.8);
                          } else if (t < 11 / 19) {
                            // Hold: 7s stay at 1.8
                            scale = 1.8;
                          } else {
                            // Exhale: 8s ease-in-out
                            final outProgress = (t - (11 / 19)) / (8 / 19);
                            final curvedOutProgress = Curves.easeInOutSine.transform(outProgress);
                            scale = 1.8 - (curvedOutProgress * 0.8);
                          }
                          
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFEFC94C).withValues(alpha: 0.4), // Butter transparent
                                border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
                              ),
                            ),
                          );
                        },
                      ),
                      // Inner solid circle
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFEFC94C), // Butter
                          border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF3A3532), // ink shadow
                              offset: Offset(4, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            key: ValueKey(_currentPhase),
                            children: [
                              const LottieCatAvatar(
                                size: 60,
                                assetPath: 'assets/animations/cat_purring.json',
                              ),
                              const SizedBox(height: 4),
                                  Text(
                                    _currentPhase,
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF3A3532), // ink
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(delay: 400.ms, duration: 800.ms, curve: Curves.easeOutBack),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C9082), // sage
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF5F7568), // sageDeep
                          offset: Offset(4, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'I\'m feeling better',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFFFFFDF9), // white
                      ),
                    ),
                  ),
                ).animate().fade(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}
