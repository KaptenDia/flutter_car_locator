// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  loyaltyLevel:
      $enumDecodeNullable(_$LoyaltyLevelEnumMap, json['loyaltyLevel']) ??
      LoyaltyLevel.bronze,
  loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
  claimedRewards:
      (json['claimedRewards'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'loyaltyLevel': _$LoyaltyLevelEnumMap[instance.loyaltyLevel]!,
  'loyaltyPoints': instance.loyaltyPoints,
  'claimedRewards': instance.claimedRewards,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$LoyaltyLevelEnumMap = {
  LoyaltyLevel.bronze: 'bronze',
  LoyaltyLevel.silver: 'silver',
  LoyaltyLevel.gold: 'gold',
  LoyaltyLevel.platinum: 'platinum',
};
