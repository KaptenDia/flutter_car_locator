import 'package:json_annotation/json_annotation.dart';
import 'campaign_pin_model.dart' show LoyaltyLevel;

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String email;
  final LoyaltyLevel loyaltyLevel;
  final int loyaltyPoints;
  final List<String> claimedRewards;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.loyaltyLevel = LoyaltyLevel.bronze,
    this.loyaltyPoints = 0,
    this.claimedRewards = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  bool hasClaimedReward(String rewardId) {
    return claimedRewards.contains(rewardId);
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    LoyaltyLevel? loyaltyLevel,
    int? loyaltyPoints,
    List<String>? claimedRewards,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, loyaltyLevel: $loyaltyLevel)';
  }
}
