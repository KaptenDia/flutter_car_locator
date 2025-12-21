import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/services.dart';

part 'location_provider.g.dart';

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  LocationModel? build() {
    return null;
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (position != null) {
        state = LocationModel.fromPosition(position);
      }
    } catch (e) {
      // Handle error - could emit to an error provider
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
    }
  }

  void updateLocation(LocationModel location) {
    state = location;
  }

  void clearLocation() {
    state = null;
  }
}

@riverpod
class LocationStreamNotifier extends _$LocationStreamNotifier {
  @override
  Stream<LocationModel?> build() {
    return LocationService.instance.getPositionStream().map(
      (position) => LocationModel.fromPosition(position),
    );
  }
}

@riverpod
Future<bool> hasLocationPermission(Ref ref) async {
  return await LocationService.instance.checkLocationPermission();
}

@riverpod
Future<bool> requestLocationPermission(Ref ref) async {
  return await LocationService.instance.requestLocationPermission();
}
