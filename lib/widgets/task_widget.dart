import 'package:bexel_task/data/model/task_model.dart';
import 'package:bexel_task/widgets/extensions/date_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  final TaskModel task;

  const TaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.title),
                Chip(
                  label: Text(
                    task.status,
                    style: TextStyle(fontSize: 10),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(task.description),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.type),
                Text(task.createdAt.formattedDateTime)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
