// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasLocationPermissionHash() =>
    r'b91ce751118d494e9df61d9fc9d5f0940d2327fd';

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
    r'6826eff4d5ec3d32006e60d5d2d0a955f9c0dfe0';

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
String _$locationNotifierHash() => r'07ff2ce688076eb19a9c60fdcf44d17d4b780bab';

/// See also [LocationNotifier].
@ProviderFor(LocationNotifier)
final locationNotifierProvider =
    NotifierProvider<LocationNotifier, LocationModel?>.internal(
      LocationNotifier.new,
      name: r'locationNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationNotifier = Notifier<LocationModel?>;
String _$locationStreamNotifierHash() =>
    r'98d9df9043fcb11034d88346ab4eb80d2e431734';

/// See also [LocationStreamNotifier].
@ProviderFor(LocationStreamNotifier)
final locationStreamNotifierProvider =
    StreamNotifierProvider<LocationStreamNotifier, LocationModel?>.internal(
      LocationStreamNotifier.new,
      name: r'locationStreamNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$locationStreamNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocationStreamNotifier = StreamNotifier<LocationModel?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
