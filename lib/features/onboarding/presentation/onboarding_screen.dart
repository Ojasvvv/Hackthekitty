import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/living_cat_avatar.dart';
import '../../../shared/widgets/spring_pressable.dart';
import '../../../shared/theme/app_typography.dart';
import '../../mood_engine/mood_provider.dart';
import '../../navigation/presentation/main_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
  }

  Future<void> _checkInitialPermissions() async {
    final repo = ref.read(healthRepositoryProvider);
    final granted = await repo.checkPermissions();
    
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool hasAdopted = prefs.containsKey('${uid}_cat_name_key');

    if (!hasAdopted && prefs.containsKey('cat_name_key')) {
      final oldName = prefs.getString('cat_name_key');
      if (oldName != null) {
        await prefs.setString('${uid}_cat_name_key', oldName);
        await prefs.remove('cat_name_key');
        hasAdopted = true;
      }
    }

    if (granted && hasAdopted && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: LivingCatAvatar(size: 200),
              ),
              const SizedBox(height: 48),
              Text(
                'This is your mirror.',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Purrist reflects your daily habits—sleep, movement, and screen time—through the life of a virtual cat.\n\nNot a game. No points to earn. Just an honest reflection of how you\'re doing.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SpringPressable(
                onTap: () async {
                  final repo = ref.read(healthRepositoryProvider);
                  final granted = await repo.requestPermissions();
                  
                  if (!context.mounted) return;
                  
                  if (granted) {
                    final controller = TextEditingController();
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: const Text('Adopt Your Kitty 🐾', style: TextStyle(fontWeight: FontWeight.bold)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Every good kitty needs a name. What will you call yours?'),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'e.g. Luna, Simba, Garfield...',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                  filled: true,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                final name = controller.text.trim();
                                if (name.isNotEmpty) {
                                  // Update name directly via SharedPreferences or Provider if accessible
                                  Navigator.pop(context, name);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Adopt!'),
                            ),
                          ],
                        );
                      },
                    ).then((name) {
                      if (name != null && name is String) {
                        // Assuming catNameProvider is imported or we just use SharedPreferences
                        SharedPreferences.getInstance().then((prefs) {
                           final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                           prefs.setString('${uid}_cat_name_key', name);
                        });
                      }
                    });

                    if (!context.mounted) return;
                    ref.invalidate(healthSnapshotProvider);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainScaffold()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please grant Health & Usage permissions to continue.',
                          style: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurface),
                        ),
                        backgroundColor: colorScheme.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      'Allow Access to Begin',
                      style: AppTypography.labelLarge.copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
