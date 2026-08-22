import '../../domain/entities/organization.dart';

/// Data model for [Organization] with JSON serialization
class OrganizationModel extends Organization {
  const OrganizationModel({
    required super.id,
    required super.name,
    required super.createdAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  factory OrganizationModel.fromEntity(Organization entity) {
    return OrganizationModel(
      id: entity.id,
      name: entity.name,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
