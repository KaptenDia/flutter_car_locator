import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/campaign_pin_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String formatBearing(double bearing) {
  const List<String> directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final int index = ((bearing + 22.5) / 45).floor() % 8;
  return '${directions[index]} (${bearing.round()}°)';
}

String formatDistance(double distance) {
  if (distance < 1000) {
    return '${distance.round()}m';
  } else {
    return '${(distance / 1000).toStringAsFixed(1)}km';
  }
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
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

int getCampaignTypeColor(CampaignType type) {
  switch (type) {
    case CampaignType.retail:
      return AppColors.retailColor;
    case CampaignType.food:
      return AppColors.foodColor;
    case CampaignType.entertainment:
      return AppColors.entertainmentColor;
    case CampaignType.gas:
      return AppColors.gasColor;
    case CampaignType.shopping:
      return AppColors.shoppingColor;
    case CampaignType.exclusive:
      return AppColors.exclusiveColor;
  }
}

IconData getCampaignTypeIcon(CampaignType type) {
  switch (type) {
    case CampaignType.retail:
      return Icons.store;
    case CampaignType.food:
      return Icons.restaurant;
    case CampaignType.entertainment:
      return Icons.movie;
    case CampaignType.gas:
      return Icons.local_gas_station;
    case CampaignType.shopping:
      return Icons.shopping_bag;
    case CampaignType.exclusive:
      return Icons.diamond;
  }
}

Color getLoyaltyLevelColor(LoyaltyLevel level) {
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

String formatExpiryDate(DateTime expiry) {
  final now = DateTime.now();
  final difference = expiry.difference(now);

  if (difference.inDays > 0) {
    return 'in ${difference.inDays} days';
  } else if (difference.inHours > 0) {
    return 'in ${difference.inHours} hours';
  } else if (difference.inMinutes > 0) {
    return 'in ${difference.inMinutes} minutes';
  } else {
    return 'soon';
  }
}

double calculateNearbyDistance(
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

double getCampaignMarkerColor(CampaignType type) {
  switch (type) {
    case CampaignType.retail:
      return BitmapDescriptor.hueViolet;
    case CampaignType.food:
      return BitmapDescriptor.hueOrange;
    case CampaignType.entertainment:
      return BitmapDescriptor.hueMagenta;
    case CampaignType.gas:
      return BitmapDescriptor.hueAzure;
    case CampaignType.shopping:
      return BitmapDescriptor.hueBlue;
    case CampaignType.exclusive:
      return BitmapDescriptor.hueYellow;
  }
}
