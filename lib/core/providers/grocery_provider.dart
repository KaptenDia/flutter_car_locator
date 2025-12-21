import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../constants/constants.dart';

part 'grocery_provider.g.dart';

// Pre-filled grocery items for demonstration
final _defaultGroceryItems = [
  const GroceryItemModel(
    id: 'item_1',
    name: 'Milk',
    description: 'Fresh whole milk 1L',
    quantity: 2,
    unit: 'bottles',
    price: 7.50,
    category: 'Dairy',
  ),
  const GroceryItemModel(
    id: 'item_2',
    name: 'Bread',
    description: 'Whole wheat bread',
    quantity: 1,
    unit: 'loaf',
    price: 4.50,
    category: 'Bakery',
  ),
  const GroceryItemModel(
    id: 'item_3',
    name: 'Eggs',
    description: 'Free-range chicken eggs',
    quantity: 12,
    unit: 'pieces',
    price: 8.90,
    category: 'Dairy',
  ),
  const GroceryItemModel(
    id: 'item_4',
    name: 'Bananas',
    description: 'Fresh bananas',
    quantity: 1,
    unit: 'bunch',
    price: 6.00,
    category: 'Fruits',
  ),
  const GroceryItemModel(
    id: 'item_5',
    name: 'Rice',
    description: 'Premium jasmine rice 5kg',
    quantity: 1,
    unit: 'bag',
    price: 28.00,
    category: 'Grains',
  ),
];

@riverpod
class GroceryListNotifier extends _$GroceryListNotifier {
  @override
  GroceryListModel? build() {
    return _loadGroceryList();
  }

  GroceryListModel? _loadGroceryList() {
    final groceryList = StorageService.instance.getObject<GroceryListModel>(
      AppConstants.groceryListKey,
      (json) => GroceryListModel.fromJson(json),
    );

    // If no saved list, create default one
    if (groceryList == null) {
      const uuid = Uuid();
      final defaultList = GroceryListModel(
        id: uuid.v4(),
        name: 'My Grocery List',
        items: _defaultGroceryItems,
        createdAt: DateTime.now(),
      );
      _saveGroceryList(defaultList);
      return defaultList;
    } else {
      return groceryList;
    }
  }

  void _saveGroceryList(GroceryListModel groceryList) {
    // Fire and forget - no need to await for UI responsiveness
    StorageService.instance.setObject(
      AppConstants.groceryListKey,
      groceryList.toJson(),
    );
  }

  void addItem(GroceryItemModel item) {
    if (state != null) {
      final updatedList = state!.copyWith(
        items: [...state!.items, item],
        updatedAt: DateTime.now(),
      );
      _saveGroceryList(updatedList);
      state = updatedList;
    }
  }

  void removeItem(String itemId) {
    if (state != null) {
      final updatedList = state!.copyWith(
        items: state!.items.where((item) => item.id != itemId).toList(),
        updatedAt: DateTime.now(),
      );
      _saveGroceryList(updatedList);
      state = updatedList;
    }
  }

  void updateItem(GroceryItemModel updatedItem) {
    if (state != null) {
      final updatedItems = state!.items.map((item) {
        return item.id == updatedItem.id ? updatedItem : item;
      }).toList();

      final updatedList = state!.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      _saveGroceryList(updatedList);
      state = updatedList;
    }
  }

  void toggleItemCompletion(String itemId) {
    if (state != null) {
      final item = state!.items.firstWhere((item) => item.id == itemId);
      final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
      updateItem(updatedItem);
    }
  }

  void clearCompletedItems() {
    if (state != null) {
      final updatedList = state!.copyWith(
        items: state!.items.where((item) => !item.isCompleted).toList(),
        updatedAt: DateTime.now(),
      );
      _saveGroceryList(updatedList);
      state = updatedList;
    }
  }

  void sendToValet() {
    if (state != null && !state!.isSentToValet) {
      final updatedList = state!.copyWith(
        isSentToValet: true,
        updatedAt: DateTime.now(),
      );
      _saveGroceryList(updatedList);
      state = updatedList;

      // Show notification (fire and forget)
      NotificationService.instance.showGroceryListSentNotification();
    }
  }

  void createNewGroceryList(String name) {
    const uuid = Uuid();
    final newList = GroceryListModel(
      id: uuid.v4(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );

    _saveGroceryList(newList);
    state = newList;
  }

  void duplicateCurrentList() {
    if (state != null) {
      const uuid = Uuid();
      final duplicatedList = state!.copyWith(
        id: uuid.v4(),
        name: '${state!.name} (Copy)',
        isSentToValet: false,
        createdAt: DateTime.now(),
        updatedAt: null,
        items: state!.items
            .map((item) => item.copyWith(id: uuid.v4(), isCompleted: false))
            .toList(),
      );

      _saveGroceryList(duplicatedList);
      state = duplicatedList;
    }
  }
}

@riverpod
List<GroceryItemModel> groceryItemsByCategory(Ref ref) {
  final groceryList = ref.watch(groceryListNotifierProvider);
  if (groceryList == null) return [];

  final items = [...groceryList.items];
  items.sort((a, b) {
    // First sort by category, then by completion status, then by name
    final categoryComparison = (a.category ?? '').compareTo(b.category ?? '');
    if (categoryComparison != 0) return categoryComparison;

    final completionComparison = a.isCompleted.toString().compareTo(
      b.isCompleted.toString(),
    );
    if (completionComparison != 0) return completionComparison;

    return a.name.compareTo(b.name);
  });

  return items;
}

@riverpod
Map<String, List<GroceryItemModel>> groupedGroceryItems(Ref ref) {
  final items = ref.watch(groceryItemsByCategoryProvider);
  final Map<String, List<GroceryItemModel>> grouped = {};

  for (final item in items) {
    final category = item.category ?? 'Other';
    if (grouped[category] == null) {
      grouped[category] = [];
    }
    grouped[category]!.add(item);
  }

  return grouped;
}

@riverpod
double totalGroceryPrice(Ref ref) {
  final groceryList = ref.watch(groceryListNotifierProvider);
  return groceryList?.totalPrice ?? 0.0;
}

@riverpod
int totalGroceryItems(Ref ref) {
  final groceryList = ref.watch(groceryListNotifierProvider);
  return groceryList?.totalItems ?? 0;
}

@riverpod
int completedGroceryItems(Ref ref) {
  final groceryList = ref.watch(groceryListNotifierProvider);
  return groceryList?.completedItems ?? 0;
}

@riverpod
double groceryProgress(Ref ref) {
  final groceryList = ref.watch(groceryListNotifierProvider);
  return groceryList?.progress ?? 0.0;
}
