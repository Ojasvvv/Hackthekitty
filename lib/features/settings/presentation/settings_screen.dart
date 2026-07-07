import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/theme/theme_provider.dart';
import '../../../core/identity/cat_name_provider.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../mood_engine/mood_provider.dart';
import '../../../shared/widgets/paws_background.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final themeMode = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const PawsBackground(),
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
          _buildSectionHeader(theme, 'Account'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Signed In As'),
            subtitle: Text(user?.email ?? 'Unknown User'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.colorScheme.surface,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.colorScheme.surface,
            onTap: () => _signOut(context),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(theme, 'Permissions'),
          ListTile(
            leading: const Icon(Icons.health_and_safety_outlined),
            title: const Text('Health Connect'),
            subtitle: const Text('Manage step tracking permissions'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.colorScheme.surface,
            onTap: () async {
              await openAppSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opened system settings for permissions.')),
                );
              }
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(theme, 'Cat Identity'),
          Consumer(
            builder: (context, ref, child) {
              final catName = ref.watch(catNameProvider);
              return ListTile(
                leading: const Icon(Icons.pets),
                title: const Text('Kitty\'s Name'),
                subtitle: Text(catName),
                trailing: const Icon(Icons.edit, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: theme.colorScheme.surface,
                onTap: () {
                  final controller = TextEditingController(text: catName);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        title: const Text('Rename Kitty', style: TextStyle(fontWeight: FontWeight.bold)),
                        content: TextField(
                          controller: controller,
                          autofocus: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            filled: true,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final name = controller.text.trim();
                              if (name.isNotEmpty) {
                                ref.read(catNameProvider.notifier).updateName(name);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(theme, 'App'),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && theme.brightness == Brightness.dark),
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.colorScheme.surface,
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
