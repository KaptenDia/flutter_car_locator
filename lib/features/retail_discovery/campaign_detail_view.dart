import 'package:flutter/material.dart';
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
            _buildCampaignInfo(currentLocation),
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

  Widget _buildCampaignInfo(LocationModel? currentLocation) {
    final distance = currentLocation != null
        ? campaign.distanceFromUser(currentLocation)
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              if (distance != null) ...[
                Text(
                  '${(distance / 1000).toStringAsFixed(1)} km away',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ] else ...[
                Text(
                  'Distance unavailable',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],

              const Spacer(),

              if (campaign.requiredLoyaltyLevel != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getLoyaltyLevelColor(campaign.requiredLoyaltyLevel!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        campaign.requiredLoyaltyLevel!.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          if (campaign.expiresAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: campaign.isExpired
                    ? const Color(AppColors.errorColor).withAlpha(26)
                    : const Color(AppColors.warningColor).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: campaign.isExpired
                      ? const Color(AppColors.errorColor)
                      : const Color(AppColors.warningColor),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: campaign.isExpired
                        ? const Color(AppColors.errorColor)
                        : const Color(AppColors.warningColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    campaign.isExpired
                        ? 'Expired'
                        : 'Expires ${formatExpiryDate(campaign.expiresAt!)}',
                    style: TextStyle(
                      color: campaign.isExpired
                          ? const Color(AppColors.errorColor)
                          : const Color(AppColors.warningColor),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0);
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
              child: _buildRewardCard(ref, reward, isClaimed, canClaim, index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRewardCard(
    WidgetRef ref,
    RewardModel reward,
    bool isClaimed,
    bool canClaim,
    int index,
  ) {
    return Card(
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reward.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Reward value
                    if (reward.discountPercentage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            AppColors.successColor,
                          ).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${reward.discountPercentage!.toInt()}% OFF',
                          style: const TextStyle(
                            color: Color(AppColors.successColor),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else if (reward.discountAmount != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            AppColors.successColor,
                          ).withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'RM ${reward.discountAmount!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(AppColors.successColor),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),

                // Claim button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isClaimed || !canClaim
                        ? null
                        : () => _claimReward(ref, reward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isClaimed
                          ? const Color(AppColors.greyColor)
                          : const Color(AppColors.primaryColor),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isClaimed
                          ? 'Already Claimed'
                          : !canClaim
                          ? 'Loyalty Level Required'
                          : 'Claim Reward',
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 600 + (index * 100)))
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
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

  Future<void> _claimReward(WidgetRef ref, RewardModel reward) async {
    await ref
        .read(claimedRewardsNotifierProvider.notifier)
        .claimReward(reward.id);

    // Add loyalty points
    await ref.read(userNotifierProvider.notifier).addLoyaltyPoints(10);
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
