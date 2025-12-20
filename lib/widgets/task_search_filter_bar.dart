import 'dart:async';

import 'package:bexel_task/data/model/task_filters.dart';
import 'package:flutter/material.dart';

import 'task_filter_controls.dart';
import 'task_search_bar.dart';

class TaskSearchFilterBar extends StatefulWidget {
  final TaskFilters initialFilters;
  final List<String> availableTypes;
  final ValueChanged<TaskFilters> onChanged;

  const TaskSearchFilterBar({
    super.key,
    required this.initialFilters,
    required this.availableTypes,
    required this.onChanged,
  });

  @override
  State<TaskSearchFilterBar> createState() => _TaskSearchFilterBarState();
}

class _TaskSearchFilterBarState extends State<TaskSearchFilterBar> {
  late TaskFilters _filters;
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _searchController = TextEditingController(text: widget.initialFilters.query);
  }

  @override
  void didUpdateWidget(covariant TaskSearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final typeListChanged = widget.availableTypes != oldWidget.availableTypes;
    if (typeListChanged &&
        _filters.type != null &&
        !widget.availableTypes.contains(_filters.type)) {
      _updateFilters(_filters.copyWith(type: null));
    }

    final filtersChanged = widget.initialFilters != oldWidget.initialFilters &&
        widget.initialFilters != _filters;
    if (filtersChanged) {
      setState(() {
        _filters = widget.initialFilters;
        _searchController.text = widget.initialFilters.query;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _updateFilters(_filters.copyWith(query: query.trim()));
    });
  }

  void _updateFilters(TaskFilters next) {
    if (next == _filters) return;
    setState(() => _filters = next);
    widget.onChanged(next);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _updateFilters(_filters.copyWith(query: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TaskSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
            const SizedBox(height: 12),
            TaskFilterControls(
              filters: _filters,
              availableTypes: widget.availableTypes,
              onChanged: (updated) => _updateFilters(updated),
            ),
          ],
        ),
      ),
    );
  }
}
