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

final _mockCampaigns = [
  CampaignPinModel(
    id: '1',
    title: 'Starbucks Coffee',
    description: '20% off your next coffee order',
    location: LocationModel(
      latitude: -6.2088,
      longitude: 106.8456,
      timestamp: DateTime.now(),
    ),
    type: CampaignType.food,
    rewards: [
      const RewardModel(
        id: 'reward_1',
        title: '20% Off Coffee',
        description: 'Get 20% discount on any coffee drink',
        discountPercentage: 20.0,
        expiresAt: null,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    expiresAt: DateTime.now().add(const Duration(days: 7)),
    requiredLoyaltyLevel: LoyaltyLevel.bronze,
  ),
  CampaignPinModel(
    id: '2',
    title: 'McDonald\'s Deals',
    description: 'Buy 1 Get 1 Free Big Mac',
    location: LocationModel(
      latitude: -6.2100,
      longitude: 106.8470,
      timestamp: DateTime.now(),
    ),
    type: CampaignType.food,
    rewards: [
      const RewardModel(
        id: 'reward_2',
        title: 'BOGO Big Mac',
        description: 'Buy one Big Mac, get one free',
        discountPercentage: 50.0,
        expiresAt: null,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    expiresAt: DateTime.now().add(const Duration(days: 3)),
    requiredLoyaltyLevel: LoyaltyLevel.bronze,
  ),
  CampaignPinModel(
    id: '3',
    title: 'ZARA Fashion Sale',
    description: 'Up to 50% off on selected items',
    location: LocationModel(
      latitude: -6.2095,
      longitude: 106.8445,
      timestamp: DateTime.now(),
    ),
    type: CampaignType.shopping,
    rewards: [
      const RewardModel(
        id: 'reward_3',
        title: '50% Off Fashion',
        description: 'Up to 50% discount on selected fashion items',
        discountPercentage: 50.0,
        expiresAt: null,
      ),
    ],
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    expiresAt: DateTime.now().add(const Duration(days: 5)),
    requiredLoyaltyLevel: LoyaltyLevel.silver,
  ),
];

@riverpod
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

      // Use actual location or fallback to Jakarta
      final lat = location?.latitude ?? -6.2088;
      final lng = location?.longitude ?? 106.8456;
      if (location != null) {
        _lastFetchLocation = location;
      }

      final places = await PlacesService.instance.fetchNearbyPlaces(lat, lng);

      if (places.isEmpty) {
        if (kDebugMode) {
          print('Places API returned empty list for $lat, $lng');
        }

        state = _mockCampaigns;
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

      state = campaigns.isNotEmpty ? campaigns : _mockCampaigns;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading campaigns: $e');
      }
      state = _mockCampaigns;
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

@riverpod
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
    return distance <= 500.0;
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
