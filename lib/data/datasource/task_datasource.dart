import 'dart:convert';

import 'package:bexel_task/data/model/task_model.dart';
import 'package:flutter/services.dart';

abstract class TaskDatasource {
  Future<List<TaskModel>> loadFromFiles();
}

class TaskDataSourceImp extends TaskDatasource {
  @override
  Future<List<TaskModel>> loadFromFiles() async {
    final rawData = await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> jsonList = json.decode(rawData) as List<dynamic>;
    return jsonList
        .map((e) => TaskModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
