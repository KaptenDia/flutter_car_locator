import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../constants/constants.dart';

part 'user_provider.g.dart';

// Mock user data - in real app, this would come from authentication
final _mockUser = UserModel(
  id: 'user_1',
  name: 'John Doe',
  email: 'john.doe@example.com',
  loyaltyLevel: LoyaltyLevel.silver,
  loyaltyPoints: 1250,
  createdAt: DateTime.now().subtract(const Duration(days: 30)),
);

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  UserModel? build() {
    return _getUser();
  }

  UserModel _getUser() {
    final user = StorageService.instance.getObject<UserModel>(
      AppConstants.userDataKey,
      (json) => UserModel.fromJson(json),
    );
    return user ?? _mockUser;
  }

  Future<void> updateUser(UserModel user) async {
    await StorageService.instance.setObject(
      AppConstants.userDataKey,
      user.toJson(),
    );
    state = user;
  }

  Future<void> updateLoyaltyLevel(LoyaltyLevel level) async {
    if (state != null) {
      final updatedUser = state!.copyWith(
        loyaltyLevel: level,
        updatedAt: DateTime.now(),
      );
      await updateUser(updatedUser);
    }
  }

  Future<void> addLoyaltyPoints(int points) async {
    if (state != null) {
      final updatedUser = state!.copyWith(
        loyaltyPoints: state!.loyaltyPoints + points,
        updatedAt: DateTime.now(),
      );

      // Check if user should be promoted to next loyalty level
      final newLevel = _calculateLoyaltyLevel(updatedUser.loyaltyPoints);
      if (newLevel != updatedUser.loyaltyLevel) {
        await updateUser(updatedUser.copyWith(loyaltyLevel: newLevel));
        await _showLoyaltyLevelUpNotification(newLevel);
      } else {
        await updateUser(updatedUser);
      }
    }
  }

  Future<void> claimReward(String rewardId) async {
    if (state != null && !state!.hasClaimedReward(rewardId)) {
      final updatedUser = state!.copyWith(
        claimedRewards: [...state!.claimedRewards, rewardId],
        updatedAt: DateTime.now(),
      );
      await updateUser(updatedUser);
    }
  }

  LoyaltyLevel _calculateLoyaltyLevel(int points) {
    if (points >= 5000) return LoyaltyLevel.platinum;
    if (points >= 2500) return LoyaltyLevel.gold;
    if (points >= 1000) return LoyaltyLevel.silver;
    return LoyaltyLevel.bronze;
  }

  Future<void> _showLoyaltyLevelUpNotification(LoyaltyLevel newLevel) async {
    await NotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Loyalty Level Up! 🌟',
      body:
          'Congratulations! You\'ve been promoted to ${newLevel.name.toUpperCase()} level!',
      payload: 'loyalty_level_up_${newLevel.name}',
    );
  }
}

@riverpod
bool canAccessExclusiveOffers(Ref ref) {
  final user = ref.watch(userNotifierProvider);
  if (user == null) return false;

  // Silver level and above can access exclusive offers
  final loyaltyLevels = LoyaltyLevel.values;
  final userLevelIndex = loyaltyLevels.indexOf(user.loyaltyLevel);
  final silverLevelIndex = loyaltyLevels.indexOf(LoyaltyLevel.silver);

  return userLevelIndex >= silverLevelIndex;
}

@riverpod
String loyaltyLevelDisplayName(Ref ref) {
  final user = ref.watch(userNotifierProvider);
  if (user == null) return 'Guest';

  return user.loyaltyLevel.name.toUpperCase();
}

@riverpod
int pointsToNextLevel(Ref ref) {
  final user = ref.watch(userNotifierProvider);
  if (user == null) return 0;

  final currentPoints = user.loyaltyPoints;

  switch (user.loyaltyLevel) {
    case LoyaltyLevel.bronze:
      return 1000 - currentPoints;
    case LoyaltyLevel.silver:
      return 2500 - currentPoints;
    case LoyaltyLevel.gold:
      return 5000 - currentPoints;
    case LoyaltyLevel.platinum:
      return 0; // Already at max level
  }
}
