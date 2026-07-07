import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'chat_provider.dart';
import '../domain/chat_message.dart';
import '../data/groq_service.dart';
import '../../../core/identity/cat_name_provider.dart';
import '../../mood_engine/mood_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final catName = ref.read(catNameProvider);
      ref.read(chatProvider.notifier).initializeGreetingIfNeeded(catName);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || ref.read(chatLoadingProvider)) return;

    _controller.clear();
    _scrollToBottom();
    
    // Add health context to the prompt
    final healthSnapshot = ref.read(healthSnapshotProvider);
    final healthContext = healthSnapshot.maybeWhen(
      data: (data) => '\n[Context for you: User has taken ${data.stepCount} steps today, and has ${data.screenTimeHours.toStringAsFixed(1)} hours of screen time. Feel free to comment on this if relevant!]',
      orElse: () => '',
    );
    
    await ref.read(chatProvider.notifier).sendMessage(text, healthContext);
    
    if (mounted) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100, // Add padding for new message
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final catName = ref.watch(catNameProvider);
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Chat with $catName',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              'Powered by Groq (Llama 70B)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFD66B44)), // marmaladeDeep
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat(catName);
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  // Typing indicator
                  return _buildTypingIndicator(theme);
                }
                
                final message = messages[index];
                
                return _buildMessageBubble(
                  message, 
                  theme,
                );
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEFC94C), // AppColors.butter
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFDCD0BC), // AppColors.line
              offset: Offset(4, 5),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐈‍⬛', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A3532), // AppColors.ink
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .fade(duration: 400.ms, delay: (index * 150).ms);
              }),
            ),
          ],
        ),
      ).animate().fade().slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.role == 'user';
    final timeString = DateFormat('h:mm a').format(message.timestamp);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF7C9082) : const Color(0xFFD66B44), // sage : marmalade
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(24),
            topRight: const Radius.circular(24),
            bottomLeft: Radius.circular(isUser ? 24 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 24),
          ),
          border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
          boxShadow: [
            BoxShadow(
              color: isUser ? const Color(0xFF5F7568) : const Color(0xFFB55431), // sageDeep : marmaladeDeep
              offset: const Offset(4, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFFFFFDF9), // AppColors.white
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: const Color(0xFFFFFDF9).withValues(alpha: 0.7),
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all_rounded, size: 14, color: const Color(0xFFFFFDF9).withValues(alpha: 0.7)),
                ],
              ],
            ),
          ],
        ),
      ).animate().fade(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Container(
      margin: const EdgeInsets.only(
        left: 16, 
        right: 16,
        top: 16,
        bottom: 24, // extra bottom padding for floating feel
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // AppColors.white
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFF3A3532), width: 2), // AppColors.ink
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCD0BC), // AppColors.line
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF3A3532),
              ),
              decoration: const InputDecoration(
                hintText: 'Tell the cat how you feel...',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B625B), // AppColors.inkSoft
                ),
                border: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFC94C), // AppColors.butter
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3A3532), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFB89A2E), // butterDeep equivalent
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Color(0xFF3A3532), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
