import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/health/health_snapshot.dart';
import '../../../core/economy/treat_repository.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class FeedingStation extends ConsumerStatefulWidget {
  final HealthSnapshot snapshot; // Kept if needed later, but treats come from provider

  const FeedingStation({super.key, required this.snapshot});

  @override
  ConsumerState<FeedingStation> createState() => _FeedingStationState();
}

class _FeedingStationState extends ConsumerState<FeedingStation> {
  bool _isFeeding = false;
  String? _feedingMessage;

  void _feedCat() async {
    final availableTreats = ref.read(treatCountProvider);
    if (availableTreats <= 0 || _isFeeding) return;
    
    setState(() {
      _isFeeding = true;
      _feedingMessage = null;
    });
    
    // Simulate feeding delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      final success = await ref.read(treatCountProvider.notifier).spendTreats(1);
      
      if (success && mounted) {
         final messages = [
           '"Thanks human. The bowl was half empty."',
           '"Finally, some good food."',
           '"Nom nom nom... you may live another day."',
           '"Purrrrr... acceptable service."',
           '"I was starving! (For 5 minutes)."',
           '"Mlem mlem mlem... exquisite vintage."',
           '"Could use more tuna, but I\'ll accept it."',
           '"Is this organic? I only eat organic."',
           '"I will remember this offering, mortal."',
           '"Chomp chomp... my bowl is still mathematically not full."',
           '"Don\'t touch me while I eat."',
           '"Did you really think 1 treat is enough?"',
           '"I suppose this prevents me from eating the house plants."'
         ];
         final randomMsg = messages[math.Random().nextInt(messages.length)];
         
         setState(() {
           _isFeeding = false;
           _feedingMessage = randomMsg;
         });
         
         Future.delayed(const Duration(seconds: 4), () {
           if (mounted) {
             setState(() => _feedingMessage = null);
           }
         });
      } else {
         setState(() {
           _isFeeding = false;
         });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final treatsAvailable = ref.watch(treatCountProvider);
    
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // AppColors.white
        border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCD0BC), // AppColors.line
            offset: Offset(4, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TREATS AVAILABLE',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.06 * 12,
                      color: Color(0xFF6B625B), // AppColors.inkSoft
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '$treatsAvailable',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          color: Color(0xFF3A3532), // AppColors.ink
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: treatsAvailable > 0 && !_isFeeding ? _feedCat : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: treatsAvailable > 0 && !_isFeeding ? const Color(0xFF7C9082) : Colors.grey, // AppColors.sage
                    border: Border.all(color: const Color(0xFF3A3532), width: 2),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF5F7568), // AppColors.sageDeep
                        offset: Offset(3, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _isFeeding ? '⏳' : '🍽️',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isFeeding ? 'Feeding...' : 'Feed Cat',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFFFFFDF9), // AppColors.white
                        ),
                      ),
                    ],
                  ),
                ).animate(target: _isFeeding ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(0.95, 0.95), duration: 200.ms, curve: Curves.easeOutCubic),
              ),
            ],
          ),
          if (_feedingMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EBDC), // AppColors.paperDeep
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3A3532), width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('💬', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _feedingMessage!,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: Color(0xFF3A3532),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fade(duration: 300.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
          ],
        ],
      ),
    );
  }
}
