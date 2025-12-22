// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groceryItemsByCategoryHash() =>
    r'c343c65a944e38f13b71cd0486fbd3511caee0b6';

/// See also [groceryItemsByCategory].
@ProviderFor(groceryItemsByCategory)
final groceryItemsByCategoryProvider =
    AutoDisposeProvider<List<GroceryItemModel>>.internal(
      groceryItemsByCategory,
      name: r'groceryItemsByCategoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groceryItemsByCategoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryItemsByCategoryRef =
    AutoDisposeProviderRef<List<GroceryItemModel>>;
String _$groupedGroceryItemsHash() =>
    r'314223ad12375d362375cdbbd8684386a6d61c10';

/// See also [groupedGroceryItems].
@ProviderFor(groupedGroceryItems)
final groupedGroceryItemsProvider =
    AutoDisposeProvider<Map<String, List<GroceryItemModel>>>.internal(
      groupedGroceryItems,
      name: r'groupedGroceryItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groupedGroceryItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupedGroceryItemsRef =
    AutoDisposeProviderRef<Map<String, List<GroceryItemModel>>>;
String _$totalGroceryPriceHash() => r'3f2b6d040f939ce088441be116be27bd95d61a31';

/// See also [totalGroceryPrice].
@ProviderFor(totalGroceryPrice)
final totalGroceryPriceProvider = AutoDisposeProvider<double>.internal(
  totalGroceryPrice,
  name: r'totalGroceryPriceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalGroceryPriceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalGroceryPriceRef = AutoDisposeProviderRef<double>;
String _$totalGroceryItemsHash() => r'2cdd4c9be71772a60ee7ec8c5d6acb70bf1d5ef7';

/// See also [totalGroceryItems].
@ProviderFor(totalGroceryItems)
final totalGroceryItemsProvider = AutoDisposeProvider<int>.internal(
  totalGroceryItems,
  name: r'totalGroceryItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$totalGroceryItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TotalGroceryItemsRef = AutoDisposeProviderRef<int>;
String _$completedGroceryItemsHash() =>
    r'b59009935009a8c7b25b6fffb9e40d66b2822658';

/// See also [completedGroceryItems].
@ProviderFor(completedGroceryItems)
final completedGroceryItemsProvider = AutoDisposeProvider<int>.internal(
  completedGroceryItems,
  name: r'completedGroceryItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedGroceryItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CompletedGroceryItemsRef = AutoDisposeProviderRef<int>;
String _$groceryProgressHash() => r'75fed8164a5f9590ffa96708f4bdd2710518a802';

/// See also [groceryProgress].
@ProviderFor(groceryProgress)
final groceryProgressProvider = AutoDisposeProvider<double>.internal(
  groceryProgress,
  name: r'groceryProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groceryProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroceryProgressRef = AutoDisposeProviderRef<double>;
String _$activeGroceryListIdNotifierHash() =>
    r'e4eb1c22c535265a09f08c3e6ddcb3ab33873f1d';

/// See also [ActiveGroceryListIdNotifier].
@ProviderFor(ActiveGroceryListIdNotifier)
final activeGroceryListIdNotifierProvider =
    NotifierProvider<ActiveGroceryListIdNotifier, String?>.internal(
      ActiveGroceryListIdNotifier.new,
      name: r'activeGroceryListIdNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeGroceryListIdNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveGroceryListIdNotifier = Notifier<String?>;
String _$allGroceryListsNotifierHash() =>
    r'277a98ca27176825790968aedf565e0f40b5a1e5';

/// See also [AllGroceryListsNotifier].
@ProviderFor(AllGroceryListsNotifier)
final allGroceryListsNotifierProvider =
    NotifierProvider<AllGroceryListsNotifier, List<GroceryListModel>>.internal(
      AllGroceryListsNotifier.new,
      name: r'allGroceryListsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allGroceryListsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AllGroceryListsNotifier = Notifier<List<GroceryListModel>>;
String _$groceryListNotifierHash() =>
    r'89edb83a498efbf626ff81579221442de9cf3bc6';

/// See also [GroceryListNotifier].
@ProviderFor(GroceryListNotifier)
final groceryListNotifierProvider =
    NotifierProvider<GroceryListNotifier, GroceryListModel?>.internal(
      GroceryListNotifier.new,
      name: r'groceryListNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groceryListNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GroceryListNotifier = Notifier<GroceryListModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
