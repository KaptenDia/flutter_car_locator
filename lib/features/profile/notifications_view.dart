import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                ),
              );
            },
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            [
                  _buildSectionHeader('Today'),
                  _buildNotificationItem(
                    icon: Icons.stars,
                    color: Colors.amber,
                    title: 'Level Up!',
                    message: 'You reached Silver tier! Enjoy exclusive offers.',
                    time: '2 hours ago',
                    isRead: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.local_offer,
                    color: const Color(AppColors.primaryColor),
                    title: 'New Offer Nearby',
                    message: '50% off at Star Coffee just around the corner.',
                    time: '4 hours ago',
                    isRead: false,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Earlier'),
                  _buildNotificationItem(
                    icon: Icons.directions_car,
                    color: Colors.blue,
                    title: 'Car Located',
                    message: 'Your car location was saved successfully.',
                    time: 'Yesterday',
                    isRead: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.store,
                    color: Colors.purple,
                    title: 'Grand Opening',
                    message: 'Visit the new Electronics Hub in West Mall.',
                    time: '2 days ago',
                    isRead: true,
                  ),
                ]
                .animate(interval: 100.ms)
                .fadeIn(duration: 500.ms)
                .slideX(begin: 0.2, end: 0),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isRead
            ? Border.all(color: Colors.transparent)
            : Border.all(
                color: const Color(AppColors.primaryColor).withAlpha(51),
              ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isRead ? Colors.black87 : Colors.black,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(AppColors.primaryColor),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
