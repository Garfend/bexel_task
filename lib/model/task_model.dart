import 'dart:convert';

import 'package:equatable/equatable.dart';

class ConsultationResponse extends Equatable{
  final int id;
  final String title;
  final String description;
  final String type;
  final String status;
  final DateTime createdAt;

  const ConsultationResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
  });

  ConsultationResponse copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    String? status,
    DateTime? createdAt,
  }) =>
      ConsultationResponse(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        type: type ?? this.type,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );

  factory ConsultationResponse.fromJson(String str) => ConsultationResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ConsultationResponse.fromMap(Map<String, dynamic> json) => ConsultationResponse(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    type: json["type"],
    status: json["status"],
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "description": description,
    "type": type,
    "status": status,
    "createdAt": createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, title, description, type, status, createdAt];
}
