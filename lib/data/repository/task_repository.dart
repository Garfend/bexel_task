import 'package:bexel_task/data/datasource/task_datasource.dart';
import 'package:bexel_task/data/local/task_local_db.dart';
import 'package:bexel_task/data/model/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> loadTasks();
  Future<List<String>> loadTaskTypes();
  Future<void> importFromAssets();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(int id);
}

class TaskRepositoryImp extends TaskRepository {
  final TaskDatasource taskDatasource;
  final TaskLocalDb localDb;

  TaskRepositoryImp(this.taskDatasource, this.localDb);

  @override
  Future<List<TaskModel>> loadTasks() async {
    return await localDb.fetchAll();
  }

  @override
  Future<List<String>> loadTaskTypes() async {
    final tasks = await loadTasks();
    final types = tasks
        .map((task) => task.type)
        .toSet()
        .toList()
      ..sort();
    return types;
  }

  @override
  Future<void> importFromAssets() async {
    final tasks = await taskDatasource.loadTasks();
    await localDb.upsertTasks(tasks, clearBeforeInsert: true);
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await localDb.insertTask(task);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await localDb.updateTask(task);
  }

  @override
  Future<void> deleteTask(int id) async {
    await localDb.deleteTask(id);
  }
}
