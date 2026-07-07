import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/economy/treat_repository.dart';
import '../../../core/economy/inventory_repository.dart';
import '../../../shared/theme/theme_provider.dart';
import 'challenges_screen.dart'; // We'll extract the body of ChallengesScreen

class ToyBoxScreen extends StatefulWidget {
  const ToyBoxScreen({super.key});

  @override
  State<ToyBoxScreen> createState() => _ToyBoxScreenState();
}

class _ToyBoxScreenState extends State<ToyBoxScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Meow Mart', 
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22, 
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD66B44), // AppColors.marmaladeDeep
          )
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final treatCount = ref.watch(treatCountProvider);
              return Container(
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '$treatCount',
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                _buildTab(0, 'Challenges'),
                _buildTab(1, 'Meow Mart'),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _selectedTab == 0 ? const ChallengesList() : const BoutiqueList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTab == index;
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isSelected ? [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class BoutiqueList extends ConsumerWidget {
  const BoutiqueList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Self-Care Rewards',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Spend your hard-earned treats on real-life rewards!',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),
        _BoutiqueItem(
          id: 'reward_gaming',
          title: '1 Hour of Gaming',
          description: 'Guilt-free gaming time. You earned it!',
          price: 100,
          icon: Icons.sports_esports_rounded,
          isUnlocked: false, // We use this flag just to hide the "Equip" state
          onTap: () async {
            final success = await ref.read(treatCountProvider.notifier).spendTreats(100);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward Claimed! Enjoy your gaming time! 🎮')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough treats!')));
            }
          },
        ),
        const SizedBox(height: 16),
        _BoutiqueItem(
          id: 'reward_coffee',
          title: 'Buy a Coffee/Treat',
          description: 'Treat yourself in real life.',
          price: 150,
          icon: Icons.coffee_rounded,
          isUnlocked: false,
          onTap: () async {
            final success = await ref.read(treatCountProvider.notifier).spendTreats(150);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward Claimed! Enjoy your coffee! ☕')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough treats!')));
            }
          },
        ),
        const SizedBox(height: 16),
        _BoutiqueItem(
          id: 'reward_chore',
          title: 'Skip a Chore',
          description: 'Use this pass to skip one minor chore today.',
          price: 250,
          icon: Icons.celebration_rounded,
          isUnlocked: false,
          onTap: () async {
            final success = await ref.read(treatCountProvider.notifier).spendTreats(250);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward Claimed! Enjoy your free time! 🎉')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough treats!')));
            }
          },
        ),
      ],
    );
  }
}

class _BoutiqueItem extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final int price;
  final IconData icon;
  final bool isUnlocked;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _BoutiqueItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.icon,
    required this.isUnlocked,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? const Color(0xFFF3EBDC) : const Color(0xFFFFFDF9), // AppColors.paperDeep : AppColors.white
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
          boxShadow: isDisabled ? [] : const [
            BoxShadow(
              color: Color(0xFFDCD0BC), // AppColors.line
              offset: Offset(4, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF7C9082).withValues(alpha: 0.15), // sage transparent
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF5F7568), size: 32), // sageDeep
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: isDisabled ? const Color(0xFF6B625B) : const Color(0xFF3A3532), // inkSoft : ink
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF6B625B), // inkSoft
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (!isDisabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isUnlocked ? const Color(0xFF7C9082) : const Color(0xFFEFC94C), // sage : butter
                  border: Border.all(color: const Color(0xFF3A3532), width: 2), // ink
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: isUnlocked ? const Color(0xFF5F7568) : const Color(0xFFB89A2E), // sageDeep : butterDeep equivalent
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Text(
                  isUnlocked ? 'Equip' : '$price ⭐',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF3A3532), // ink
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
