import 'package:bexel_task/data/datasource/task_datasource.dart';
import 'package:bexel_task/data/model/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> loadTask();
}

class TaskRepositoryImp extends TaskRepository {
  final TaskDatasource taskDatasource;

  TaskRepositoryImp(this.taskDatasource);

  @override
  Future<List<TaskModel>> loadTask() async {
    return await taskDatasource.loadTasks();
  }
}
