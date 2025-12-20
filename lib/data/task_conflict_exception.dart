import 'package:bexel_task/data/model/task_model.dart';

enum TaskConflictType {
  revisionMismatch,
  deleted,
  wrongId,
  notFound,
  idAlreadyExists,
}

class TaskConflictException implements Exception {
  final TaskConflictType type;
  final int? id;
  final TaskModel? latest;
  final TaskModel? attempted;
  final String message;

  TaskConflictException._({
    required this.type,
    this.id,
    this.latest,
    this.attempted,
    required this.message,
  });

  factory TaskConflictException.revisionMismatch({
    required int id,
    required TaskModel attempted,
    required TaskModel latest,
  }) {
    return TaskConflictException._(
      type: TaskConflictType.revisionMismatch,
      id: id,
      attempted: attempted,
      latest: latest,
      message: 'Task was updated elsewhere, reload',
    );
  }

  factory TaskConflictException.deleted({
    required int id,
    TaskModel? attempted,
  }) {
    return TaskConflictException._(
      type: TaskConflictType.deleted,
      id: id,
      attempted: attempted,
      message: 'Task was deleted elsewhere',
    );
  }

  factory TaskConflictException.notFound({
    required int id,
    TaskModel? attempted,
  }) {
    return TaskConflictException._(
      type: TaskConflictType.notFound,
      id: id,
      attempted: attempted,
      message: 'Task not found',
    );
  }

  factory TaskConflictException.wrongId({
    int? id,
    TaskModel? attempted,
  }) {
    return TaskConflictException._(
      type: TaskConflictType.wrongId,
      id: id,
      attempted: attempted,
      message: 'Invalid task id',
    );
  }

  factory TaskConflictException.idAlreadyExists({
    required int id,
    TaskModel? attempted,
  }) {
    return TaskConflictException._(
      type: TaskConflictType.idAlreadyExists,
      id: id,
      attempted: attempted,
      message: 'Task id already exists',
    );
  }

  @override
  String toString() => 'TaskConflictException($type, id: $id): $message';
}
