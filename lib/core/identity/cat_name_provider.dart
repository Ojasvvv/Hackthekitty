import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _catNameKey = 'cat_name_key';
const String _defaultName = 'Kitty';

class CatNameNotifier extends Notifier<String> {
  late SharedPreferences _prefs;

  @override
  String build() {
    _init();
    return _defaultName;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedName = _prefs.getString(_catNameKey);
    if (savedName != null) {
      state = savedName;
    }
  }

  Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) return;
    state = newName.trim();
    await _prefs.setString(_catNameKey, state);
  }

  bool get hasCustomName => _prefs.containsKey(_catNameKey);
}

final catNameProvider = NotifierProvider<CatNameNotifier, String>(() {
  return CatNameNotifier();
});
