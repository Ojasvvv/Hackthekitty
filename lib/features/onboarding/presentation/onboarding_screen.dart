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

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isChecking && !_isDialogShowing) {
        _checkInitialPermissions();
      }
    }
  }

  Future<void> _checkInitialPermissions() async {
    final repo = ref.read(healthRepositoryProvider);
    final granted = await repo.checkPermissions();
    
    if (granted) {
      await _handleGrantedPermissions();
    } else {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _handleGrantedPermissions() async {
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

    if (!mounted) return;

    if (hasAdopted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      if (mounted) {
        setState(() => _isChecking = false);
      }
      await _showAdoptionDialog();
    }
  }

  Future<void> _showAdoptionDialog() async {
    if (_isDialogShowing) return;
    setState(() => _isDialogShowing = true);

    final controller = TextEditingController();
    final name = await showDialog<String>(
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
    );

    if (mounted) {
      setState(() => _isDialogShowing = false);
    }

    if (name != null && name.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await prefs.setString('${uid}_cat_name_key', name);

      if (!mounted) return;
      ref.invalidate(healthSnapshotProvider);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isDialogShowing) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Icon(
            Icons.pets,
            size: 160,
            color: colorScheme.onSurface.withOpacity(0.04),
          ),
        ),
      );
    }

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
                    await _handleGrantedPermissions();
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
