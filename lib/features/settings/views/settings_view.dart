import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _pushNotifications = true;
  bool _locationServices = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            [
                  _buildSectionHeader('PREFERENCES'),
                  _buildSwitchTile(
                    icon: Icons.notifications_active,
                    title: 'Push Notifications',
                    subtitle: 'Receive alerts about offers and car status',
                    value: _pushNotifications,
                    onChanged: (val) =>
                        setState(() => _pushNotifications = val),
                  ),
                  _buildSwitchTile(
                    icon: Icons.location_on,
                    title: 'Location Services',
                    subtitle: 'Allow app to access your location',
                    value: _locationServices,
                    onChanged: (val) => setState(() => _locationServices = val),
                  ),
                  _buildSwitchTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Enable dark theme',
                    value: _darkMode,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('ACCOUNT'),
                  _buildActionTile(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    onTap: () {
                      // Edit profile navigation
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.lock,
                    title: 'Change Password',
                    onTap: () {
                      // Change password navigation
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('ABOUT'),
                  _buildActionTile(
                    icon: Icons.info,
                    title: 'Version',
                    trailing: const Text(
                      '1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Icons.description,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  const SizedBox(height: 40),
                  OutlinedButton(
                    onPressed: () {
                      // Logout logic
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.errorColor),
                      side: const BorderSide(
                        color: Color(AppColors.errorColor),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Log Out'),
                  ),
                ]
                .animate(interval: 50.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(AppColors.primaryColor).withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(AppColors.primaryColor)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(AppColors.primaryColor),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[700]),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing:
            trailing ??
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
