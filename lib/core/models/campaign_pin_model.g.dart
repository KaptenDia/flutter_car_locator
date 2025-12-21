// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_pin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RewardModel _$RewardModelFromJson(Map<String, dynamic> json) => RewardModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
  discountAmount: (json['discountAmount'] as num?)?.toDouble(),
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  isExclusive: json['isExclusive'] as bool? ?? false,
  requiredLoyaltyLevel: $enumDecodeNullable(
    _$LoyaltyLevelEnumMap,
    json['requiredLoyaltyLevel'],
  ),
);

Map<String, dynamic> _$RewardModelToJson(
  RewardModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'discountPercentage': instance.discountPercentage,
  'discountAmount': instance.discountAmount,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'isExclusive': instance.isExclusive,
  'requiredLoyaltyLevel': _$LoyaltyLevelEnumMap[instance.requiredLoyaltyLevel],
};

const _$LoyaltyLevelEnumMap = {
  LoyaltyLevel.bronze: 'bronze',
  LoyaltyLevel.silver: 'silver',
  LoyaltyLevel.gold: 'gold',
  LoyaltyLevel.platinum: 'platinum',
};

CampaignPinModel _$CampaignPinModelFromJson(Map<String, dynamic> json) =>
    CampaignPinModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      type: $enumDecode(_$CampaignTypeEnumMap, json['type']),
      rewards:
          (json['rewards'] as List<dynamic>?)
              ?.map((e) => RewardModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      requiredLoyaltyLevel: $enumDecodeNullable(
        _$LoyaltyLevelEnumMap,
        json['requiredLoyaltyLevel'],
      ),
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 100.0,
    );

Map<String, dynamic> _$CampaignPinModelToJson(
  CampaignPinModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'type': _$CampaignTypeEnumMap[instance.type]!,
  'rewards': instance.rewards,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt.toIso8601String(),
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'isActive': instance.isActive,
  'requiredLoyaltyLevel': _$LoyaltyLevelEnumMap[instance.requiredLoyaltyLevel],
  'radiusMeters': instance.radiusMeters,
};

const _$CampaignTypeEnumMap = {
  CampaignType.retail: 'retail',
  CampaignType.food: 'food',
  CampaignType.entertainment: 'entertainment',
  CampaignType.gas: 'gas',
  CampaignType.shopping: 'shopping',
  CampaignType.exclusive: 'exclusive',
};
