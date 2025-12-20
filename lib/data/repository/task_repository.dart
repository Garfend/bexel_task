import 'package:bexel_task/data/datasource/task_datasource.dart';
import 'package:bexel_task/data/local/app_database.dart';
import 'package:bexel_task/data/model/task_model.dart';
import 'package:bexel_task/data/task_conflict_exception.dart';
import 'package:drift/drift.dart';

abstract class TaskRepository {
  Stream<List<TaskModel>> watchTasks({
    String? keyword,
    String? status,
    String? type,
    DateTime? from,
    DateTime? to,
    bool desc = true,
  });
  Future<List<String>> loadTaskTypes();
  Future<void> importFromAssets();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(int id);
}

class TaskRepositoryImp extends TaskRepository {
  final TaskDatasource taskDatasource;
  final TaskDao taskDao;

  TaskRepositoryImp(this.taskDatasource, this.taskDao);

  @override
  Stream<List<TaskModel>> watchTasks({
    String? keyword,
    String? status,
    String? type,
    DateTime? from,
    DateTime? to,
    bool desc = true,
  }) {
    return taskDao
        .watchTasks(
          keyword: keyword,
          status: status,
          type: type,
          from: from,
          to: to,
          desc: desc,
        )
        .map((rows) => rows
            .map(
              (row) => TaskModel(
                id: row.id,
                title: row.title,
                description: row.description,
                type: row.type,
                status: row.status,
                createdAt: row.createdAt,
                revision: row.revision,
              ),
            )
            .toList());
  }

  @override
  Future<List<String>> loadTaskTypes() async {
    return taskDao.loadTypes();
  }

  @override
  Future<void> importFromAssets() async {
    final tasks = await taskDatasource.loadFromFiles();
    await taskDao.upsertAll(
      tasks
          .map(
            (t) => Task(
              id: t.id ?? 0,
              title: t.title,
              description: t.description,
              type: t.type,
              status: t.status,
              createdAt: t.createdAt,
              revision: t.revision,
            ),
          )
          .toList(),
      clearBeforeInsert: true,
    );
  }

  @override
  Future<void> addTask(TaskModel task) async {
    if (task.id != null) {
      final existing = await taskDao.fetchTaskById(task.id!);
      if (existing != null) {
        throw TaskConflictException.idAlreadyExists(
          id: task.id!,
          attempted: task,
        );
      }
    }
    await taskDao.insertTask(
      TasksCompanion(
        id: task.id == null ? const Value.absent() : Value(task.id!),
        title: Value(task.title),
        description: Value(task.description),
        type: Value(task.type),
        status: Value(task.status),
        createdAt: Value(task.createdAt),
        revision: Value(task.revision),
      ),
    );
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final id = task.id;
    if (id == null || id <= 0) {
      throw TaskConflictException.wrongId(
        id: id,
        attempted: task,
      );
    }
    final existing = await taskDao.fetchTaskById(id);
    if (existing == null) {
      throw TaskConflictException.notFound(
        id: id,
        attempted: task,
      );
    }
    final updated = await taskDao.updateTaskRow(
      Task(
        id: id,
        title: task.title,
        description: task.description,
        type: task.type,
        status: task.status,
        createdAt: task.createdAt,
        revision: task.revision,
      ),
    );
    if (updated > 0) {
      return;
    }
    final latest = await taskDao.fetchTaskById(id);
    if (latest == null) {
      throw TaskConflictException.deleted(
        id: id,
        attempted: task,
      );
    }
    throw TaskConflictException.revisionMismatch(
      id: id,
      attempted: task,
      latest: TaskModel(
        id: latest.id,
        title: latest.title,
        description: latest.description,
        type: latest.type,
        status: latest.status,
        createdAt: latest.createdAt,
        revision: latest.revision,
      ),
    );
  }

  @override
  Future<void> deleteTask(int id) async {
    await taskDao.deleteTaskById(id);
  }
}
