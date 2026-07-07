import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_provider.dart';
import 'features/mood_engine/mood_provider.dart';
import 'shared/widgets/noise_overlay.dart';
import 'features/auth/presentation/auth_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'core/economy/treat_repository.dart';
import 'core/economy/inventory_repository.dart';

import 'features/tasks/data/task_repository.dart';
import 'features/tasks/presentation/task_provider.dart';
import 'features/chat/presentation/chat_provider.dart';
import 'core/providers/global_providers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase not initialized. Please configure google-services.json manually.');
  }
  
  final prefs = await SharedPreferences.getInstance();
  
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: const Color(0xFFEFC94C), // butter
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🙀', style: TextStyle(fontSize: 80)),
            SizedBox(height: 24),
            Text(
              'Oh no! The cat knocked something over.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w900,
                fontSize: 24,
                color: Color(0xFF3A3532), // ink
              ),
            ),
            SizedBox(height: 16),
            Text(
              'An unexpected error occurred. Please restart the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF6B625B), // inkSoft
              ),
            ),
          ],
        ),
      ),
    );
  };
  
  runApp(ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
    ],
    child: const WhiskerApp(),
  ));
}

class WhiskerApp extends ConsumerWidget {
  const WhiskerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTier = ref.watch(moodTierProvider);
    final themeMode = ref.watch(themeProvider);
    
    Brightness brightness;
    if (themeMode == ThemeMode.system) {
      brightness = MediaQuery.platformBrightnessOf(context);
    } else {
      brightness = themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light;
    }

    final themeData = AppTheme.getThemeData(brightness);

    return MaterialApp(
      title: 'Whisker',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      themeMode: themeMode,
      builder: (context, child) {
        return NoiseOverlay(child: child!);
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData && snapshot.data != null) {
            return const OnboardingScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
