import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';
import 'package:flutter_car_locator/core/models/car_anchor_model.dart';
import 'package:flutter_car_locator/core/models/location_model.dart';
import 'package:flutter_car_locator/core/models/user_model.dart';
import 'package:flutter_car_locator/core/providers/campaign_provider.dart';
import 'package:flutter_car_locator/core/providers/car_anchor_provider.dart';
import 'package:flutter_car_locator/core/providers/location_provider.dart';
import 'package:flutter_car_locator/core/providers/user_provider.dart';
import 'package:flutter_car_locator/features/ar_locator/ar_car_locator_view.dart';
import 'package:flutter_car_locator/features/retail_discovery/campaign_detail_view.dart';
import 'package:flutter_car_locator/shared/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  GoogleMapController? _mapController;
  bool isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(locationNotifierProvider);
    final carAnchor = ref.watch(carAnchorNotifierProvider);
    final nearbyCampaigns = ref.watch(nearbyCampaignsProvider);
    final user = ref.watch(userNotifierProvider);

    if (currentLocation == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Fetching your location...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(locationNotifierProvider.notifier)
                    .getCurrentLocation(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildMapScaffold(currentLocation, carAnchor, nearbyCampaigns, user);
  }

  Widget _buildMapScaffold(
    dynamic currentLocation,
    dynamic carAnchor,
    List<CampaignPinModel> nearbyCampaigns,
    dynamic user,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Locator Map'),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.view_in_ar),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ArCarLocatorView(),
                ),
              );
            },
            tooltip: 'Switch to AR Mode',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => _moveToCurrentLocation(),
            tooltip: 'My Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentLocation.latitude,
                currentLocation.longitude,
              ),
              zoom: AppConstants.defaultZoom,
            ),
            markers: _buildMarkers(currentLocation, carAnchor, nearbyCampaigns),
            circles: _buildCircles(currentLocation, carAnchor),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top info panel
          _buildTopInfoPanel(carAnchor, user),

          // Bottom controls
          _buildBottomControls(),

          // Nearby campaigns list
          _buildNearbyCampaignsList(nearbyCampaigns),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(
    LocationModel? currentLocation,
    CarAnchorModel? carAnchor,
    List<CampaignPinModel> nearbyCampaigns,
  ) {
    final markers = <Marker>{};

    // Car marker
    if (carAnchor != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('car'),
          position: LatLng(
            carAnchor.location.latitude,
            carAnchor.location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: carAnchor.name ?? 'My Car',
            snippet: carAnchor.description ?? 'Car location',
          ),
        ),
      );
    }

    // Campaign markers
    for (final campaign in nearbyCampaigns) {
      markers.add(
        Marker(
          markerId: MarkerId(campaign.id),
          position: LatLng(
            campaign.location.latitude,
            campaign.location.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            getCampaignMarkerColor(campaign.type),
          ),
          infoWindow: InfoWindow(
            title: campaign.title,
            snippet: campaign.description,
            onTap: () => _showCampaignDetail(campaign),
          ),
          onTap: () => _showCampaignDetail(campaign),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles(
    LocationModel? currentLocation,
    CarAnchorModel? carAnchor,
  ) {
    final circles = <Circle>{};

    // Car search radius circle
    if (carAnchor != null) {
      circles.add(
        Circle(
          circleId: const CircleId('car_radius'),
          center: LatLng(
            carAnchor.location.latitude,
            carAnchor.location.longitude,
          ),
          radius: 50, // 50 meters
          fillColor: Colors.blue.withAlpha(26),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }

    // Campaign visibility radius
    if (currentLocation != null) {
      circles.add(
        Circle(
          circleId: const CircleId('campaign_radius'),
          center: LatLng(currentLocation.latitude, currentLocation.longitude),
          radius: AppConstants.campaignVisibilityRadius,
          fillColor: Colors.green.withAlpha(13),
          strokeColor: Colors.green,
          strokeWidth: 1,
        ),
      );
    }

    return circles;
  }

  Widget _buildTopInfoPanel(CarAnchorModel? carAnchor, UserModel? user) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
            Row(
              children: [
                Icon(
                  carAnchor != null ? Icons.directions_car : Icons.car_repair,
                  color: carAnchor != null
                      ? const Color(AppColors.successColor)
                      : const Color(AppColors.greyColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    carAnchor != null ? 'Car Located' : 'No Car Location',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (user != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getLoyaltyLevelColor(user.loyaltyLevel),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.loyaltyLevel.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (carAnchor != null) ...[
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, child) {
                  final distance = ref.watch(formattedDistanceToCarProvider);
                  final bearing = ref.watch(formattedBearingToCarProvider);

                  return Text(
                    '${distance ?? 'Unknown'} • ${bearing ?? 'Unknown'}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: 'mark_location',
            onPressed: () => _markCurrentLocation(),
            backgroundColor: const Color(AppColors.primaryColor),
            child: const Icon(Icons.add_location, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'clear_location',
            onPressed: () => _clearCarLocation(),
            backgroundColor: const Color(AppColors.errorColor),
            child: const Icon(Icons.clear, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyCampaignsList(List<CampaignPinModel> campaigns) {
    if (campaigns.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 100,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return _buildCampaignCard(campaign);
          },
        ),
      ),
    );
  }

  Widget _buildCampaignCard(CampaignPinModel campaign) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () => _showCampaignDetail(campaign),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Color(getCampaignTypeColor(campaign.type)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  campaign.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Consumer(
                  builder: (context, ref, child) {
                    final currentLocation = ref.watch(locationNotifierProvider);
                    if (currentLocation == null) return const SizedBox.shrink();

                    final distance = campaign.distanceFromUser(currentLocation);
                    return Text(
                      '${(distance / 1000).toStringAsFixed(1)} km',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    setState(() {
      isMapReady = true;
    });

    // Auto-navigate to user location if available
    final locationNotifier = ref.read(locationNotifierProvider.notifier);
    await locationNotifier.getCurrentLocation();
  }

  Future<void> _animateToLocation(LocationModel location) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(location.latitude, location.longitude),
            zoom: 16.0,
          ),
        ),
      );
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_mapController == null) return;

    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    final location = ref.read(locationNotifierProvider);
    if (location != null) {
      await _animateToLocation(location);
    }
  }

  Future<void> _markCurrentLocation() async {
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

  Future<void> _clearCarLocation() async {
    await ref.read(carAnchorNotifierProvider.notifier).clearCarLocation();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.carLocationCleared),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showCampaignDetail(CampaignPinModel campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailView(campaign: campaign),
      ),
    );
  }
}
