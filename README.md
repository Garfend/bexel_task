### bexel_task

### 1) Data expansion and import
- The dataset was expanded offline (from a small sample to 10,000 unique tasks)
  and committed as `assets/data/data.json` using a python scrip made with ai.
- Import reads that JSON via `rootBundle` and inserts it with a batch upsert.

Relevant code:
- JSON load: `lib/data/datasource/task_datasource.dart`
- Import + batch upsert: `lib/data/repository/task_repository.dart`
- AppBar import action: `lib/Pages/home_page.dart`

### 2) Smart search (keyword + filters + sort)
- Keyword search uses SQLite FTS5.
- Filters: status + type.
- Sorting: creation date ascending/descending.

UI controls are in `lib/widgets/task_search_filter_bar.dart` and
`lib/widgets/task_filter_controls.dart`.

### 3) Reactive updates with Drift
- The query is a reactive `watch()` stream.
- `StreamBuilder` rebuilds the list automatically on insert/update/delete.
- FTS triggers keep the search index consistent after writes.

Performance notes for large data:
- Filtering and sorting happen in SQL, not in Dart.
- FTS5 avoids linear scans for keyword search.
- The list uses `ListView.builder` to keep UI work lazy.
- pagination is also a valid choise for handling bottlenecks.

### 4) Code snippets (query + reactive UI)

Flexible Drift query (keyword + filters + sort):

- First I read all filter values from `params` into local variables.

- After that I prepare two empty lists:
  - `where` SQL conditions
  - `variables` values for `?` placeholders

- After that I normalize the search keyword:
  - Trim spaces
  - Split by whitespace
  - Append `*` to each word
  - Example: `"code time"` `"code* time*"`

- After that I add the full-text search condition:
  - `tasks.id IN (SELECT id FROM tasks_fts WHERE tasks_fts MATCH ?)`
  - Push the normalized keyword into `variables`.

- After that if `status` exists, I add:
  - `tasks.status = ?`
  - Push `status` into `variables`.

- After that if `type` exists, I add:
  - `tasks.type = ?`
  - Push `type` into `variables`.

- After that if `from` exists, I add:
  - `tasks.created_at >= ?`
  - Push `from` into `variables`.

- After that if `to` exists, I add:
  - `tasks.created_at <= ?`
  - Push `to` into `variables`.

- After that I build the SQL query string:
  - Start with `SELECT * FROM tasks`
  - Append `WHERE` + conditions joined with `AND`
  - Append `ORDER BY tasks.created_at DESC : ASC`.

- After that I create a Drift `customSelect` query using the SQL and variables.

- After that I call `watch()` to get a reactive `Stream`.

- After that I map each returned row into a `Task` object and return `Stream<List<Task>>`.

```dart
  Stream<List<Task>> watchTasks(TaskQueryParams params) {
    final keyword = params.keyword;
    final status = params.status;
    final type = params.type;
    final from = params.from;
    final to = params.to;
    final desc = params.sortDescending;
    final where = <String>[];
    final variables = <Variable>[];

    if (keyword.trim().isNotEmpty) {
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
                  revision: row.read<int>('revision'),
                ),
              )
              .toList(),
        );
  }
```

Reactive UI listener:

- First `StreamBuilder` subscribes to the stream returned from `repository.watchTasks(...)`.

- After that `watchTasks` is a reactive DB query, so **any insert/update/delete** that affects the result will emit a new `List<TaskModel>`.

- After that whenever the stream emits, `builder` runs again with a new `snapshot`.

- After that you read the latest tasks from `snapshot.data ?? []`.

- After that `ListView.builder` rebuilds using the new `tasks` list, so the UI always matches the database.

```dart
StreamBuilder<List<TaskModel>>(
  stream: repository.watchTasks(
    keyword: filters.query,
    status: filters.status,
    type: filters.type,
    from: filters.dateFrom,
    to: filters.dateTo,
    desc: filters.sortDescending,
  ),
  builder: (context, snapshot) {
    final tasks = snapshot.data ?? [];
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) => TaskWidget(
        task: tasks[index],
        editItem: () => _openTaskForm(task: tasks[index]),
        deleteItem: () => _deleteTask(tasks[index]),
      ),
    );
  },
)
```

### 5) Problem-solving notes
- Rapid search input: debounced in the UI with a 250ms timer to avoid firing a
  new query per keystroke (`TaskSearchFilterBar`).
- Large list performance: keep filtering/sorting in SQL, use FTS5 for search,
  lazy-build the list, and add paging/indexes (pagination not implemented) if the dataset grows further.
- Data conflicts: updates use optimistic locking via the `revision` column.
  If a stale revision is submitted, the repository throws a
  `TaskConflictException` and the UI can reload the latest record.

## some clarifications
- The FTS table and triggers are created in `beforeOpen` so new writes always
  update the search index automatically.
- Import clears the existing `tasks` table before inserting the asset data.
