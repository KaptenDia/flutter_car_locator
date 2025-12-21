// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasLocationPermissionHash() =>
    r'87cd668f78582363fd4fcd28b9c58d5635c89913';

/// See also [hasLocationPermission].
@ProviderFor(hasLocationPermission)
final hasLocationPermissionProvider = AutoDisposeFutureProvider<bool>.internal(
  hasLocationPermission,
  name: r'hasLocationPermissionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasLocationPermissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasLocationPermissionRef = AutoDisposeFutureProviderRef<bool>;
String _$requestLocationPermissionHash() =>
    r'ff4869902857e844271e1b5ce94a3246fcb96a3c';

/// See also [requestLocationPermission].
@ProviderFor(requestLocationPermission)
final requestLocationPermissionProvider =
    AutoDisposeFutureProvider<bool>.internal(
      requestLocationPermission,
      name: r'requestLocationPermissionProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requestLocationPermissionHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequestLocationPermissionRef = AutoDisposeFutureProviderRef<bool>;
String _$locationNotifierHash() => r'0cae66512267cb374f3ee4c22dd3c66562e7f66e';

/// See also [LocationNotifier].
@ProviderFor(LocationNotifier)
final locationNotifierProvider =
    AutoDisposeNotifierProvider<LocationNotifier, LocationModel?>.internal(
      LocationNotifier.new,
      name: r'locationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationNotifier = AutoDisposeNotifier<LocationModel?>;
String _$locationStreamNotifierHash() =>
    r'f7a6475fe92c35642861b0fb218a6d705fe5d56a';

/// See also [LocationStreamNotifier].
@ProviderFor(LocationStreamNotifier)
final locationStreamNotifierProvider =
    AutoDisposeStreamNotifierProvider<
      LocationStreamNotifier,
      LocationModel?
    >.internal(
      LocationStreamNotifier.new,
      name: r'locationStreamNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationStreamNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationStreamNotifier = AutoDisposeStreamNotifier<LocationModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
