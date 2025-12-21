import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import '../../../core/providers/providers.dart';
import '../../../core/constants/constants.dart';

class ArCarLocatorView extends ConsumerStatefulWidget {
  const ArCarLocatorView({super.key});

  @override
  ConsumerState<ArCarLocatorView> createState() => _ArCarLocatorViewState();
}

class _ArCarLocatorViewState extends ConsumerState<ArCarLocatorView>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  late AnimationController _pulseAnimationController;
  late AnimationController _rotationAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationAnimationController,
        curve: Curves.linear,
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission.isGranted) {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseAnimationController.dispose();
    _rotationAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carAnchor = ref.watch(carAnchorNotifierProvider);
    final currentLocation = ref.watch(locationNotifierProvider);

    // Check if no car is marked
    if (carAnchor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.arCarLocatorTitle),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text(AppStrings.noCarMarked)),
      );
    }

    // Check if location is available
    if (currentLocation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.arCarLocatorTitle),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _buildArView(context, carAnchor, currentLocation);
  }

  Widget _buildArView(
    BuildContext context,
    dynamic carAnchor,
    dynamic currentLocation,
  ) {
    // Calculate distance and bearing if both locations exist
    double? distance;
    double? bearing;
    if (carAnchor != null && currentLocation != null) {
      distance = _calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        carAnchor.location.latitude,
        carAnchor.location.longitude,
      );
      bearing = _calculateBearing(
        currentLocation.latitude,
        currentLocation.longitude,
        carAnchor.location.latitude,
        carAnchor.location.longitude,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.arCarLocatorTitle),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to Map',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview or placeholder
          _buildCameraView(),

          // AR Overlay
          if (carAnchor != null && distance != null && bearing != null)
            _buildArOverlay(distance, bearing),

          // Car not found message
          if (carAnchor == null) _buildNoCarMessage(),

          // Info panel
          _buildInfoPanel(carAnchor, distance, bearing),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_isCameraInitialized && _cameraController != null) {
      return SizedBox.expand(child: CameraPreview(_cameraController!));
    } else {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, size: 64, color: Colors.white54),
              SizedBox(height: 16),
              Text(
                'Camera Initializing...',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildArOverlay(double distance, double bearing) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ArOverlayPainter(
            distance: distance,
            bearing: bearing,
            pulseAnimation: _pulseAnimation.value,
            rotationAnimation: _rotationAnimation.value,
          ),
        );
      },
    );
  }

  Widget _buildNoCarMessage() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noCarMarked,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Go to map view and mark your car location first',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.map),
              label: const Text('Go to Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryColor),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel(dynamic carAnchor, double? distance, double? bearing) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(204),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (carAnchor != null) ...[
              Text(
                carAnchor.name ?? 'My Car',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (distance != null) ...[
                Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Distance: ${_formatDistance(distance)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (bearing != null) ...[
                Row(
                  children: [
                    const Icon(Icons.navigation, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Direction: ${_formatBearing(bearing)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final double dLon = _degToRad(lon2 - lon1);
    final double lat1Rad = _degToRad(lat1);
    final double lat2Rad = _degToRad(lat2);

    final double y = math.sin(dLon) * math.cos(lat2Rad);
    final double x =
        math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final double bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) %
        360; // Convert to degrees and normalize
  }

  double _degToRad(double deg) {
    return deg * (math.pi / 180);
  }

  String _formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  String _formatBearing(double bearing) {
    const List<String> directions = [
      'N',
      'NE',
      'E',
      'SE',
      'S',
      'SW',
      'W',
      'NW',
    ];
    final int index = ((bearing + 22.5) / 45).floor() % 8;
    return '${directions[index]} (${bearing.round()}°)';
  }
}

class ArOverlayPainter extends CustomPainter {
  final double distance;
  final double bearing;
  final double pulseAnimation;
  final double rotationAnimation;

  ArOverlayPainter({
    required this.distance,
    required this.bearing,
    required this.pulseAnimation,
    required this.rotationAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw compass background
    final compassPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 80, compassPaint);

    // Draw bearing indicator
    final bearingRadians = bearing * math.pi / 180;
    final arrowEnd = Offset(
      center.dx + 60 * math.sin(bearingRadians),
      center.dy - 60 * math.cos(bearingRadians),
    );

    final arrowPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, arrowEnd, arrowPaint);

    // Draw car icon at the end of arrow
    final carIconPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(arrowEnd, 8 * pulseAnimation, carIconPaint);

    // Draw distance text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(distance / 1000).toStringAsFixed(1)}km',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + 100),
    );
  }

  @override
  bool shouldRepaint(ArOverlayPainter oldDelegate) {
    return oldDelegate.distance != distance ||
        oldDelegate.bearing != bearing ||
        oldDelegate.pulseAnimation != pulseAnimation ||
        oldDelegate.rotationAnimation != rotationAnimation;
  }
}
