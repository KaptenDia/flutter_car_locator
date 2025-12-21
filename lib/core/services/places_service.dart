import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PlacesService {
  static final PlacesService _instance = PlacesService._();
  static PlacesService get instance => _instance;
  PlacesService._();

  final Dio _dio = Dio();
  final String _overpassUrl = 'https://overpass-api.de/api/interpreter';

  Future<List<Map<String, dynamic>>> fetchNearbyPlaces(
    double lat,
    double lng, {
    double radius = 5000,
  }) async {
    try {
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

      final response = await _dio.get(
        _overpassUrl,
        queryParameters: {'data': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        final elements = response.data['elements'] as List;
        return elements.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching places: $e');
      }
      return [];
    }
  }
}
