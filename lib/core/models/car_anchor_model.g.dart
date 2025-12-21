// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_anchor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarAnchorModel _$CarAnchorModelFromJson(Map<String, dynamic> json) =>
    CarAnchorModel(
      id: json['id'] as String,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      name: json['name'] as String?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$CarAnchorModelToJson(CarAnchorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': instance.location,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isActive': instance.isActive,
    };
