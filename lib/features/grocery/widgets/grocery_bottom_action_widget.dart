import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/models.dart';
import 'package:flutter_car_locator/features/grocery/controller/grocery_action_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroceryBottomActionWidget extends ConsumerWidget {
  const GroceryBottomActionWidget({super.key, required this.groceryList});

  final GroceryListModel groceryList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!groceryList.isSentToValet) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: groceryList.items.isEmpty
                    ? null
                    : () => GroceryActionController(ref, context).sendToValet(),
                icon: const Icon(Icons.send),
                label: const Text('Send to Valet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryColor),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[500],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => GroceryActionController(
                      ref,
                      context,
                    ).showAddItemDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.primaryColor),
                      side: const BorderSide(
                        color: Color(AppColors.primaryColor),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        GroceryActionController(ref, context).clearCompleted(),
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Done'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(AppColors.warningColor),
                      side: const BorderSide(
                        color: Color(AppColors.warningColor),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(AppColors.successColor).withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(AppColors.successColor),
                  width: 2,
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(AppColors.successColor),
                    size: 32,
                  ),
                  SizedBox(height: 8),
                  Text(
                    AppStrings.groceryListSentToValet,
                    style: TextStyle(
                      color: Color(AppColors.successColor),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
