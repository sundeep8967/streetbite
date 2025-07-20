import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/vendor_provider.dart';
import '../../models/menu_item_model.dart';
import 'add_menu_item_screen.dart';
import 'edit_menu_item_screen.dart';
import '../../constants/app_theme.dart';
import '../../widgets/animated/animated_menu_item_card.dart';
import '../../widgets/animated/animated_refresh_indicator.dart';
import '../../widgets/animated/page_transitions.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMenuItems();
    });
  }

  void _loadMenuItems() {
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);
    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    
    if (vendorProvider.currentVendor != null) {
      menuProvider.loadMenuItems(vendorProvider.currentVendor!.id);
    }
  }

  Future<void> _refreshMenuItems() async {
    HapticFeedback.lightImpact();
    _loadMenuItems();
  }

  void _editMenuItem(MenuItemModel item) {
    HapticFeedback.lightImpact();
    NavigationHelper.pushIOS(
      context,
      EditMenuItemScreen(menuItem: item),
    );
  }

  Future<void> _toggleAvailability(MenuItemModel item, MenuProvider menuProvider) async {
    HapticFeedback.mediumImpact();
    final success = await menuProvider.toggleItemAvailability(item.id);
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item.isAvailable 
                ? 'Item marked as unavailable'
                : 'Item marked as available',
          ),
          backgroundColor: item.isAvailable ? AppTheme.iosRed : AppTheme.iosGreen,
        ),
      );
    }
  }

  void _showDeleteConfirmation(MenuItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              final success = await menuProvider.deleteMenuItem(item.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? 'Menu item deleted successfully'
                        : 'Failed to delete menu item'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddMenuItemScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          if (menuProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (menuProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${menuProvider.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadMenuItems,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Total Items',
                      menuProvider.menuItems.length.toString(),
                      Icons.restaurant_menu,
                    ),
                    _buildStatItem(
                      'Available',
                      menuProvider.availableItemsCount.toString(),
                      Icons.check_circle,
                    ),
                    _buildStatItem(
                      'Categories',
                      menuProvider.categories.length.toString(),
                      Icons.category,
                    ),
                  ],
                ),
              ),

              // Category Filter
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = menuProvider.categories[index];
                    final isSelected = menuProvider.selectedCategory == category;
                    final itemCount = menuProvider.getItemsCountByCategory(category);

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('$category ($itemCount)'),
                        selected: isSelected,
                        onSelected: (_) => menuProvider.filterByCategory(category),
                        backgroundColor: Colors.grey[200],
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Menu Items List
              Expanded(
                child: menuProvider.filteredMenuItems.isEmpty
                    ? _buildEmptyState()
                    : AnimatedRefreshIndicator(
                        onRefresh: _refreshMenuItems,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: menuProvider.filteredMenuItems.length,
                          itemBuilder: (context, index) {
                            final item = menuProvider.filteredMenuItems[index];
                            return AnimatedMenuItemCard(
                              menuItem: item,
                              index: index,
                              onEdit: () => _editMenuItem(item),
                              onDelete: () => _showDeleteConfirmation(item),
                              onToggleAvailability: () => _toggleAvailability(item, menuProvider),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddMenuItemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No menu items yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first menu item to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddMenuItemScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Menu Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(MenuItemModel item, MenuProvider menuProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Item Image Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.restaurant, color: Colors.grey);
                            },
                          ),
                        )
                      : const Icon(Icons.restaurant, color: Colors.grey),
                ),
                
                const SizedBox(width: 16),
                
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: item.isAvailable ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.isAvailable ? 'Available' : 'Unavailable',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (item.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final success = await menuProvider.toggleItemAvailability(item.id);
                      if (mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              item.isAvailable 
                                  ? 'Item marked as unavailable'
                                  : 'Item marked as available',
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      item.isAvailable ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(
                      item.isAvailable ? 'Mark Unavailable' : 'Mark Available',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditMenuItemScreen(menuItem: item),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _showDeleteConfirmation(item),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}