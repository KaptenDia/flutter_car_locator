// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroceryItemModel _$GroceryItemModelFromJson(Map<String, dynamic> json) =>
    GroceryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit'] as String? ?? 'pcs',
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      addedAt: json['addedAt'] == null
          ? null
          : DateTime.parse(json['addedAt'] as String),
    );

Map<String, dynamic> _$GroceryItemModelToJson(GroceryItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'price': instance.price,
      'category': instance.category,
      'isCompleted': instance.isCompleted,
      'addedAt': instance.addedAt?.toIso8601String(),
    };

GroceryListModel _$GroceryListModelFromJson(Map<String, dynamic> json) =>
    GroceryListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => GroceryItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      isSentToValet: json['isSentToValet'] as bool? ?? false,
    );

Map<String, dynamic> _$GroceryListModelToJson(GroceryListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'items': instance.items,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'isSentToValet': instance.isSentToValet,
    };
