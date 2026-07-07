import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_message.dart';
import '../data/chat_repository.dart';
import '../data/groq_service.dart';
import '../../../core/identity/cat_name_provider.dart';

import '../../../core/providers/global_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final user = ref.watch(authUserProvider).value;
  final prefix = user?.uid ?? 'guest';
  return ChatRepository(prefs, prefix);
});

// A provider for checking if the chat is currently waiting for a response
class ChatLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setLoading(bool val) => state = val;
}
final chatLoadingProvider = NotifierProvider<ChatLoadingNotifier, bool>(() => ChatLoadingNotifier());

class ChatNotifier extends Notifier<List<ChatMessage>> {
  late ChatRepository _repository;

  @override
  List<ChatMessage> build() {
    _repository = ref.watch(chatRepositoryProvider);
    final history = _repository.getMessages();
    return history;
  }

  void initializeGreetingIfNeeded(String catName) {
    if (state.isEmpty) {
      final greeting = ChatMessage(
        role: 'assistant',
        content: 'Meow. I see you looking at me. Did you bring treats, or do you just want to complain about your day? I\'m $catName, by the way.',
        timestamp: DateTime.now(),
      );
      state = [greeting];
      _repository.saveMessages(state);
    }
  }

  Future<void> sendMessage(String text, String healthContext) async {
    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];
    _repository.saveMessages(state);
    
    ref.read(chatLoadingProvider.notifier).setLoading(true);
    
    try {
      final groqService = ref.read(groqServiceProvider);
      // Map domain models to the format expected by groq
      final historyForGroq = state
          .where((msg) => msg.role != 'system') // Exclude any internal system stuff if present
          .map((msg) => {'role': msg.role, 'content': msg.content})
          .toList();
          
      // Ensure the history passed doesn't include the newly added user message (GroqService might expect just history)
      // Actually, GroqService sendMessage appends the messageWithContext to the history.
      final historyExcludingLast = historyForGroq.sublist(0, historyForGroq.length - 1);
      
      final messageWithContext = text + healthContext;
      
      final responseText = await groqService.sendMessage(messageWithContext, historyExcludingLast);
      
      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: responseText,
        timestamp: DateTime.now(),
      );
      
      state = [...state, assistantMessage];
      _repository.saveMessages(state);
    } finally {
      ref.read(chatLoadingProvider.notifier).setLoading(false);
    }
  }

  void clearChat(String catName) {
    state = [];
    _repository.clearMessages();
    initializeGreetingIfNeeded(catName);
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(() {
  return ChatNotifier();
});
