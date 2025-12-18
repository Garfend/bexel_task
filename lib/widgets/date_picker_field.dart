import 'package:flutter/material.dart';

import '../utils/extensions/date_extensions.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool endOfDayDefault;
  final ValueChanged<DateTime?> onChanged;

  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.endOfDayDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await _pickDateTime(
          context,
          initial: value,
          endOfDayDefault: endOfDayDefault,
        );
        onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    value?.formattedDateTime ?? 'Not set',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
            if (value != null)
              IconButton(
                onPressed: () => onChanged(null),
                icon: const Icon(Icons.close, size: 18),
                splashRadius: 18,
                tooltip: 'Clear',
              ),
          ],
        ),
      ),
    );
  }
}

Future<DateTime?> _pickDateTime(
  BuildContext context, {
  DateTime? initial,
  bool endOfDayDefault = false,
}) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: DateTime(2000),
    lastDate: DateTime(2030),
  );
  if (date == null) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: initial != null
        ? TimeOfDay(hour: initial.hour, minute: initial.minute)
        : TimeOfDay.now(),
  );
  if (time == null) {
    return endOfDayDefault
        ? DateTime(date.year, date.month, date.day, 23, 59, 59, 999)
        : DateTime(date.year, date.month, date.day);
  }
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
