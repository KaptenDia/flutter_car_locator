import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/providers/car_anchor_provider.dart';
import 'package:flutter_car_locator/core/providers/grocery_provider.dart';
import 'package:flutter_car_locator/core/providers/location_provider.dart';
import 'package:flutter_car_locator/features/ar_locator/views/ar_car_locator_view.dart';
import 'package:flutter_car_locator/features/grocery/views/grocery_list_view.dart';
import 'package:flutter_car_locator/features/map/views/map_view.dart';
import 'package:flutter_car_locator/features/qr_scanner/views/qr_scanner_view.dart';
import 'package:flutter_car_locator/features/retail_discovery/views/retail_discovery_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_car_locator/features/profile/views/profile_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward();

    // Initialize location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const MapView(),
    const RetailDiscoveryView(),
    const GroceryListView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedItemColor: const Color(AppColors.primaryColor),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Grocery',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),

      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton(
              onPressed: () => _showQuickActionsBottomSheet(context),
              backgroundColor: const Color(AppColors.primaryColor),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.directions_car,
                  label: 'Mark Car',
                  onTap: () => _markCarLocation(context),
                ),

                _buildQuickActionButton(
                  context,
                  icon: Icons.view_in_ar,
                  label: 'AR View',
                  onTap: () => _openArView(context),
                ),

                _buildQuickActionButton(
                  context,
                  icon: Icons.qr_code_scanner,
                  label: 'Scan QR',
                  onTap: () => _openQrScanner(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  context,
                  icon: Icons.navigation,
                  label: 'Find Car',
                  onTap: () => _findCar(context),
                ),

                _buildQuickActionButton(
                  context,
                  icon: Icons.send,
                  label: 'Send to Valet',
                  onTap: () => _sendGroceryToValet(context),
                ),

                _buildQuickActionButton(
                  context,
                  icon: Icons.explore,
                  label: 'Discover',
                  onTap: () => _switchToDiscoverTab(context),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(AppColors.primaryColor).withAlpha(26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(AppColors.primaryColor),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _markCarLocation(BuildContext context) async {
    Navigator.pop(context);

    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    final location = ref.read(locationNotifierProvider);

    if (location != null) {
      await ref
          .read(carAnchorNotifierProvider.notifier)
          .setCarLocation(location);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.carLocationSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _openArView(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ArCarLocatorView()),
    );
  }

  void _openQrScanner(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerView()),
    );
  }

  void _findCar(BuildContext context) {
    Navigator.pop(context);

    final carAnchor = ref.read(carAnchorNotifierProvider);
    if (carAnchor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.noCarLocationFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Switch to map tab and show car location
    setState(() {
      _selectedIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _sendGroceryToValet(BuildContext context) {
    Navigator.pop(context);

    final groceryList = ref.read(groceryListNotifierProvider);
    if (groceryList == null || groceryList.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your grocery list is empty'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (groceryList.isSentToValet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grocery list already sent to valet'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

    // Send to valet
    ref.read(groceryListNotifierProvider.notifier).sendToValet();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.groceryListSentToValet),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _switchToDiscoverTab(BuildContext context) {
    Navigator.pop(context);

    setState(() {
      _selectedIndex = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
