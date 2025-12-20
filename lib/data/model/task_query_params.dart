import 'package:equatable/equatable.dart';

class TaskQueryParams extends Equatable {
  final String keyword;
  final String? status;
  final String? type;
  final bool sortDescending;
  final DateTime? from;
  final DateTime? to;

  const TaskQueryParams({
    this.keyword = '',
    this.status,
    this.type,
    this.sortDescending = true,
    this.from,
    this.to,
  });

  TaskQueryParams copyWith({
    String? keyword,
    String? status,
    String? type,
    bool? sortDescending,
    DateTime? from,
    DateTime? to,
  }) {
    return TaskQueryParams(
      keyword: keyword ?? this.keyword,
      status: status ?? this.status,
      type: type ?? this.type,
      sortDescending: sortDescending ?? this.sortDescending,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [
        keyword.trim(),
        status,
        type,
        sortDescending,
        from,
        to,
      ];
}
