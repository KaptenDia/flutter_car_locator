import 'package:flutter/material.dart';
import 'package:flutter_car_locator/core/constants/app_constants.dart';
import 'package:flutter_car_locator/core/models/grocery_model.dart';
import 'package:flutter_car_locator/core/providers/grocery_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroceryActionController {
  GroceryActionController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  void toggleItemCompletion(String itemId) {
    ref.read(groceryListNotifierProvider.notifier).toggleItemCompletion(itemId);
  }

  void showAddItemDialog(BuildContext context) {
    showItemDialog(context, 'Add Item');
  }

  void showEditItemDialog(BuildContext context, GroceryItemModel item) {
    showItemDialog(context, 'Edit Item', item);
  }

  void handleItemAction(String action, GroceryItemModel item) {
    switch (action) {
      case 'edit':
        showEditItemDialog(context, item);
        break;
      case 'delete':
        deleteItem(item.id);
        break;
    }
  }

  void deleteItem(String itemId) {
    ref.read(groceryListNotifierProvider.notifier).removeItem(itemId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from list'),
        backgroundColor: Color(AppColors.warningColor),
      ),
    );
  }

  void clearCompleted() {
    ref.read(groceryListNotifierProvider.notifier).clearCompletedItems();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completed items cleared'),
        backgroundColor: Color(AppColors.infoColor),
      ),
    );
  }

  void sendToValet() {
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

  void showItemDialog(
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
                  labelText: 'Price (RM)',
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

  void showNewListDialog(BuildContext context) {
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
                  .read(allGroceryListsNotifierProvider.notifier)
                  .createNewList(nameController.text.trim());

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

  void handleMenuAction(String action) {
    switch (action) {
      case 'switch_list':
        _showSwitchListSheet(context);
        break;
      case 'rename_list':
        _showRenameListDialog(context);
        break;
      case 'clear_completed':
        clearCompleted();
        break;
      case 'duplicate_list':
        final currentList = ref.read(groceryListNotifierProvider);
        if (currentList != null) {
          ref
              .read(allGroceryListsNotifierProvider.notifier)
              .duplicateList(currentList);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('List duplicated successfully'),
              backgroundColor: Color(AppColors.successColor),
            ),
          );
        }
        break;
      case 'new_list':
        showNewListDialog(context);
        break;
    }
  }

  void _showSwitchListSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final allLists = ref.watch(allGroceryListsNotifierProvider);
          final activeList = ref.watch(groceryListNotifierProvider);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: Color(AppColors.primaryColor),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Your Grocery Lists',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allLists.length,
                    itemBuilder: (context, index) {
                      final list = allLists[index];
                      final isActive = activeList?.id == list.id;

                      return ListTile(
                        leading: Icon(
                          isActive ? Icons.check_circle : Icons.circle_outlined,
                          color: isActive
                              ? const Color(AppColors.successColor)
                              : Colors.grey,
                        ),
                        title: Text(
                          list.name,
                          style: TextStyle(
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          '${list.items.length} items • ${list.isSentToValet ? 'Sent to Valet' : 'Draft'}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: allLists.length > 1
                              ? () => _confirmDeleteList(context, list)
                              : null,
                        ),
                        onTap: () {
                          ref
                              .read(allGroceryListsNotifierProvider.notifier)
                              .switchList(list.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showNewListDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create New List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primaryColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteList(BuildContext context, GroceryListModel list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete List'),
        content: Text('Are you sure you want to delete "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(allGroceryListsNotifierProvider.notifier)
                  .removeList(list.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameListDialog(BuildContext context) {
    final currentList = ref.read(groceryListNotifierProvider);
    if (currentList == null) return;

    final nameController = TextEditingController(text: currentList.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(
          controller: nameController,
          autofocus: true,
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
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;

              ref
                  .read(groceryListNotifierProvider.notifier)
                  .renameGroceryList(newName);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('List renamed successfully'),
                  backgroundColor: Color(AppColors.successColor),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppColors.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
