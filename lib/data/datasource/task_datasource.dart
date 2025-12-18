import 'dart:convert';

import 'package:bexel_task/data/local/task_local_db.dart';
import 'package:bexel_task/data/model/task_model.dart';
import 'package:flutter/services.dart';

abstract class TaskDatasource {
  Future<List<TaskModel>> loadTasks();
  Future<List<TaskModel>> loadFromFiles();
}

class TaskDataSourceImp extends TaskDatasource {
  final TaskLocalDb localDb;

  TaskDataSourceImp(this.localDb);

  @override
  Future<List<TaskModel>> loadTasks() async {
    return localDb.fetchAll();
  }

  @override
  Future<List<TaskModel>> loadFromFiles() async {
    final rawData = await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> jsonList = json.decode(rawData) as List<dynamic>;
    return jsonList
        .map((e) => TaskModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
