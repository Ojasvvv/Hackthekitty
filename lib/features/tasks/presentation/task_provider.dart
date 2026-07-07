import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/cat_task.dart';
import '../data/task_repository.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/global_providers.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final user = ref.watch(authUserProvider).value;
  final prefix = user?.uid ?? 'guest';
  return TaskRepository(prefs, prefix);
});

class TaskNotifier extends Notifier<List<CatTask>> {
  late TaskRepository _repository;
  final _uuid = const Uuid();

  @override
  List<CatTask> build() {
    _repository = ref.watch(taskRepositoryProvider);
    return _repository.getTasks();
  }

  void addPrey(String title, DateTime? deadline) {
    final newTask = CatTask(
      id: _uuid.v4(),
      title: title,
      deadline: deadline,
    );
    state = [...state, newTask];
    _repository.saveTasks(state);
  }

  void huntPrey(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isHunted: !task.isHunted);
      }
      return task;
    }).toList();
    _repository.saveTasks(state);
  }

  void editPrey(String id, String title, DateTime? deadline) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(title: title, deadline: deadline);
      }
      return task;
    }).toList();
    _repository.saveTasks(state);
  }

  void tossInLitterbox(String id) {
    state = state.where((task) => task.id != id).toList();
    _repository.saveTasks(state);
  }
}

final taskProvider = NotifierProvider<TaskNotifier, List<CatTask>>(() {
  return TaskNotifier();
});
