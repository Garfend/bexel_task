import 'package:bexel_task/data/model/task_filters.dart';
import 'package:flutter/material.dart';

class TaskFilterControls extends StatelessWidget {
  final TaskFilters filters;
  final List<String> availableTypes;
  final ValueChanged<TaskFilters> onChanged;

  const TaskFilterControls({
    super.key,
    required this.filters,
    required this.availableTypes,
    required this.onChanged,
  });

  void _update(TaskFilters next) => onChanged(next);

  @override
  Widget build(BuildContext context) {
    final typeOptions = [null, ...availableTypes];
    final selectedType =
        typeOptions.contains(filters.type) ? filters.type : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: filters.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'Complete', child: Text('Complete')),
                  DropdownMenuItem(
                    value: 'Incomplete',
                    child: Text('Incomplete'),
                  ),
                ],
                onChanged: (value) => _update(filters.copyWith(status: value)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  isDense: true,
                ),
                items: typeOptions
                    .map(
                      (type) => DropdownMenuItem<String?>(
                        value: type,
                        child: Text(type ?? 'All'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _update(filters.copyWith(type: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<bool>(
          value: filters.sortDescending,
          decoration: const InputDecoration(
            labelText: 'Sort by creation date',
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(
              value: true,
              child: Text('Newest first'),
            ),
            DropdownMenuItem(
              value: false,
              child: Text('Oldest first'),
            ),
          ],
          onChanged: (value) =>
              _update(filters.copyWith(sortDescending: value ?? true)),
        ),
      ],
    );
  }
}
