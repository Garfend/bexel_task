import 'package:flutter/material.dart';

import '../data/model/task_model.dart';

Future<TaskModel?> showTaskFormDialog({
  required BuildContext context,
  TaskModel? initial,
}) {
  final titleController = TextEditingController(text: initial?.title ?? '');
  final descController =
      TextEditingController(text: initial?.description ?? '');
  final typeController = TextEditingController(text: initial?.type ?? '');
  String status = initial?.status ?? 'Incomplete';
  DateTime createdAt = initial?.createdAt ?? DateTime.now();

  return showDialog<TaskModel>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: Text(initial == null ? 'Add Task' : 'Edit Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'Complete', child: Text('Complete')),
                      DropdownMenuItem(
                          value: 'Incomplete', child: Text('Incomplete')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() {
                          status = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: createdAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          createdAt = picked;
                        });
                      }
                    },
                    child: Text(
                        'Date: ${createdAt.year}-${createdAt.month}-${createdAt.day}'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newTask = TaskModel(
                    id: initial?.id,
                    title: titleController.text,
                    description: descController.text,
                    type: typeController.text,
                    status: status,
                    createdAt: createdAt,
                  );
                  Navigator.of(context).pop(newTask);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}
