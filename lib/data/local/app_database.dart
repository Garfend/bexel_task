import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement(_ftsTable);
          await customStatement(_ftsTriggerInsert);
          await customStatement(_ftsTriggerDelete);
          await customStatement(_ftsTriggerUpdate);
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final databaseFile = File(path.join(documentsDirectory.path, 'tasks.db'));
    return NativeDatabase(databaseFile);
  });
}

const _ftsTable = '''
CREATE VIRTUAL TABLE IF NOT EXISTS tasks_fts USING fts5(
  id UNINDEXED,
  title,
  description,
  type,
  content='tasks',
  content_rowid='id'
);
''';

const _ftsTriggerInsert = '''
CREATE TRIGGER IF NOT EXISTS tasks_ai AFTER INSERT ON tasks BEGIN
  INSERT INTO tasks_fts(rowid, id, title, description, type)
  VALUES (new.id, new.id, new.title, new.description, new.type);
END;
''';

const _ftsTriggerDelete = '''
CREATE TRIGGER IF NOT EXISTS tasks_ad AFTER DELETE ON tasks BEGIN
  INSERT INTO tasks_fts(tasks_fts, rowid, id, title, description, type)
  VALUES('delete', old.id, old.id, old.title, old.description, old.type);
END;
''';

const _ftsTriggerUpdate = '''
CREATE TRIGGER IF NOT EXISTS tasks_au AFTER UPDATE ON tasks BEGIN
  INSERT INTO tasks_fts(tasks_fts, rowid, id, title, description, type)
  VALUES('delete', old.id, old.id, old.title, old.description, old.type);
  INSERT INTO tasks_fts(rowid, id, title, description, type)
  VALUES(new.id, new.id, new.title, new.description, new.type);
END;
''';

@DriftAccessor(tables: [Tasks])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(AppDatabase db) : super(db);

  Stream<List<Task>> watchTasks({
    String? keyword,
    String? status,
    String? type,
    DateTime? from,
    DateTime? to,
    bool desc = true,
  }) {
    final where = <String>[];
    final variables = <Variable>[];

    if (keyword != null && keyword.trim().isNotEmpty) {
      final normalized = keyword
          .trim()
          .split(RegExp(r'\s+'))
          .where((term) => term.isNotEmpty)
          .map((term) => '$term*')
          .join(' ');
      where.add(
          'tasks.id IN (SELECT id FROM tasks_fts WHERE tasks_fts MATCH ?)');
      variables.add(Variable<String>(normalized));
    }
    if (status != null && status.isNotEmpty) {
      where.add('tasks.status = ?');
      variables.add(Variable<String>(status));
    }
    if (type != null && type.isNotEmpty) {
      where.add('tasks.type = ?');
      variables.add(Variable<String>(type));
    }
    if (from != null) {
      where.add('tasks.created_at >= ?');
      variables.add(Variable<DateTime>(from));
    }
    if (to != null) {
      where.add('tasks.created_at <= ?');
      variables.add(Variable<DateTime>(to));
    }

    final buffer = StringBuffer('SELECT * FROM tasks');
    if (where.isNotEmpty) {
      buffer.write(' WHERE ');
      buffer.write(where.join(' AND '));
    }
    buffer.write(' ORDER BY tasks.created_at ${desc ? 'DESC' : 'ASC'}');

    final query = customSelect(
      buffer.toString(),
      variables: variables,
      readsFrom: {tasks},
    );

    return query.watch().map(
          (rows) => rows
              .map(
                (row) => Task(
                  id: row.read<int>('id'),
                  title: row.read<String>('title'),
                  description: row.read<String>('description'),
                  type: row.read<String>('type'),
                  status: row.read<String>('status'),
                  createdAt: row.read<DateTime>('created_at'),
                ),
              )
              .toList(),
        );
  }

  Future<int> insertTask(TasksCompanion task) {
    return into(tasks).insertOnConflictUpdate(task);
  }

  Future<bool> updateTaskRow(Task task) {
    return update(tasks).replace(task);
  }

  Future<int> deleteTaskById(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> upsertAll(List<Task> rows,
      {bool clearBeforeInsert = false}) async {
    await transaction(() async {
      if (clearBeforeInsert) {
        await delete(tasks).go();
      }
      await batch((batch) {
        batch.insertAllOnConflictUpdate(tasks, rows);
      });
    });
  }

  Future<List<String>> loadTypes() async {
    final typeQuery = selectOnly(tasks, distinct: true)..addColumns([tasks.type]);
    typeQuery.orderBy([OrderingTerm.asc(tasks.type)]);
    final results = await typeQuery.map((row) => row.read(tasks.type)!).get();
    return results;
  }
}
