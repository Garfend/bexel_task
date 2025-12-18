import 'package:bexel_task/model/task_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  final TaskModel task;

  const TaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(task.title), Chip(label: Text(task.status))],
          ),
          Expanded(child: Text(task.description)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(task.title),
              Text(task.createdAt.toIso8601String())
            ],
          )
        ],
      ),
    );
  }
}
