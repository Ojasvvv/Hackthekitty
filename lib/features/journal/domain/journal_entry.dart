import 'dart:convert';

class JournalEntry {
  final String id;
  final DateTime date;
  final String moodEmoji;
  final String text;

  JournalEntry({
    required this.id,
    required this.date,
    required this.moodEmoji,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodEmoji': moodEmoji,
      'text': text,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] ?? '',
      date: DateTime.parse(map['date']),
      moodEmoji: map['moodEmoji'] ?? '',
      text: map['text'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory JournalEntry.fromJson(String source) =>
      JournalEntry.fromMap(json.decode(source));
}
