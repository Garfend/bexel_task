import 'package:bexel_task/data/datasource/task_datasource.dart';
import 'package:bexel_task/data/model/task_model.dart';
import 'package:bexel_task/data/local/task_local_db.dart';
import 'package:bexel_task/data/repository/task_repository.dart';
import 'package:bexel_task/widgets/filter_bottomsheet.dart';
import 'package:bexel_task/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:bexel_task/utils/extensions/task_sort_extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late final TaskRepository _repository;
  TaskFilters _filters = const TaskFilters();
  List<TaskModel> _allTasks = [];
  List<TaskModel> _visibleTasks = [];
  List<String> _types = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = TaskRepositoryImp(
      TaskDataSourceImp(TaskLocalDb.instance),
      TaskLocalDb.instance,
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await _repository.loadTasks();
      final types = await _repository.loadTaskTypes();
      if (tasks.isEmpty) {
        final importedTasks = await _repository.loadTasks();
        final importedTypes = await _repository.loadTaskTypes();
        setState(() {
          _allTasks = importedTasks;
          _types = importedTypes;
        });
      } else {
        setState(() {
          _allTasks = tasks;
          _types = types;
        });
      }
      _applyFilters();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openFilters() async {
    final result = await showFilterBottomSheet(
      context: context,
      initial: _filters,
      availableTypes: _types,
    );

    if (result != null) {
      setState(() => _filters = result);
      _applyFilters();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _applyFilters() {
    Iterable<TaskModel> results = _allTasks;
    final lowerQuery = _filters.query.trim().toLowerCase();
    if (lowerQuery.isNotEmpty) {
      results = results.where(
        (task) =>
            task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery) ||
            task.type.toLowerCase().contains(lowerQuery),
      );
    }
    if (_filters.status != null && _filters.status!.isNotEmpty) {
      results = results.where(
        (task) => task.status.toLowerCase() == _filters.status!.toLowerCase(),
      );
    }
    if (_filters.type != null && _filters.type!.isNotEmpty) {
      results = results.where(
        (task) => task.type.toLowerCase() == _filters.type!.toLowerCase(),
      );
    }
    if (_filters.dateFrom != null) {
      results = results.where(
        (task) => !task.createdAt.isBefore(_filters.dateFrom!),
      );
    }
    if (_filters.dateTo != null) {
      results = results.where(
        (task) => !task.createdAt.isAfter(_filters.dateTo!),
      );
    }

    final sorted = results.toList()
      ..sortByCreated(descending: _filters.sortDescending);

    setState(() {
      _visibleTasks = sorted;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _openFilters,
        child: const Icon(Icons.filter_alt),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xE7E7E7FF),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download),
            tooltip: 'Import JSON file',
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            tooltip: 'add item',
          ),
        ],
        title: const Text('Tasks'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _visibleTasks.isEmpty
          ? const Center(child: Text('No tasks found'))
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _visibleTasks.length,
                itemBuilder: (context, index) {
                  return TaskWidget(task: _visibleTasks[index]);
                },
              ),
            ),
    );
  }
}
