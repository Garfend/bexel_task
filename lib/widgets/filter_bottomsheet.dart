import 'package:flutter/material.dart';

import 'date_picker_field.dart';

class TaskFilters {
  final String query;
  final String? status;
  final String? type;
  final bool sortDescending;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const TaskFilters({
    this.query = '',
    this.status,
    this.type,
    this.sortDescending = true,
    this.dateFrom,
    this.dateTo,
  });
}

class _FilterSheetContent extends StatefulWidget {
  final TaskFilters initial;
  final List<String> availableTypes;

  const _FilterSheetContent({
    required this.initial,
    required this.availableTypes,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late final TextEditingController _queryController;
  late String? _status;
  late String? _type;
  late bool _sortDesc;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initial.query);
    _status = widget.initial.status;
    _type = widget.initial.type;
    _sortDesc = widget.initial.sortDescending;
    _dateFrom = widget.initial.dateFrom;
    _dateTo = widget.initial.dateTo;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildChoiceChips({
      required List<String?> values,
      required String? selected,
      required ValueChanged<String?> onChanged,
    }) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: values
            .map((value) => ChoiceChip(
                  label: Text(value ?? 'All'),
                  selected: selected == value,
                  onSelected: (_) => setState(() => onChanged(value)),
                ))
            .toList(),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Search & Filter',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search tasks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            buildChoiceChips(
              values: const [null, 'Complete', 'Incomplete'],
              selected: _status,
              onChanged: (val) => _status = val,
            ),
            const SizedBox(height: 16),
            const Text(
              'Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  direction: Axis.vertical,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in [null, ...widget.availableTypes])
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 90,
                          maxWidth: 120,
                        ),
                        child: ChoiceChip(
                          label: Text(
                            value ?? 'All',
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected: _type == value,
                          onSelected: (_) => setState(() => _type = value),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Date range (optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DatePickerField(
                    label: 'From',
                    value: _dateFrom,
                    endOfDayDefault: false,
                    onChanged: (picked) => setState(() => _dateFrom = picked),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    label: 'To',
                    value: _dateTo,
                    endOfDayDefault: true,
                    onChanged: (picked) => setState(() => _dateTo = picked),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Sort by date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Newest'),
                  selected: _sortDesc,
                  onSelected: (_) => setState(() => _sortDesc = true),
                ),
                ChoiceChip(
                  label: const Text('Oldest'),
                  selected: !_sortDesc,
                  onSelected: (_) => setState(() => _sortDesc = false),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 128,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(TaskFilters(
                    query: _queryController.text,
                    status: _status,
                    type: _type,
                    sortDescending: _sortDesc,
                    dateFrom: _dateFrom,
                    dateTo: _dateTo,
                  ));
                },
                child: const Text('Search'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
Future<TaskFilters?> showFilterBottomSheet({
  required BuildContext context,
  required TaskFilters initial,
  required List<String> availableTypes,
}) async {
  return showModalBottomSheet<TaskFilters>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _FilterSheetContent(
      initial: initial,
      availableTypes: availableTypes,
    ),
  );
}
