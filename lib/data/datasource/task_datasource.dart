import 'dart:convert';

import 'package:bexel_task/data/model/task_model.dart';
import 'package:flutter/services.dart';

abstract class TaskDatasource {
  Future<List<TaskModel>> loadTasks();
}

class TaskDataSourceImp extends TaskDatasource {
  @override
  Future<List<TaskModel>> loadTasks() async {
    final rawData = await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> jsonList = json.decode(rawData) as List<dynamic>;
    return jsonList
        .map((_) => TaskModel.fromMap(_ as Map<String, dynamic>))
        .toList();
  }
}
