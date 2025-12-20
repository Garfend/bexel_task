import 'package:bexel_task/data/model/task_model.dart';
import 'package:bexel_task/utils/extensions/date_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  final TaskModel task;
  final Function() deleteItem;
  final Function() editItem;

  const TaskWidget({
    super.key,
    required this.task,
    required this.deleteItem,
    required this.editItem,
  });

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
                Row(
                  children: [
                    IconButton(
                      onPressed: deleteItem,
                      icon: Icon(Icons.delete),
                      iconSize: 16,
                    ),
                    IconButton(
                      onPressed: editItem,
                      icon: Icon(Icons.edit),
                      iconSize: 16,
                    ),
                  ],
                ),
              ],
            ),
            Text(task.status, style: TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Text(task.description),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.type),
                Text(task.createdAt.formattedDateTime),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
