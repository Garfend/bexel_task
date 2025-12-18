import 'package:bexel_task/data/datasource/task_datasource.dart';
import 'package:bexel_task/data/repository/task_repository.dart';
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
  late final Future<List<TaskModel>> _task;
  late final TaskRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = TaskRepositoryImp(TaskDataSourceImp());
    _task = _repository.loadTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('task'),
      ),
      body: FutureBuilder(
          future: _task,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('error occured: ${snapshot.error}'),
              );
            }
            final tasks = snapshot.data;
            if (tasks!.isEmpty) {
              return Center(
                child: Text('no data found'),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return TaskWidget(task: tasks[index]);
              },
            );
          }),
    );
  }
}
