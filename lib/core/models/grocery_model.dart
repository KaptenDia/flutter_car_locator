import 'package:json_annotation/json_annotation.dart';

part 'grocery_model.g.dart';

@JsonSerializable()
class GroceryItemModel {
  final String id;
  final String name;
  final String? description;
  final int quantity;
  final String unit;
  final double? price;
  final String? category;
  final bool isCompleted;
  final DateTime? addedAt;

  const GroceryItemModel({
    required this.id,
    required this.name,
    this.description,
    this.quantity = 1,
    this.unit = 'pcs',
    this.price,
    this.category,
    this.isCompleted = false,
    this.addedAt,
  });

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) =>
      _$GroceryItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroceryItemModelToJson(this);

  GroceryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    String? unit,
    double? price,
    String? category,
    bool? isCompleted,
    DateTime? addedAt,
  }) {
    return GroceryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroceryItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GroceryItemModel(id: $id, name: $name, quantity: $quantity $unit)';
  }
}

@JsonSerializable()
class GroceryListModel {
  final String id;
  final String name;
  final List<GroceryItemModel> items;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSentToValet;

  const GroceryListModel({
    required this.id,
    required this.name,
    this.items = const [],
    required this.createdAt,
    this.updatedAt,
    this.isSentToValet = false,
  });

  factory GroceryListModel.fromJson(Map<String, dynamic> json) =>
      _$GroceryListModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroceryListModelToJson(this);

  int get totalItems => items.length;
  int get completedItems => items.where((item) => item.isCompleted).length;
  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;

  double get totalPrice {
    return items
        .where((item) => item.price != null)
        .fold(0.0, (sum, item) => sum + (item.price! * item.quantity));
  }

  GroceryListModel copyWith({
    String? id,
    String? name,
    List<GroceryItemModel>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSentToValet,
  }) {
    return GroceryListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSentToValet: isSentToValet ?? this.isSentToValet,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroceryListModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'GroceryListModel(id: $id, name: $name, items: ${items.length})';
  }
}
