import 'package:json_annotation/json_annotation.dart';
import 'location_model.dart';

part 'car_anchor_model.g.dart';

@JsonSerializable()
class CarAnchorModel {
  final String id;
  final LocationModel location;
  final String? name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const CarAnchorModel({
    required this.id,
    required this.location,
    this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory CarAnchorModel.fromJson(Map<String, dynamic> json) =>
      _$CarAnchorModelFromJson(json);

  Map<String, dynamic> toJson() => _$CarAnchorModelToJson(this);

  CarAnchorModel copyWith({
    String? id,
    LocationModel? location,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CarAnchorModel(
      id: id ?? this.id,
      location: location ?? this.location,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarAnchorModel &&
        other.id == id &&
        other.location == location;
  }

  @override
  int get hashCode => id.hashCode ^ location.hashCode;

  @override
  String toString() {
    return 'CarAnchorModel(id: $id, location: $location, name: $name)';
  }
}
