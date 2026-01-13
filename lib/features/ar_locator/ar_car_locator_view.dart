import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_car_locator/features/ar_locator/widgets/ar_overlay_painter_widget.dart';
import 'package:flutter_car_locator/shared/utils/utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import '../../../core/providers/providers.dart';
import '../../../core/constants/constants.dart';

class ArCarLocatorView extends ConsumerStatefulWidget {
  const ArCarLocatorView({super.key});

  @override
  ConsumerState<ArCarLocatorView> createState() => _ArCarLocatorViewState();
}

class _ArCarLocatorViewState extends ConsumerState<ArCarLocatorView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isDisposing = false;
  late AnimationController _pulseAnimationController;
  late AnimationController _rotationAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  double? _heading;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializeCompass();
    // Delay camera initialization to avoid race conditions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCamera();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  void _initializeCompass() {
    _compassSubscription = FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted && !_isDisposing) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
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
    if (_isDisposing) return;

    try {
      final cameraPermission = await Permission.camera.request();

      if (!mounted || _isDisposing) return;

      if (cameraPermission.isGranted) {
        final cameras = await availableCameras();

        if (!mounted || _isDisposing) return;

        if (cameras.isNotEmpty) {
          // Dispose existing controller if any
          await _disposeCamera();

          _cameraController = CameraController(
            cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg,
          );

          try {
            await _cameraController!.initialize();

            if (!mounted || _isDisposing) {
              await _disposeCamera();
              return;
            }

            setState(() {
              _isCameraInitialized = true;
            });
          } catch (e) {
            if (kDebugMode) {
              print('Error initializing camera controller: $e');
            }
            await _disposeCamera();
          }
        }
      } else {
        if (kDebugMode) {
          print('Camera permission not granted');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing camera: $e');
      }
      await _disposeCamera();
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      try {
        if (_cameraController!.value.isInitialized) {
          await _cameraController!.dispose();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error disposing camera: $e');
        }
      } finally {
        _cameraController = null;
        if (mounted && !_isDisposing) {
          setState(() {
            _isCameraInitialized = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    _pulseAnimationController.dispose();
    _rotationAnimationController.dispose();
    _compassSubscription?.cancel();
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
      distance = calculateDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        carAnchor.location.latitude,
        carAnchor.location.longitude,
      );
      bearing = calculateBearing(
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
            _buildArOverlay(distance, bearing, _heading ?? 0),

          // Car not found message
          if (carAnchor == null) _buildNoCarMessage(),

          // Info panel
          _buildInfoPanel(carAnchor, distance, bearing),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_isCameraInitialized &&
        _cameraController != null &&
        _cameraController!.value.isInitialized) {
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

  Widget _buildArOverlay(double distance, double bearing, double heading) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: ArOverlayPainterWidget(
            distance: distance,
            bearing: bearing,
            heading: heading,
            distanceText: formatDistance(distance),
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
                      'Distance: ${formatDistance(distance)}',
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
                      'Direction: ${formatBearing(bearing)}',
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
}
