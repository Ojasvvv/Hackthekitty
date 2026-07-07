import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/economy/treat_repository.dart';
import '../../../shared/widgets/paws_background.dart';
import '../../../shared/widgets/living_cat_avatar.dart';

class ThePromiseScreen extends ConsumerStatefulWidget {
  const ThePromiseScreen({super.key});

  @override
  ConsumerState<ThePromiseScreen> createState() => _ThePromiseScreenState();
}

class _ThePromiseScreenState extends ConsumerState<ThePromiseScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _holdController;
  bool _isPromising = false;
  bool _promiseComplete = false;

  @override
  void initState() {
    super.initState();
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _holdController.addListener(() {
      if (_holdController.value == 1.0 && !_promiseComplete) {
        _completePromise();
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    super.dispose();
  }

  void _completePromise() {
    setState(() => _promiseComplete = true);
    ref.read(treatCountProvider.notifier).addTreats(50); // Redemption Treat
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF3EBDC), // paperDeep
      body: Stack(
        children: [
          const PawsBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_promiseComplete) ...[
                      const Text('😿', style: TextStyle(fontSize: 80))
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: -5, end: 5, duration: 2.seconds)
                        .fadeIn(duration: 800.ms),
                      const SizedBox(height: 32),
                      const Text(
                        'You\'ve been staring at the glowing box all day...',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: Color(0xFF3A3532), // ink
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      const Text(
                        'I waited. I purred. I even knocked over a glass. But you didn\'t look away from the screen.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF6B625B), // inkSoft
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.1),
                      const SizedBox(height: 64),
                      const Text(
                        'Hold to make a promise for tomorrow.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF6B625B), // inkSoft
                        ),
                      ).animate().fadeIn(delay: 2400.ms),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTapDown: (_) {
                          setState(() => _isPromising = true);
                          _holdController.forward();
                        },
                        onTapUp: (_) {
                          if (!_promiseComplete) {
                            setState(() => _isPromising = false);
                            _holdController.reverse();
                          }
                        },
                        onTapCancel: () {
                          if (!_promiseComplete) {
                            setState(() => _isPromising = false);
                            _holdController.reverse();
                          }
                        },
                        child: AnimatedBuilder(
                          animation: _holdController,
                          builder: (context, child) {
                            return Container(
                              width: double.infinity,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: const Color(0xFF3A3532), // ink
                                  width: 2,
                                ),
                                color: const Color(0xFFFFFDF9), // white
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFDCD0BC), // line
                                    offset: Offset(4, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * _holdController.value,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: const Color(0xFF7C9082), // sage
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'I promise to be better',
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        color: _isPromising ? const Color(0xFFFFFDF9) : const Color(0xFF3A3532), // white or ink
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 2800.ms),
                    ] else ...[
                      const Text('😻', style: TextStyle(fontSize: 80))
                        .animate()
                        .scale(curve: Curves.easeOutBack, duration: 600.ms),
                      const SizedBox(height: 32),
                      const Text(
                        'Promise Accepted!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          color: Color(0xFF3A3532), // ink
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 16),
                      const Text(
                        'I believe in you. Here\'s 50 Treats for being honest.\nLet\'s try again tomorrow.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF6B625B), // inkSoft
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),
                      const SizedBox(height: 64),
                      GestureDetector(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFC94C), // butter
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
                            boxShadow: const [
                              BoxShadow(color: Color(0xFF3A3532), offset: Offset(4, 5)),
                            ],
                          ),
                          child: const Text(
                            'Let\'s go',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: Color(0xFF3A3532), // ink
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 800.ms),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
