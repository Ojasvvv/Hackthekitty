import 'package:shared_preferences/shared_preferences.dart';
import '../domain/chat_message.dart';

class ChatRepository {
  final SharedPreferences _prefs;
  final String _userId;

  ChatRepository(this._prefs, this._userId);
  
  String get _chatKey => '${_userId}_cat_chat_history';

  List<ChatMessage> getMessages() {
    final messagesList = _prefs.getStringList(_chatKey);
    if (messagesList == null) return [];
    
    try {
      return messagesList.map((t) => ChatMessage.fromJson(t)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMessages(List<ChatMessage> messages) async {
    final messagesList = messages.map((t) => t.toJson()).toList();
    await _prefs.setStringList(_chatKey, messagesList);
  }

  Future<void> clearMessages() async {
    await _prefs.remove(_chatKey);
  }
}
