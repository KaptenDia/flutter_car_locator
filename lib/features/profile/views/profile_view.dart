import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/car_anchor_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/car_anchor_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/campaign_provider.dart';
import '../../settings/views/notifications_view.dart';
import '../../settings/views/settings_view.dart';
import '../../settings/views/help_support_view.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final carAnchor = ref.watch(carAnchorNotifierProvider);
    final claimedRewards = ref.watch(claimedRewardsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildLoyaltySection(user),
              const SizedBox(height: 24),
              _buildStatsSection(user, carAnchor, claimedRewards),
              const SizedBox(height: 24),
              _buildActionsSection(context),
            ] else ...[
              const Center(
                child: Text(
                  'No user data available',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(AppColors.primaryColor),
            Color(AppColors.primaryColorLight),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildLoyaltySection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loyalty Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getLoyaltyLevelColor(user.loyaltyLevel),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      user.loyaltyLevel.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Text(
                '${user.loyaltyPoints} Points',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, child) {
              final pointsToNext = ref.watch(pointsToNextLevelProvider);
              if (pointsToNext <= 0) {
                return const Text(
                  'Congratulations! You\'ve reached the highest level!',
                  style: TextStyle(
                    color: Color(AppColors.successColor),
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pointsToNext points to next level',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getProgressToNextLevel(
                      user.loyaltyLevel,
                      user.loyaltyPoints,
                    ),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getLoyaltyLevelColor(user.loyaltyLevel),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0);
  }

  Widget _buildStatsSection(
    UserModel user,
    CarAnchorModel? carAnchor,
    List<String> claimedRewards,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.directions_car,
                  label: 'Car Status',
                  value: carAnchor != null ? 'Located' : 'Not Set',
                  color: carAnchor != null
                      ? const Color(AppColors.successColor)
                      : const Color(AppColors.greyColor),
                ),
              ),

              Expanded(
                child: _buildStatItem(
                  icon: Icons.card_giftcard,
                  label: 'Rewards',
                  value: claimedRewards.length.toString(),
                  color: const Color(AppColors.warningColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.stars,
                  label: 'Points',
                  value: user.loyaltyPoints.toString(),
                  color: const Color(AppColors.primaryColor),
                ),
              ),

              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today,
                  label: 'Member Since',
                  value: _formatMemberSince(user.createdAt),
                  color: const Color(AppColors.infoColor),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(
              Icons.notifications,
              color: Color(AppColors.primaryColor),
            ),
            title: const Text('Notifications'),
            subtitle: const Text('Manage your notification preferences'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsView(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.settings,
              color: Color(AppColors.primaryColor),
            ),
            title: const Text('Settings'),
            subtitle: const Text('App settings and preferences'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.help,
              color: Color(AppColors.primaryColor),
            ),
            title: const Text('Help & Support'),
            subtitle: const Text('Get help and contact support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportView(),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Color _getLoyaltyLevelColor(LoyaltyLevel level) {
    switch (level) {
      case LoyaltyLevel.bronze:
        return Colors.brown;
      case LoyaltyLevel.silver:
        return Colors.grey;
      case LoyaltyLevel.gold:
        return Colors.amber;
      case LoyaltyLevel.platinum:
        return Colors.purple;
    }
  }

  double _getProgressToNextLevel(LoyaltyLevel level, int points) {
    switch (level) {
      case LoyaltyLevel.bronze:
        return points / 1000;
      case LoyaltyLevel.silver:
        return (points - 1000) / (2500 - 1000);
      case LoyaltyLevel.gold:
        return (points - 2500) / (5000 - 2500);
      case LoyaltyLevel.platinum:
        return 1.0;
    }
  }

  String _formatMemberSince(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '${years}Y ago';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '${months}M ago';
    } else {
      return '${difference.inDays}D ago';
    }
  }
}
