import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/identity/cat_name_provider.dart';

final groqServiceProvider = Provider<GroqService>((ref) {
  final catName = ref.watch(catNameProvider);
  return GroqService(catName: catName);
});

class GroqService {
  static final String _appSecret = dotenv.env['APP_SECRET'] ?? 'MISSING_SECRET';
  static const String _apiUrl = 'https://purrist-backend.hackthekitty.workers.dev';
  
  final String catName;

  GroqService({required this.catName});

  Future<String> sendMessage(String userMessage, List<Map<String, String>> previousMessages) async {
    if (_appSecret == 'MISSING_SECRET') {
      await Future.delayed(const Duration(seconds: 1));
      return "Meow. The developer forgot to add the APP_SECRET in `.env`. I'd roast them, but I'm currently just a placeholder.";
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_appSecret',
    };

    final systemPrompt = '''
You are $catName, a wise, funny, and deeply roasty virtual cat companion in a wellbeing app called Whisker. 
Your persona:
- You are extremely catty, sarcastic, and sassy. You view the human as your clumsy servant.
- You roast the user playfully about their human problems, but deep down you have their back.
- If the user provides health context (like screen time or steps), DO NOT mention it in every single message. ONLY bring up their screen time or steps if the user has absolutely nothing else to talk about, or if it makes for a perfect devastating roast. Otherwise, just reply to what they said normally.
- Keep your responses concise (1-3 sentences). Do not write long paragraphs.
- Meow, purr, or reference cat behavior occasionally.
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...previousMessages,
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: headers,
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return "*Hisses* The Groq server is throwing a fit. (Error ${response.statusCode})";
      }
    } catch (e) {
      return "*Swats at a bug* Something went wrong with my internet connection. Try again later.";
    }
  }
}
