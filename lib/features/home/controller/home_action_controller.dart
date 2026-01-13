import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/providers/car_anchor_provider.dart';
import 'package:flutter_car_locator/core/providers/grocery_provider.dart';
import 'package:flutter_car_locator/core/providers/location_provider.dart';
import 'package:flutter_car_locator/features/ar_locator/ar_car_locator_view.dart';
import 'package:flutter_car_locator/features/qr_scanner/qr_scanner_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeActionController {
  HomeActionController({required this.ref, required this.context});
  final WidgetRef ref;
  final BuildContext context;

  Future<void> markCarLocation(BuildContext context) async {
    Navigator.pop(context);

    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    final location = ref.read(locationNotifierProvider);

    if (location != null) {
      await ref
          .read(carAnchorNotifierProvider.notifier)
          .setCarLocation(location);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.carLocationSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void openArView(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ArCarLocatorView()),
    );
  }

  void openQrScanner(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerView()),
    );
  }

  void sendGroceryToValet(BuildContext context) {
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
}
