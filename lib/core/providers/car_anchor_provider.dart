import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../constants/constants.dart';
import 'location_provider.dart';

part 'car_anchor_provider.g.dart';

@Riverpod(keepAlive: true)
class CarAnchorNotifier extends _$CarAnchorNotifier {
  @override
  CarAnchorModel? build() {
    // Load saved car anchor immediately
    final carAnchor = StorageService.instance.getObject<CarAnchorModel>(
      AppConstants.carAnchorKey,
      (json) => CarAnchorModel.fromJson(json),
    );
    return (carAnchor != null && carAnchor.isActive) ? carAnchor : null;
  }

  Future<void> setCarLocation(
    LocationModel location, {
    String? name,
    String? description,
  }) async {
    const uuid = Uuid();
    final carAnchor = CarAnchorModel(
      id: uuid.v4(),
      location: location,
      name: name ?? 'My Car',
      description: description,
      createdAt: DateTime.now(),
      isActive: true,
    );

    await StorageService.instance.setObject(
      AppConstants.carAnchorKey,
      carAnchor.toJson(),
    );
    state = carAnchor;

    // Schedule a reminder notification
    await NotificationService.instance.showCarLocationReminderNotification();
  }

  Future<void> updateCarLocation(LocationModel location) async {
    if (state != null) {
      final updatedAnchor = state!.copyWith(
        location: location,
        updatedAt: DateTime.now(),
      );
      await StorageService.instance.setObject(
        AppConstants.carAnchorKey,
        updatedAnchor.toJson(),
      );
      state = updatedAnchor;
    }
  }

  Future<void> clearCarLocation() async {
    await StorageService.instance.remove(AppConstants.carAnchorKey);
    state = null;
  }

  Future<void> deactivateCarAnchor() async {
    if (state != null) {
      final deactivatedAnchor = state!.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );
      await StorageService.instance.setObject(
        AppConstants.carAnchorKey,
        deactivatedAnchor.toJson(),
      );
      state = deactivatedAnchor;
    }
  }
}

@Riverpod(keepAlive: true)
double? distanceToCar(Ref ref) {
  final carAnchor = ref.watch(carAnchorNotifierProvider);
  final currentLocation = ref.watch(locationNotifierProvider);

  if (carAnchor == null || currentLocation == null) {
    return null;
  }

  return currentLocation.distanceTo(carAnchor.location);
}

@Riverpod(keepAlive: true)
double? bearingToCar(Ref ref) {
  final carAnchor = ref.watch(carAnchorNotifierProvider);
  final currentLocation = ref.watch(locationNotifierProvider);

  if (carAnchor == null || currentLocation == null) {
    return null;
  }

  return currentLocation.bearingTo(carAnchor.location);
}

@Riverpod(keepAlive: true)
String? formattedDistanceToCar(Ref ref) {
  final distance = ref.watch(distanceToCarProvider);
  if (distance == null) return null;

  return LocationService.instance.formatDistance(distance);
}

@Riverpod(keepAlive: true)
String? formattedBearingToCar(Ref ref) {
  final bearing = ref.watch(bearingToCarProvider);
  if (bearing == null) return null;

  return LocationService.instance.formatBearing(bearing);
}
