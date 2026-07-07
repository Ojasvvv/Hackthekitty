import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../core/economy/treat_repository.dart';
import '../../../shared/widgets/paws_background.dart';
import '../../../shared/widgets/living_cat_avatar.dart';
import '../../../shared/widgets/lottie_cat_avatar.dart';

class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});

  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> with WidgetsBindingObserver {
  // 25 minutes in seconds
  static const int _focusDuration = 25 * 60;
  
  int _secondsRemaining = _focusDuration;
  bool _isActive = false;
  bool _hasFailed = false;
  bool _hasSucceeded = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isActive && !_hasFailed && !_hasSucceeded) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        _failFocus();
      }
    }
  }

  void _startFocus() {
    setState(() {
      _isActive = true;
      _hasFailed = false;
      _hasSucceeded = false;
      _secondsRemaining = _focusDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _succeedFocus();
        }
      });
    });
  }

  void _failFocus() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _hasFailed = true;
    });
  }

  void _succeedFocus() {
    _timer?.cancel();
    setState(() {
      _isActive = false;
      _hasSucceeded = true;
    });
    // Award a large amount of treats
    ref.read(treatCountProvider.notifier).addTreats(25);
  }

  void _quitEarly() {
    if (_isActive) {
      _failFocus();
    } else {
      Navigator.of(context).pop();
    }
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine the state text
    String mainText = 'Cat Nap Timer';
    String subText = 'Keep the app open to let the cat sleep for 25 minutes. If you leave, you wake the cat!';
    
    if (_isActive) {
      mainText = 'Do Not Disturb';
      subText = 'Shh... the cat is sleeping. Don\'t leave the app!';
    } else if (_hasFailed) {
      mainText = 'You woke the cat!';
      subText = 'You left the app! The cat is very displeased.';
    } else if (_hasSucceeded) {
      mainText = 'Purr-fect Focus!';
      subText = 'You earned 25 Treats! The cat had a great nap.';
    }

    return PopScope(
      canPop: !_isActive,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Wake the cat?'),
            content: const Text('If you leave now, the cat will wake up and you will lose your progress!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep Napping'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Wake Up (Exit)', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        
        if (shouldPop == true && context.mounted) {
          _failFocus();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: _isActive ? const Color(0xFF1A1A24) : colorScheme.surface,
      body: Stack(
        children: [
          if (!_isActive) const PawsBackground(),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mainText,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isActive ? Colors.white : colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate(key: ValueKey(mainText)).fade().slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    Text(
                      subText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _isActive ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate(key: ValueKey(subText)).fade().slideY(begin: 0.2),
                    const SizedBox(height: 64),
                    
                    // The Avatar and Timer Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Timer Ring
                        if (_isActive || _hasFailed || _hasSucceeded)
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 1.0,
                                end: _secondsRemaining / _focusDuration,
                              ),
                              duration: const Duration(seconds: 1),
                              builder: (context, value, _) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 8,
                                  backgroundColor: _isActive ? Colors.white12 : colorScheme.primary.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _hasFailed ? Colors.redAccent : (_isActive ? colorScheme.primary : Colors.green),
                                  ),
                                );
                              },
                            ),
                          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                          
                        // The Cat
                        LottieCatAvatar(
                          size: 200,
                          assetPath: _hasFailed
                              ? 'assets/animations/sad_cat.json'
                              : (_isActive ? 'assets/animations/cat_sleeping.json' : 'assets/animations/cat_default.json'),
                        ).animate(target: _hasFailed ? 1 : 0)
                         .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 400.ms),
                      ],
                    ),
                    const SizedBox(height: 48),
                    
                    // Timer Text
                    if (_isActive || _hasSucceeded)
                      Text(
                        _hasSucceeded ? '+25 Treats' : _formattedTime,
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: _isActive ? Colors.white : Colors.amber.shade700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ).animate().fade(),

                    const SizedBox(height: 64),
                    
                    // Action Buttons
                    if (!_isActive && !_hasSucceeded)
                      ElevatedButton(
                        onPressed: _startFocus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                          elevation: 8,
                        ),
                        child: Text(
                          _hasFailed ? 'Try Again' : 'Start Cat Nap',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _quitEarly,
                      child: Text(
                        _isActive ? 'Wake Up Cat (Give Up)' : 'Back to Home',
                        style: TextStyle(
                          color: _isActive ? Colors.white54 : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
