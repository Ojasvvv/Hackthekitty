import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/global_providers.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final user = ref.watch(authUserProvider).value;
  final prefix = user?.uid ?? 'guest';
  return InventoryRepository(prefs, prefix);
});

final unlockedItemsProvider = NotifierProvider<UnlockedItemsNotifier, List<String>>(() {
  return UnlockedItemsNotifier();
});

class InventoryRepository {
  final SharedPreferences _prefs;
  final String _userId;

  InventoryRepository(this._prefs, this._userId);
  
  String get _inventoryKey => '${_userId}_purrist_inventory';

  List<String> getUnlockedItems() {
    return _prefs.getStringList(_inventoryKey) ?? [];
  }

  Future<void> unlockItem(String itemId) async {
    final current = getUnlockedItems();
    if (!current.contains(itemId)) {
      current.add(itemId);
      await _prefs.setStringList(_inventoryKey, current);
    }
  }
}

class UnlockedItemsNotifier extends Notifier<List<String>> {
  late InventoryRepository _repo;

  @override
  List<String> build() {
    _repo = ref.watch(inventoryRepositoryProvider);
    return _repo.getUnlockedItems();
  }

  Future<void> unlock(String itemId) async {
    await _repo.unlockItem(itemId);
    state = _repo.getUnlockedItems();
  }
}
