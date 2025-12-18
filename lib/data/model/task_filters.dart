import 'package:equatable/equatable.dart';

class TaskFilters extends Equatable {
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

  TaskFilters copyWith({
    String? query,
    String? status,
    String? type,
    bool? sortDescending,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return TaskFilters(
      query: query ?? this.query,
      status: status ?? this.status,
      type: type ?? this.type,
      sortDescending: sortDescending ?? this.sortDescending,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  TaskFilters clearedDates() => copyWith(dateFrom: null, dateTo: null);

  @override
  List<Object?> get props => [
        query.trim(),
        status,
        type,
        sortDescending,
        dateFrom,
        dateTo,
      ];
}
