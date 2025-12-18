import 'dart:async';

import 'package:bexel_task/data/datasource/task_datasource.dart';
import 'package:bexel_task/data/local/app_database.dart';
import 'package:bexel_task/data/model/task_filters.dart';
import 'package:bexel_task/data/model/task_model.dart';
import 'package:bexel_task/data/repository/task_repository.dart';
import 'package:bexel_task/widgets/task_form_dialog.dart';
import 'package:bexel_task/widgets/task_search_filter_bar.dart';
import 'package:bexel_task/widgets/task_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late final AppDatabase _db;
  late final TaskRepository _repository;
  TaskFilters _filters = const TaskFilters();
  List<String> _types = [];
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _repository = TaskRepositoryImp(TaskDataSourceImp(), TaskDao(_db));
    _initialize();
  }

  Future<void> _initialize() async {
    await _repository.warmIndexes();
    await _loadTypes();
  }

  Future<void> _loadTypes() async {
    final types = await _repository.loadTaskTypes();
    if (!mounted) return;
    setState(() => _types = types);
  }

  Future<void> _deleteTask(TaskModel task) async {
    await _repository.deleteTask(task.id);
    await _loadTypes();
  }

  Future<void> _openTaskForm({TaskModel? task}) async {
    final result = await showTaskFormDialog(
      context: context,
      initial: task,
      nextId: await _nextId(),
    );

    if (result != null) {
      if (task == null) {
        await _repository.addTask(result);
      } else {
        await _repository.updateTask(result);
      }
      await _loadTypes();
    }
  }

  Future<int> _nextId() {
    return _repository.nextId();
  }

  Future<void> _importData() async {
    setState(() => _importing = true);
    try {
      await _repository.importFromAssets();
      await _loadTypes();
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  @override
  void dispose() {
    unawaited(_db.close());
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
              stream: _repository.watchTasks(
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
                final visibleTasks = tasks;
                if (visibleTasks.isEmpty) {
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
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: _importData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: visibleTasks.length,
                      itemBuilder: (context, index) {
                        return TaskWidget(
                          task: visibleTasks[index],
                          editItem: () =>
                              _openTaskForm(task: visibleTasks[index]),
                          deleteItem: () => _deleteTask(visibleTasks[index]),
                        );
                      },
                    ),
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
