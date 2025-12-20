import 'package:flutter/material.dart';

import 'Pages/home_page.dart';
import 'data/datasource/task_datasource.dart';
import 'data/local/app_database.dart';
import 'data/repository/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class _Dependencies {
  final AppDatabase db;
  final TaskRepository repository;

  _Dependencies(this.db, this.repository);
}

Future<_Dependencies> _bootstrap() async {
  final db = AppDatabase();
  try {
    await db.customSelect('SELECT 1').get();
  } catch (err) {
    await db.close();
    rethrow;
  }
  final repository = TaskRepositoryImp(TaskDataSourceImp(), TaskDao(db));
  return _Dependencies(db, repository);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeXel Technical Task',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<_Dependencies>(
        future: _bootstrap(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: Text(
                  'Failed to initialize database:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final deps = snapshot.data!;
          return HomePage(
            db: deps.db,
            repository: deps.repository,
          );
        },
      ),
    );
  }
}
