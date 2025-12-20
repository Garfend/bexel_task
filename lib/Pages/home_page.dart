import 'dart:async';

import 'package:bexel_task/data/local/app_database.dart';
import 'package:bexel_task/data/model/task_filters.dart';
import 'package:bexel_task/data/model/task_model.dart';
import 'package:bexel_task/data/repository/task_repository.dart';
import 'package:bexel_task/widgets/task_form_dialog.dart';
import 'package:bexel_task/widgets/task_search_filter_bar.dart';
import 'package:bexel_task/widgets/task_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final AppDatabase db;
  final TaskRepository repository;

  const HomePage({
    super.key,
    required this.db,
    required this.repository,
  });

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  TaskFilters _filters = const TaskFilters();
  List<String> _types = [];
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    final types = await widget.repository.loadTaskTypes();
    if (!mounted) return;
    setState(() => _types = types);
  }

  Future<void> _deleteTask(TaskModel task) async {
    final id = task.id;
    if (id == null) return;
    await widget.repository.deleteTask(id);
    await _loadTypes();
  }

  Future<void> _openTaskForm({TaskModel? task}) async {
    final result = await showTaskFormDialog(
      context: context,
      initial: task,
    );

    if (result != null) {
      if (task == null) {
        await widget.repository.addTask(result);
      } else {
        await widget.repository.updateTask(result);
      }
      await _loadTypes();
    }
  }

  Future<void> _importData() async {
    setState(() => _importing = true);
    try {
      await widget.repository.importFromAssets();
      await _loadTypes();
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  void dispose() {
    unawaited(widget.db.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xE7E7E7FF),
        actions: [
          IconButton(
            onPressed: _importing ? null : _importData,
            icon: _importing
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            tooltip: 'Import JSON file',
          ),
          IconButton(
            onPressed: () => _openTaskForm(),
            icon: const Icon(Icons.add),
            tooltip: 'add item',
          ),
        ],
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TaskSearchFilterBar(
              initialFilters: _filters,
              availableTypes: _types,
              onChanged: (filters) => setState(() {
                _filters = filters;
              }),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: widget.repository.watchTasks(
                keyword: _filters.query,
                status: _filters.status,
                type: _filters.type,
                from: _filters.dateFrom,
                to: _filters.dateTo,
                desc: _filters.sortDescending,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No data imported yet. Import data with import button in appbar or add tasks manually.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _importData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskWidget(
                        task: tasks[index],
                        editItem: () => _openTaskForm(task: tasks[index]),
                        deleteItem: () => _deleteTask(tasks[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
