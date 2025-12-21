import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search for help...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _buildFaqItem(
            question: 'How do I save my car location?',
            answer:
                'To save your car location, tap the "Mark Car" button on the home screen or the "+" button on the map view. Your location will be pinned instantly.',
          ),
          _buildFaqItem(
            question: 'How do I claim rewards?',
            answer:
                'Visit participating retailers marked on the map. When you are within range, check in to earn points and unlock exclusive rewards.',
          ),
          _buildFaqItem(
            question: 'What is AR Car Locator?',
            answer:
                'The AR Car Locator uses your camera to show you exactly where your car is parked in the real world. Just follow the AR markers on your screen.',
          ),
          _buildFaqItem(
            question: 'Can I use this offline?',
            answer:
                'Some features like viewing your last saved car location work offline, but you need an internet connection for map updates and finding new offers.',
          ),

          const SizedBox(height: 24),

          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildContactCard(
                  icon: Icons.chat_bubble,
                  title: 'Live Chat',
                  color: const Color(AppColors.primaryColor),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContactCard(
                  icon: Icons.email,
                  title: 'Email Us',
                  color: Colors.orange,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
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
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          children: [
            Text(
              answer,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
