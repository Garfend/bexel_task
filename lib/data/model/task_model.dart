import 'dart:convert';

import 'package:equatable/equatable.dart';

class TaskModel extends Equatable{
  final int? id;
  final String title;
  final String description;
  final String type;
  final String status;
  final DateTime createdAt;
  final int revision;

  TaskModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    this.revision = 0,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    String? status,
    DateTime? createdAt,
    int? revision,
  }) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        revision: revision ?? this.revision,
      );

  factory TaskModel.fromJson(String str) => TaskModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TaskModel.fromMap(Map<String, dynamic> json) => TaskModel(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    type: json["type"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
    revision: json["revision"] is int
        ? json["revision"] as int
        : int.tryParse(json["revision"]?.toString() ?? '') ?? 0,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "description": description,
    "type": type,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
    "revision": revision,
  };

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        status,
        createdAt,
        revision,
      ];
}
