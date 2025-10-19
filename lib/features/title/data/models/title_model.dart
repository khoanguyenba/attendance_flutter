import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/title.dart';

class TitleModel extends Title {
  const TitleModel({
    required super.id,
    required super.name,
    super.description,
    required super.createdAt,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory TitleModel.fromListJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] is Timestamp 
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String 
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TitleModel.fromCreateJson(Map<String, dynamic> json) {
    return TitleModel(
      id: json['id'] as String,
      name: '',
      createdAt: DateTime.now(),
    );
  }
}
