import 'package:flutter/material.dart';
import 'package:flutter_car_locator/features/grocery/controller/grocery_action_controller.dart';
import 'package:flutter_car_locator/features/grocery/widgets/grocery_bottom_action_widget.dart';
import 'package:flutter_car_locator/features/grocery/widgets/grocery_progress_header_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/constants/constants.dart';

class GroceryListView extends ConsumerStatefulWidget {
  const GroceryListView({super.key});

  @override
  ConsumerState<GroceryListView> createState() => _GroceryListViewState();
}

class _GroceryListViewState extends ConsumerState<GroceryListView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groceryList = ref.watch(groceryListNotifierProvider);
    final groupedItems = ref.watch(groupedGroceryItemsProvider);
    final totalPrice = ref.watch(totalGroceryPriceProvider);
    final progress = ref.watch(groceryProgressProvider);

    if (groceryList == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(groceryList.name),
        backgroundColor: const Color(AppColors.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => GroceryActionController(
              ref,
              context,
            ).showAddItemDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: GroceryActionController(ref, context).handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch_list',
                child: Text('Switch List'),
              ),
              const PopupMenuItem(
                value: 'rename_list',
                child: Text('Rename List'),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Text('Clear Completed Items'),
              ),
              const PopupMenuItem(
                value: 'duplicate_list',
                child: Text('Duplicate List'),
              ),
              const PopupMenuItem(
                value: 'new_list',
                child: Text('Create New List'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          GroceryProgressHeaderWidget(
            groceryList: groceryList,
            progress: progress,
            totalPrice: totalPrice,
          ),
          Expanded(child: _buildGroceryList(groupedItems)),
        ],
      ),
      bottomNavigationBar: GroceryBottomActionWidget(groceryList: groceryList),
    );
  }

  Widget _buildGroceryList(Map<String, List<GroceryItemModel>> groupedItems) {
    if (groupedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your grocery list is empty',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some items to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupedItems.keys.length,
      itemBuilder: (context, index) {
        final category = groupedItems.keys.elementAt(index);
        final items = groupedItems[category]!;

        return _buildCategorySection(category, items, index);
      },
    );
  }

  Widget _buildCategorySection(
    String category,
    List<GroceryItemModel> items,
    int categoryIndex,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppColors.primaryColor),
                ),
              ),
            )
            .animate(delay: Duration(milliseconds: categoryIndex * 100))
            .fadeIn()
            .slideX(begin: -0.2, end: 0),

        ...items.asMap().entries.map((entry) {
          final itemIndex = entry.key;
          final item = entry.value;

          return _buildGroceryItem(item, categoryIndex, itemIndex);
        }),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildGroceryItem(
    GroceryItemModel item,
    int categoryIndex,
    int itemIndex,
  ) {
    return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Checkbox(
              value: item.isCompleted,
              onChanged: (value) => GroceryActionController(
                ref,
                context,
              ).toggleItemCompletion(item.id),
              activeColor: const Color(AppColors.successColor),
            ),

            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.isCompleted ? Colors.grey : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description != null) ...[
                  Text(
                    item.description!,
                    style: TextStyle(
                      color: item.isCompleted ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],

                Row(
                  children: [
                    Text(
                      '${item.quantity} ${item.unit}',
                      style: TextStyle(
                        color: item.isCompleted
                            ? Colors.grey
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),

                    if (item.price != null) ...[
                      const Text(' • '),
                      Text(
                        'RM ${item.price!.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: item.isCompleted
                              ? Colors.grey
                              : const Color(AppColors.successColor),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            trailing: PopupMenuButton<String>(
              onSelected: (action) => GroceryActionController(
                ref,
                context,
              ).handleItemAction(action, item),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        )
        .animate(
          delay: Duration(
            milliseconds: (categoryIndex * 100) + (itemIndex * 50),
          ),
        )
        .fadeIn()
        .slideX(begin: 0.2, end: 0);
  }
}
