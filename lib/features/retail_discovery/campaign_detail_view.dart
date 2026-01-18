import 'package:flutter/material.dart';
import 'package:flutter_car_locator/features/retail_discovery/widgets/campaign_info.dart';
import 'package:flutter_car_locator/features/retail_discovery/widgets/reward_card.dart';
import 'package:flutter_car_locator/shared/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/constants/constants.dart';

class CampaignDetailView extends ConsumerWidget {
  final CampaignPinModel campaign;

  const CampaignDetailView({super.key, required this.campaign});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final claimedRewards = ref.watch(claimedRewardsNotifierProvider);
    final currentLocation = ref.watch(locationNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(campaign.title),
        backgroundColor: Color(getCampaignTypeColor(campaign.type)),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderImage(),
            CampaignInfo(currentLocation: currentLocation, campaign: campaign),
            _buildDescription(),
            _buildRewardsList(ref, user, claimedRewards),
            _buildActionButtons(context, ref, user),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(getCampaignTypeColor(campaign.type)),
            Color(getCampaignTypeColor(campaign.type)).withAlpha(179),
          ],
        ),
      ),
      child: Stack(
        children: [
          if (campaign.imageUrl != null)
            Image.network(
              campaign.imageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildDefaultImage(),
            )
          else
            _buildDefaultImage(),

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withAlpha(128)],
              ),
            ),
          ),

          // Campaign type badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                campaign.type.name.toUpperCase(),
                style: TextStyle(
                  color: Color(getCampaignTypeColor(campaign.type)),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildDefaultImage() {
    return Center(
      child: Icon(
        getCampaignTypeIcon(campaign.type),
        size: 80,
        color: Colors.white.withAlpha(204),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            campaign.description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildRewardsList(
    WidgetRef ref,
    UserModel? user,
    List<String> claimedRewards,
  ) {
    if (campaign.rewards.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available Rewards',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...campaign.rewards.asMap().entries.map((entry) {
            final index = entry.key;
            final reward = entry.value;
            final isClaimed = claimedRewards.contains(reward.id);
            final canClaim = _canClaimReward(reward, user);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: RewardCard(
                reward: reward,
                isClaimed: isClaimed,
                canClaim: canClaim,
                index: index,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    UserModel? user,
  ) {
    final currentLocation = ref.watch(locationNotifierProvider);
    final isWithinRadius = currentLocation != null
        ? campaign.isWithinRadius(currentLocation)
        : false;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Navigate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToCampaign(context),
              icon: const Icon(Icons.navigation),
              label: const Text('Navigate Here'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Enter store button (only if within radius)
          if (isWithinRadius) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _simulateStoreEntry(context, ref),
                icon: const Icon(Icons.store),
                label: const Text('Enter Store'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(AppColors.primaryColor),
                  side: const BorderSide(color: Color(AppColors.primaryColor)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Get closer to enter store',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
  }

  bool _canClaimReward(RewardModel reward, UserModel? user) {
    if (user == null) return false;
    if (reward.isExpired) return false;

    final loyaltyLevels = LoyaltyLevel.values;
    final userIndex = loyaltyLevels.indexOf(user.loyaltyLevel);

    // Check campaign level requirement first
    if (campaign.requiredLoyaltyLevel != null) {
      final campaignRequiredIndex = loyaltyLevels.indexOf(
        campaign.requiredLoyaltyLevel!,
      );
      if (userIndex < campaignRequiredIndex) return false;
    }

    // Check reward level requirement
    if (reward.requiredLoyaltyLevel != null) {
      final rewardRequiredIndex = loyaltyLevels.indexOf(
        reward.requiredLoyaltyLevel!,
      );
      if (userIndex < rewardRequiredIndex) return false;
    }

    return true;
  }

  void _navigateToCampaign(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening navigation to ${campaign.title}...'),
        backgroundColor: const Color(AppColors.infoColor),
      ),
    );
  }

  void _simulateStoreEntry(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome!'),
        content: Text(
          'Welcome to ${campaign.title}! Enjoy exclusive in-store offers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );

    // Add loyalty points for store visit
    ref.read(userNotifierProvider.notifier).addLoyaltyPoints(5);
  }
}
