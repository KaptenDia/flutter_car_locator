import 'package:flutter/material.dart';
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
            onPressed: () => _showAddItemDialog(context),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
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
          _buildProgressHeader(groceryList, progress, totalPrice),
          Expanded(child: _buildGroceryList(groupedItems)),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(groceryList),
    );
  }

  Widget _buildProgressHeader(
    GroceryListModel groceryList,
    double progress,
    double totalPrice,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(AppColors.primaryColor),
            Color(AppColors.primaryColorLight),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shopping Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withAlpha(77),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${groceryList.completedItems}/${groceryList.totalItems} items completed',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    'Rp ${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (groceryList.isSentToValet) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(AppColors.successColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Sent to Valet Service',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
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
              onChanged: (value) => _toggleItemCompletion(item.id),
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
                        'Rp ${item.price!.toStringAsFixed(0)}',
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
              onSelected: (action) => _handleItemAction(action, item),
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

  Widget _buildBottomActions(GroceryListModel groceryList) {
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
                onPressed: () => _sendToValet(),
                icon: const Icon(Icons.send),
                label: const Text('Send to Valet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppColors.primaryColor),
                  foregroundColor: Colors.white,
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
                    onPressed: () => _showAddItemDialog(context),
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
                    onPressed: () => _clearCompleted(),
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

  void _toggleItemCompletion(String itemId) {
    ref.read(groceryListNotifierProvider.notifier).toggleItemCompletion(itemId);
  }

  void _handleItemAction(String action, GroceryItemModel item) {
    switch (action) {
      case 'edit':
        _showEditItemDialog(context, item);
        break;
      case 'delete':
        _deleteItem(item.id);
        break;
    }
  }

  void _deleteItem(String itemId) {
    ref.read(groceryListNotifierProvider.notifier).removeItem(itemId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from list'),
        backgroundColor: Color(AppColors.warningColor),
      ),
    );
  }

  void _clearCompleted() {
    ref.read(groceryListNotifierProvider.notifier).clearCompletedItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completed items cleared'),
        backgroundColor: Color(AppColors.infoColor),
      ),
    );
  }

  void _sendToValet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send to Valet'),
        content: const Text(
          'This will send your grocery list to the valet service. '
          'They will shop for you and deliver the items to your car. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(groceryListNotifierProvider.notifier).sendToValet();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.groceryListSentToValet),
                  backgroundColor: Color(AppColors.successColor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'clear_completed':
        _clearCompleted();
        break;
      case 'duplicate_list':
        ref.read(groceryListNotifierProvider.notifier).duplicateCurrentList();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('List duplicated successfully'),
            backgroundColor: Color(AppColors.successColor),
          ),
        );
        break;
      case 'new_list':
        _showNewListDialog(context);
        break;
    }
  }

  void _showAddItemDialog(BuildContext context) {
    _showItemDialog(context, 'Add Item');
  }

  void _showEditItemDialog(BuildContext context, GroceryItemModel item) {
    _showItemDialog(context, 'Edit Item', item);
  }

  void _showItemDialog(
    BuildContext context,
    String title, [
    GroceryItemModel? item,
  ]) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descriptionController = TextEditingController(
      text: item?.description ?? '',
    );
    final quantityController = TextEditingController(
      text: (item?.quantity ?? 1).toString(),
    );
    final unitController = TextEditingController(text: item?.unit ?? 'pcs');
    final priceController = TextEditingController(
      text: item?.price != null ? item!.price!.toString() : '',
    );
    final categoryController = TextEditingController(
      text: item?.category ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (Rp)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              final newItem = GroceryItemModel(
                id:
                    item?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                description: descriptionController.text.trim().isNotEmpty
                    ? descriptionController.text.trim()
                    : null,
                quantity: int.tryParse(quantityController.text) ?? 1,
                unit: unitController.text.trim(),
                price: double.tryParse(priceController.text),
                category: categoryController.text.trim().isNotEmpty
                    ? categoryController.text.trim()
                    : null,
                addedAt: item?.addedAt ?? DateTime.now(),
              );

              if (item != null) {
                ref
                    .read(groceryListNotifierProvider.notifier)
                    .updateItem(newItem);
              } else {
                ref.read(groceryListNotifierProvider.notifier).addItem(newItem);
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: Text(item != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showNewListDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'List Name *',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;

              ref
                  .read(groceryListNotifierProvider.notifier)
                  .createNewGroceryList(nameController.text.trim());

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New list created successfully'),
                  backgroundColor: Color(AppColors.successColor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
