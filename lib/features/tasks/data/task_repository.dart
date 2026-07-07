import 'package:shared_preferences/shared_preferences.dart';
import '../domain/cat_task.dart';

class TaskRepository {
  final SharedPreferences _prefs;
  final String _userId;

  TaskRepository(this._prefs, this._userId);
  
  String get _tasksKey => '${_userId}_cat_tasks';

  List<CatTask> getTasks() {
    final tasksList = _prefs.getStringList(_tasksKey);
    if (tasksList == null) return [];
    
    try {
      return tasksList.map((t) => CatTask.fromJson(t)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<CatTask> tasks) async {
    final tasksList = tasks.map((t) => t.toJson()).toList();
    await _prefs.setStringList(_tasksKey, tasksList);
  }
}
