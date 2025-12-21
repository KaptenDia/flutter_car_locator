import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/services.dart';
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
  @override
  List<CampaignPinModel> build() {
    return _mockCampaigns;
  }

  Future<void> loadCampaigns() async {
    state = _mockCampaigns;
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

  if (location == null) return [];

  return campaigns.where((campaign) {
    final distance = _calculateDistance(
      location.latitude,
      location.longitude,
      campaign.location.latitude,
      campaign.location.longitude,
    );
    return distance <= 5.0;
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

bool _canAccessLoyaltyLevel(
  LoyaltyLevel userLevel,
  LoyaltyLevel requiredLevel,
) {
  return userLevel.index >= requiredLevel.index;
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
