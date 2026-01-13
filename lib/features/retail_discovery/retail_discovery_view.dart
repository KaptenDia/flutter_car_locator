import 'package:flutter/material.dart';
import 'package:flutter_car_locator/features/retail_discovery/widgets/retail_discovery_filter_delegate_widget.dart';
import 'package:flutter_car_locator/features/retail_discovery/widgets/retail_discovery_header_delegate_widget.dart';
import 'package:flutter_car_locator/shared/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/notification_service.dart';
import 'campaign_detail_view.dart';

class RetailDiscoveryView extends ConsumerStatefulWidget {
  const RetailDiscoveryView({super.key});

  @override
  ConsumerState<RetailDiscoveryView> createState() =>
      _RetailDiscoveryViewState();
}

class _RetailDiscoveryViewState extends ConsumerState<RetailDiscoveryView>
    with TickerProviderStateMixin {
  CampaignType? _selectedType;
  bool _showExclusiveOnly = false;

  @override
  Widget build(BuildContext context) {
    final nearbyCampaigns = ref.watch(nearbyCampaignsProvider);
    final user = ref.watch(userNotifierProvider);
    final filteredCampaigns = nearbyCampaigns.where((campaign) {
      if (_selectedType != null && campaign.type != _selectedType) return false;
      if (_showExclusiveOnly) {
        return campaign.type == CampaignType.exclusive ||
            (campaign.requiredLoyaltyLevel != null &&
                campaign.requiredLoyaltyLevel != LoyaltyLevel.bronze);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Nearby'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            onPressed: () {
              final firstCampaign = filteredCampaigns.isNotEmpty
                  ? filteredCampaigns.first
                  : null;
              NotificationService.instance.showOfferExpiringNotification(
                campaignTitle: firstCampaign?.title ?? 'Special Offer',
                expiryTime: DateTime.now().add(const Duration(minutes: 5)),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulating expiring offer notification...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Simulate Notification',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(campaignNotifierProvider.notifier).loadCampaigns(),
        child: CustomScrollView(
          slivers: [
            if (user != null)
              SliverPersistentHeader(
                pinned: true,
                delegate: RetailDiscoveryHeaderDelegate(
                  user: user,
                  loyaltyColor: getLoyaltyLevelColor(user.loyaltyLevel),
                ),
              ),
            SliverPersistentHeader(
              pinned: true,
              delegate: RetailDiscoveryFilterDelegate(
                selectedType: _selectedType,
                showExclusiveOnly: _showExclusiveOnly,
                onTypeSelected: (type) => setState(() => _selectedType = type),
                onExclusiveChanged: (val) =>
                    setState(() => _showExclusiveOnly = val),
                getCampaignTypeColor: getCampaignTypeColor,
              ),
            ),
            _buildCampaignsList(filteredCampaigns),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignsList(List<CampaignPinModel> campaigns) {
    if (campaigns.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No campaigns found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or check back later',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final campaign = campaigns[index];
          return _buildCampaignCard(campaign, index);
        }, childCount: campaigns.length),
      ),
    );
  }

  Widget _buildCampaignCard(CampaignPinModel campaign, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child:
          Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () => _showCampaignDetail(campaign),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCardHeader(campaign),
                      _buildCardContent(campaign),
                      _buildCardActions(campaign),
                    ],
                  ),
                ),
              )
              .animate(delay: Duration(milliseconds: (index % 5) * 50))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0)
              .shimmer(duration: 1.seconds, color: Colors.white.withAlpha(100)),
    );
  }

  Widget _buildCardHeader(CampaignPinModel campaign) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(getCampaignTypeColor(campaign.type)),
            Color(getCampaignTypeColor(campaign.type)).withAlpha(204),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              getCampaignTypeIcon(campaign.type),
              size: 48,
              color: Colors.white.withAlpha(204),
            ),
          ),

          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                campaign.type.name.toUpperCase(),
                style: TextStyle(
                  color: Color(getCampaignTypeColor(campaign.type)),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (campaign.requiredLoyaltyLevel != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: getLoyaltyLevelColor(campaign.requiredLoyaltyLevel!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 10, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      campaign.requiredLoyaltyLevel!.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(CampaignPinModel campaign) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            campaign.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final currentLocation = ref.watch(locationNotifierProvider);
                  if (currentLocation == null) return const SizedBox.shrink();

                  final distance = campaign.distanceFromUser(currentLocation);
                  return Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(distance / 1000).toStringAsFixed(1)} km',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(),

              Text(
                '${campaign.rewards.length} reward${campaign.rewards.length != 1 ? 's' : ''}',
                style: TextStyle(
                  color: const Color(AppColors.successColor),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(CampaignPinModel campaign) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCampaignDetail(campaign),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(getCampaignTypeColor(campaign.type)),
                side: BorderSide(
                  color: Color(getCampaignTypeColor(campaign.type)),
                ),
              ),
              child: const Text('View Details'),
            ),
          ),

          const SizedBox(width: 8),

          ElevatedButton(
            onPressed: () => _navigateToCampaign(campaign),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(getCampaignTypeColor(campaign.type)),
              foregroundColor: Colors.white,
            ),
            child: const Text('Navigate'),
          ),
        ],
      ),
    );
  }

  void _showCampaignDetail(CampaignPinModel campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailView(campaign: campaign),
      ),
    );
  }

  void _navigateToCampaign(CampaignPinModel campaign) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening navigation to ${campaign.title}...'),
        backgroundColor: const Color(AppColors.infoColor),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Options',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Campaign Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        setModalState(() => _selectedType = null);
                        setState(() {});
                      },
                    ),
                    ...CampaignType.values.map(
                      (type) => ChoiceChip(
                        label: Text(type.name.toUpperCase()),
                        selected: _selectedType == type,
                        onSelected: (selected) {
                          setModalState(
                            () => _selectedType = selected ? type : null,
                          );
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text('Exclusive Offers Only'),
                  subtitle: const Text(
                    'Show only exclusive loyalty member offers',
                  ),
                  value: _showExclusiveOnly,
                  onChanged: (value) {
                    setModalState(() => _showExclusiveOnly = value);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
