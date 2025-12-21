import 'package:json_annotation/json_annotation.dart';
import 'location_model.dart';

part 'campaign_pin_model.g.dart';

@JsonEnum()
enum CampaignType { retail, food, entertainment, gas, shopping, exclusive }

@JsonEnum()
enum LoyaltyLevel { bronze, silver, gold, platinum }

@JsonSerializable()
class RewardModel {
  final String id;
  final String title;
  final String description;
  final double? discountPercentage;
  final double? discountAmount;
  final DateTime? expiresAt;
  final bool isExclusive;
  final LoyaltyLevel? requiredLoyaltyLevel;

  const RewardModel({
    required this.id,
    required this.title,
    required this.description,
    this.discountPercentage,
    this.discountAmount,
    this.expiresAt,
    this.isExclusive = false,
    this.requiredLoyaltyLevel,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) =>
      _$RewardModelFromJson(json);

  Map<String, dynamic> toJson() => _$RewardModelToJson(this);

  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? false;

  RewardModel copyWith({
    String? id,
    String? title,
    String? description,
    double? discountPercentage,
    double? discountAmount,
    DateTime? expiresAt,
    bool? isExclusive,
    LoyaltyLevel? requiredLoyaltyLevel,
  }) {
    return RewardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      expiresAt: expiresAt ?? this.expiresAt,
      isExclusive: isExclusive ?? this.isExclusive,
      requiredLoyaltyLevel: requiredLoyaltyLevel ?? this.requiredLoyaltyLevel,
    );
  }
}

@JsonSerializable()
class CampaignPinModel {
  final String id;
  final String title;
  final String description;
  final LocationModel location;
  final CampaignType type;
  final List<RewardModel> rewards;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final LoyaltyLevel? requiredLoyaltyLevel;
  final double radiusMeters;

  const CampaignPinModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    this.rewards = const [],
    this.imageUrl,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.requiredLoyaltyLevel,
    this.radiusMeters = 100.0,
  });

  factory CampaignPinModel.fromJson(Map<String, dynamic> json) =>
      _$CampaignPinModelFromJson(json);

  Map<String, dynamic> toJson() => _$CampaignPinModelToJson(this);

  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? false;

  double distanceFromUser(LocationModel userLocation) {
    return location.distanceTo(userLocation);
  }

  bool isWithinRadius(LocationModel userLocation) {
    return distanceFromUser(userLocation) <= radiusMeters;
  }

  bool isVisibleToUser(LoyaltyLevel? userLoyaltyLevel) {
    if (requiredLoyaltyLevel == null) return true;
    if (userLoyaltyLevel == null) return false;

    final loyaltyLevels = LoyaltyLevel.values;
    final requiredIndex = loyaltyLevels.indexOf(requiredLoyaltyLevel!);
    final userIndex = loyaltyLevels.indexOf(userLoyaltyLevel);

    return userIndex >= requiredIndex;
  }

  CampaignPinModel copyWith({
    String? id,
    String? title,
    String? description,
    LocationModel? location,
    CampaignType? type,
    List<RewardModel>? rewards,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isActive,
    LoyaltyLevel? requiredLoyaltyLevel,
    double? radiusMeters,
  }) {
    return CampaignPinModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      type: type ?? this.type,
      rewards: rewards ?? this.rewards,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      requiredLoyaltyLevel: requiredLoyaltyLevel ?? this.requiredLoyaltyLevel,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CampaignPinModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CampaignPinModel(id: $id, title: $title, type: $type)';
  }
}
