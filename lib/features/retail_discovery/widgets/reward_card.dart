import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';
import 'package:flutter_car_locator/core/providers/campaign_provider.dart';
import 'package:flutter_car_locator/core/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RewardCard extends ConsumerStatefulWidget {
  const RewardCard({
    super.key,
    required this.reward,
    required this.isClaimed,
    required this.canClaim,
    required this.index,
  });

  final RewardModel reward;
  final bool isClaimed;
  final bool canClaim;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RewardCardState();
}

class _RewardCardState extends ConsumerState<RewardCard> {
  @override
  Widget build(BuildContext context) {
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
                            widget.reward.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.reward.description,
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
                    if (widget.reward.discountPercentage != null) ...[
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
                          '${widget.reward.discountPercentage!.toInt()}% OFF',
                          style: const TextStyle(
                            color: Color(AppColors.successColor),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else if (widget.reward.discountAmount != null) ...[
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
                          'RM ${widget.reward.discountAmount!.toStringAsFixed(2)}',
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
                    onPressed: widget.isClaimed || !widget.canClaim
                        ? null
                        : () => _claimReward(ref, widget.reward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isClaimed
                          ? const Color(AppColors.greyColor)
                          : const Color(AppColors.primaryColor),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      widget.isClaimed
                          ? 'Already Claimed'
                          : !widget.canClaim
                          ? 'Loyalty Level Required'
                          : 'Claim Reward',
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: 600 + (widget.index * 100)))
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
  }

  Future<void> _claimReward(WidgetRef ref, RewardModel reward) async {
    await ref
        .read(claimedRewardsNotifierProvider.notifier)
        .claimReward(reward.id);

    // Add loyalty points
    await ref.read(userNotifierProvider.notifier).addLoyaltyPoints(10);
  }
}
