import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/global_providers.dart';

final treatRepositoryProvider = Provider<TreatRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final user = ref.watch(authUserProvider).value;
  final prefix = user?.uid ?? 'guest';
  return TreatRepository(prefs, prefix);
});

final treatCountProvider = NotifierProvider<TreatCountNotifier, int>(() {
  return TreatCountNotifier();
});

class TreatRepository {
  final SharedPreferences _prefs;
  final String _userId;

  TreatRepository(this._prefs, this._userId);
  
  String get _treatsKey => '${_userId}_whisker_treats';

  int getTreats() {
    final treats = _prefs.getInt(_treatsKey);
    if (treats == null) {
      _prefs.setInt(_treatsKey, 200); // Async save starting balance
      return 200;
    }
    return treats;
  }

  Future<void> setTreats(int amount) async {
    await _prefs.setInt(_treatsKey, amount);
  }
}

class TreatCountNotifier extends Notifier<int> {
  late TreatRepository _repo;

  @override
  int build() {
    _repo = ref.watch(treatRepositoryProvider);
    return _repo.getTreats();
  }

  Future<void> addTreats(int amount) async {
    final newAmount = state + amount;
    await _repo.setTreats(newAmount);
    state = newAmount;
  }

  Future<bool> spendTreats(int amount) async {
    if (state >= amount) {
      final newAmount = state - amount;
      await _repo.setTreats(newAmount);
      state = newAmount;
      return true;
    }
    return false;
  }
}
