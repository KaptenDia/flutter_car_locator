import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_car_locator/shared/utils/amenity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../services/places_service.dart';
import '../constants/constants.dart';
import 'location_provider.dart';

part 'campaign_provider.g.dart';

@Riverpod(keepAlive: true)
class CampaignNotifier extends _$CampaignNotifier {
  LocationModel? _lastFetchLocation;

  @override
  List<CampaignPinModel> build() {
    ref.listen(locationStreamNotifierProvider, (previous, next) {
      next.whenData((location) {
        if (location != null) {
          final shouldReload =
              _lastFetchLocation == null ||
              _calculateDistance(
                    _lastFetchLocation!.latitude,
                    _lastFetchLocation!.longitude,
                    location.latitude,
                    location.longitude,
                  ) >
                  0.5;

          if (shouldReload) {
            loadCampaigns(location);
          }
        }
      });
    });
    Future.microtask(() => loadCampaigns());
    return [];
  }

  Future<void> loadCampaigns([LocationModel? overriddenLocation]) async {
    try {
      final LocationModel? location;
      if (overriddenLocation != null) {
        location = overriddenLocation;
      } else {
        final position = await LocationService.instance.getCurrentPosition();
        location = position != null
            ? LocationModel.fromPosition(position)
            : null;
      }

      if (location == null) {
        state = [];
        return;
      }

      final lat = location.latitude;
      final lng = location.longitude;
      _lastFetchLocation = location;

      final places = await PlacesService.instance.fetchNearbyPlaces(lat, lng);

      if (places.isEmpty) {
        if (kDebugMode) {
          print('Places API returned empty list for $lat, $lng');
        }

        state = [];
        return;
      }

      final campaigns = places
          .where((place) => place['tags']?['name'] != null)
          .map((place) {
            final tags = place['tags'] as Map<String, dynamic>;
            final name = tags['name'] as String;
            final type = _mapOsmTypeToCampaignType(tags);
            final id = place['id'].toString();

            return CampaignPinModel(
              id: id,
              title: name,
              description: _generateDescription(name, type),
              location: LocationModel(
                latitude: place['lat'],
                longitude: place['lon'],
                timestamp: DateTime.now(),
              ),
              type: type,
              rewards: _generateRewards(id, type),
              createdAt: DateTime.now(),
              expiresAt: DateTime.now().add(const Duration(days: 14)),
              requiredLoyaltyLevel: LoyaltyLevel
                  .values[math.Random().nextInt(LoyaltyLevel.values.length)],
            );
          })
          .toList();

      state = campaigns;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading campaigns: $e');
      }
      // If we already have data, don't clear it on error
      if (state.isEmpty) {
        state = [];
      }
    }
  }

  CampaignType _mapOsmTypeToCampaignType(Map<String, dynamic> tags) {
    if (tags.containsKey('amenity')) {
      final amenity = tags['amenity'];
      debugPrint('amenity: $amenity');
      if (amenity == 'cafe' ||
          amenity == 'restaurant' ||
          amenity == 'fast_food') {
        return CampaignType.food;
      }

      if (entertainmentAmenities.contains(amenity)) {
        return CampaignType.entertainment;
      }
    }
    if (tags.containsKey('leisure') && tags['leisure'] == 'fitness_centre') {
      return CampaignType.exclusive;
    }
    if (tags.containsKey('shop')) {
      final shop = tags['shop'];
      if (shop == 'supermarket' || shop == 'convenience') {
        return CampaignType.retail;
      }
      if (shop == 'clothes' || shop == 'mall') return CampaignType.shopping;
    }
    return CampaignType.retail;
  }

  String _generateDescription(String name, CampaignType type) {
    switch (type) {
      case CampaignType.food:
        return 'Special dining offers at $name. limited time only!';
      case CampaignType.retail:
        return 'Shop at $name and earn double points today.';
      case CampaignType.shopping:
        return 'Exclusive fashion deals available at $name.';
      case CampaignType.entertainment:
        return 'Enjoy your free time at $name with our member perks.';
      default:
        return 'Visit $name to unlock special rewards.';
    }
  }

  List<RewardModel> _generateRewards(String campaignId, CampaignType type) {
    final random = math.Random();
    final discount = (random.nextInt(4) + 1) * 10.0; // 10, 20, 30, 40%

    return [
      RewardModel(
        id: 'reward_${campaignId}_1',
        title: '${discount.toInt()}% Off',
        description: 'Get ${discount.toInt()}% discount on your purchase',
        discountPercentage: discount,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      ),
    ];
  }

  void addCampaign(CampaignPinModel campaign) {
    state = [...state, campaign];
  }

  void removeCampaign(String campaignId) {
    state = state.where((campaign) => campaign.id != campaignId).toList();
  }

  void updateCampaign(CampaignPinModel updatedCampaign) {
    state = state.map((campaign) {
      return campaign.id == updatedCampaign.id ? updatedCampaign : campaign;
    }).toList();
  }
}

@Riverpod(keepAlive: true)
List<CampaignPinModel> nearbyCampaigns(Ref ref) {
  final campaigns = ref.watch(campaignNotifierProvider);
  final location = ref.watch(locationNotifierProvider);

  if (location == null) return campaigns;

  return campaigns.where((campaign) {
    final distance = _calculateDistance(
      location.latitude,
      location.longitude,
      campaign.location.latitude,
      campaign.location.longitude,
    );
    return distance <= 10.0; // 10 km radius
  }).toList();
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371;

  final double dLat = (lat2 - lat1) * (math.pi / 180);
  final double dLon = (lon2 - lon1) * (math.pi / 180);

  final double a =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1 * (math.pi / 180)) *
          math.cos(lat2 * (math.pi / 180)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);

  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return earthRadius * c;
}

@riverpod
class SelectedCampaignNotifier extends _$SelectedCampaignNotifier {
  @override
  CampaignPinModel? build() => null;

  void selectCampaign(CampaignPinModel campaign) {
    state = campaign;
  }

  void clearSelection() {
    state = null;
  }
}

@riverpod
class ClaimedRewardsNotifier extends _$ClaimedRewardsNotifier {
  @override
  List<String> build() {
    final claimedRewards = StorageService.instance.getStringList(
      AppConstants.claimedRewardsKey,
    );
    return claimedRewards ?? [];
  }

  Future<void> claimReward(String rewardId) async {
    final currentClaimed = [...state, rewardId];
    await StorageService.instance.setStringList(
      AppConstants.claimedRewardsKey,
      currentClaimed,
    );
    state = currentClaimed;
  }

  Future<void> removeClaimedReward(String rewardId) async {
    final updatedClaimed = state.where((id) => id != rewardId).toList();
    await StorageService.instance.setStringList(
      AppConstants.claimedRewardsKey,
      updatedClaimed,
    );
    state = updatedClaimed;
  }

  bool isRewardClaimed(String rewardId) {
    return state.contains(rewardId);
  }
}
