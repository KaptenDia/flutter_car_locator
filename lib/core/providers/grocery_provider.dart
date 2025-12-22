import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../constants/constants.dart';

part 'grocery_provider.g.dart';

// Pre-filled grocery items
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

@Riverpod(keepAlive: true)
class ActiveGroceryListIdNotifier extends _$ActiveGroceryListIdNotifier {
  @override
  String? build() {
    return StorageService.instance.getString(
      AppConstants.activeGroceryListIdKey,
    );
  }

  void set(String id) {
    StorageService.instance.setString(AppConstants.activeGroceryListIdKey, id);
    state = id;
  }
}

@Riverpod(keepAlive: true)
class AllGroceryListsNotifier extends _$AllGroceryListsNotifier {
  @override
  List<GroceryListModel> build() {
    return _loadAllLists();
  }

  List<GroceryListModel> _loadAllLists() {
    final lists = StorageService.instance.getObject<List<dynamic>>(
      AppConstants.allGroceryListsKey,
      (json) => json as List<dynamic>,
    );

    if (lists == null || lists.isEmpty) {
      final oldList = StorageService.instance.getObject<GroceryListModel>(
        AppConstants.groceryListKey,
        (json) => GroceryListModel.fromJson(json),
      );

      final defaultList = oldList ?? _createDefaultList();
      final collection = [defaultList];
      _saveAllLists(collection);
      return collection;
    }

    return lists
        .map((json) => GroceryListModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  GroceryListModel _createDefaultList() {
    const uuid = Uuid();
    return GroceryListModel(
      id: uuid.v4(),
      name: 'My Grocery List',
      items: _defaultGroceryItems,
      createdAt: DateTime.now(),
    );
  }

  void _saveAllLists(List<GroceryListModel> lists) {
    StorageService.instance.setObject(
      AppConstants.allGroceryListsKey,
      lists.map((l) => l.toJson()).toList(),
    );
  }

  void updateList(GroceryListModel updatedList) {
    state = state.map((l) => l.id == updatedList.id ? updatedList : l).toList();
    _saveAllLists(state);
  }

  void addList(GroceryListModel newList) {
    state = [...state, newList];
    _saveAllLists(state);
  }

  void removeList(String id) {
    if (state.length <= 1) return;

    state = state.where((l) => l.id != id).toList();
    _saveAllLists(state);
    final activeId = ref.read(activeGroceryListIdNotifierProvider);
    if (activeId == id) {
      ref
          .read(activeGroceryListIdNotifierProvider.notifier)
          .set(state.first.id);
    }
  }

  void createNewList(String name) {
    const uuid = Uuid();
    final newList = GroceryListModel(
      id: uuid.v4(),
      name: name,
      items: [],
      createdAt: DateTime.now(),
    );

    addList(newList);
    ref.read(activeGroceryListIdNotifierProvider.notifier).set(newList.id);
  }

  void duplicateList(GroceryListModel list) {
    const uuid = Uuid();
    final duplicatedList = list.copyWith(
      id: uuid.v4(),
      name: '${list.name} (Copy)',
      isSentToValet: false,
      createdAt: DateTime.now(),
      updatedAt: null,
      items: list.items
          .map((item) => item.copyWith(id: uuid.v4(), isCompleted: false))
          .toList(),
    );

    addList(duplicatedList);
    ref
        .read(activeGroceryListIdNotifierProvider.notifier)
        .set(duplicatedList.id);
  }

  void switchList(String id) {
    ref.read(activeGroceryListIdNotifierProvider.notifier).set(id);
  }
}

@Riverpod(keepAlive: true)
class GroceryListNotifier extends _$GroceryListNotifier {
  @override
  GroceryListModel? build() {
    final activeId = ref.watch(activeGroceryListIdNotifierProvider);
    final allLists = ref.watch(allGroceryListsNotifierProvider);

    if (activeId == null && allLists.isNotEmpty) {
      return allLists.first;
    }

    return allLists.firstWhere(
      (l) => l.id == activeId,
      orElse: () => allLists.first,
    );
  }

  void addItem(GroceryItemModel item) {
    if (state != null) {
      final updatedList = state!.copyWith(
        items: [...state!.items, item],
        updatedAt: DateTime.now(),
      );
      ref
          .read(allGroceryListsNotifierProvider.notifier)
          .updateList(updatedList);
    }
  }

  void removeItem(String itemId) {
    if (state != null) {
      final updatedList = state!.copyWith(
        items: state!.items.where((item) => item.id != itemId).toList(),
        updatedAt: DateTime.now(),
      );
      ref
          .read(allGroceryListsNotifierProvider.notifier)
          .updateList(updatedList);
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
      ref
          .read(allGroceryListsNotifierProvider.notifier)
          .updateList(updatedList);
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
      ref
          .read(allGroceryListsNotifierProvider.notifier)
          .updateList(updatedList);
    }
  }

  void sendToValet() {
    if (state != null && !state!.isSentToValet) {
      final updatedList = state!.copyWith(
        isSentToValet: true,
        updatedAt: DateTime.now(),
      );
      ref
          .read(allGroceryListsNotifierProvider.notifier)
          .updateList(updatedList);
      NotificationService.instance.showGroceryListSentNotification();
    }
  }

  void renameGroceryList(String name) {
    if (state != null) {
      final updatedList = state!.copyWith(
        name: name,
        updatedAt: DateTime.now(),
      );
      ref
          .read(allGroceryListsNotifierProvider.notifier)
          .updateList(updatedList);
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
