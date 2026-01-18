import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';
import 'package:flutter_car_locator/core/models/location_model.dart';
import 'package:flutter_car_locator/shared/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampaignInfo extends ConsumerStatefulWidget {
  const CampaignInfo({
    super.key,
    required this.currentLocation,
    required this.campaign,
  });
  final LocationModel? currentLocation;
  final CampaignPinModel campaign;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CampaignInfoState();
}

class _CampaignInfoState extends ConsumerState<CampaignInfo> {
  get currentLocation => null;

  @override
  Widget build(BuildContext context) {
    final distance = currentLocation != null
        ? widget.campaign.distanceFromUser(currentLocation)
        : null;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.campaign.title,
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

              if (widget.campaign.requiredLoyaltyLevel != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getLoyaltyLevelColor(
                      widget.campaign.requiredLoyaltyLevel!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        widget.campaign.requiredLoyaltyLevel!.name
                            .toUpperCase(),
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

          if (widget.campaign.expiresAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.campaign.isExpired
                    ? const Color(AppColors.errorColor).withAlpha(26)
                    : const Color(AppColors.warningColor).withAlpha(26),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.campaign.isExpired
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
                    color: widget.campaign.isExpired
                        ? const Color(AppColors.errorColor)
                        : const Color(AppColors.warningColor),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.campaign.isExpired
                        ? 'Expired'
                        : 'Expires ${formatExpiryDate(widget.campaign.expiresAt!)}',
                    style: TextStyle(
                      color: widget.campaign.isExpired
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
}
