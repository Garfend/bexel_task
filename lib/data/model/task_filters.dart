import 'package:equatable/equatable.dart';

class TaskFilters extends Equatable {
  static const _unset = Object();
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
    Object? status = _unset,
    Object? type = _unset,
    bool? sortDescending,
    Object? dateFrom = _unset,
    Object? dateTo = _unset,
  }) {
    return TaskFilters(
      query: query ?? this.query,
      status: status == _unset ? this.status : status as String?,
      type: type == _unset ? this.type : type as String?,
      sortDescending: sortDescending ?? this.sortDescending,
      dateFrom: dateFrom == _unset ? this.dateFrom : dateFrom as DateTime?,
      dateTo: dateTo == _unset ? this.dateTo : dateTo as DateTime?,
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
