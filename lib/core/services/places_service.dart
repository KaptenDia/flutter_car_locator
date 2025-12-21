import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PlacesService {
  static final PlacesService _instance = PlacesService._();
  static PlacesService get instance => _instance;
  PlacesService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  final List<String> _overpassMirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.nchc.org.tw/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
    'https://z.overpass-api.de/api/interpreter',
  ];

  // Simple in-memory cache: Map<CoordString, ListOfPlaces>
  final Map<String, List<Map<String, dynamic>>> _cache = {};
  DateTime? _lastCacheClear;

  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(
    double lat,
    double lng, {
    double radius = 5000,
  }) async {
    // Clear cache if older than 1 hour
    if (_lastCacheClear == null ||
        DateTime.now().difference(_lastCacheClear!) >
            const Duration(hours: 1)) {
      _cache.clear();
      _lastCacheClear = DateTime.now();
    }

    // Check cache for nearby results (within 100m)
    for (final entry in _cache.entries) {
      final coords = entry.key.split(',');
      final cLat = double.parse(coords[0]);
      final cLng = double.parse(coords[1]);

      final distance = _calculateDistance(lat, lng, cLat, cLng);
      if (distance < 0.1) {
        // 100 meters
        if (kDebugMode) {
          print('Using cached places for $lat, $lng (matched ${entry.key})');
        }
        return entry.value;
      }
    }

    // Query for shops and amenities (cafes, restaurants, fast_food)
    final query =
        '''
      [out:json][timeout:30];
      (
        node["shop"](around:$radius, $lat, $lng);
        node["amenity"="cafe"](around:$radius, $lat, $lng);
        node["amenity"="restaurant"](around:$radius, $lat, $lng);
        node["amenity"="fast_food"](around:$radius, $lat, $lng);
        node["amenity"="cinema"](around:$radius, $lat, $lng);
        node["leisure"="fitness_centre"](around:$radius, $lat, $lng);
      );
      out body;
    ''';

    for (final mirror in _overpassMirrors) {
      try {
        if (kDebugMode) {
          print('Fetching places from mirror: $mirror');
        }
        final response = await _dio.get(
          mirror,
          queryParameters: {'data': query},
        );

        if (response.statusCode == 200 && response.data != null) {
          final elements = (response.data['elements'] as List)
              .cast<Map<String, dynamic>>();
          _cache['$lat,$lng'] = elements;
          return elements;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching from $mirror: $e');
        }
        // Continue to next mirror
        continue;
      }
    }

    if (kDebugMode) {
      print('All Overpass mirrors failed for $lat, $lng');
    }
    return [];
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;
    final double dLat = (lat2 - lat1) * (3.1415926535897932 / 180);
    final double dLon = (lon2 - lon1) * (3.1415926535897932 / 180);
    final double a =
        0.5 -
        math.cos(dLat) / 2 +
        math.cos(lat1 * (3.1415926535897932 / 180)) *
            math.cos(lat2 * (3.1415926535897932 / 180)) *
            (1 - math.cos(dLon)) /
            2;
    return earthRadius * 2 * math.asin(math.sqrt(a));
  }
}
