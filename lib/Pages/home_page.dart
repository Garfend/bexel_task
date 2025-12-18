import 'package:bexel_task/widgets/task_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('task'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [TaskWidget(task: task)],
      ),
    );
  }
}
