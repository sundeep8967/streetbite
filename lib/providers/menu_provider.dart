import 'package:flutter/material.dart';
import 'dart:io';
import '../models/menu_item_model.dart';
import '../services/menu_service.dart';
import '../constants/app_constants.dart';

class MenuProvider with ChangeNotifier {
  final MenuService _menuService = MenuService();
  
  List<MenuItemModel> _menuItems = [];
  List<MenuItemModel> _filteredMenuItems = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';

  // Getters
  List<MenuItemModel> get menuItems => _menuItems;
  List<MenuItemModel> get filteredMenuItems => 
      _filteredMenuItems.isEmpty ? _menuItems : _filteredMenuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  
  List<String> get categories {
    final allCategories = ['All', ...AppConstants.menuCategories];
    return allCategories;
  }

  // Load menu items for a vendor
  Future<void> loadMenuItems(String vendorId) async {
    _setLoading(true);
    _clearError();

    try {
      _menuItems = await _menuService.getVendorMenuItems(vendorId);
      _applyFilter();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Add new menu item
  Future<bool> addMenuItem({
    required String vendorId,
    required String name,
    String? description,
    required double price,
    required String category,
    bool isAvailable = true,
    File? imageFile,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Upload image to Firebase Storage if imageFile is provided
      String? imageUrl;
      if (imageFile != null) {
        // For now, we'll use a placeholder URL
        // In a real app, you would upload to Firebase Storage here
        imageUrl = 'placeholder_image_url';
      }

      final menuItem = MenuItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        vendorId: vendorId,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        isAvailable: isAvailable,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _menuService.addMenuItem(menuItem);
      _menuItems.add(menuItem);
      _applyFilter();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Update menu item
  Future<bool> updateMenuItem(MenuItemModel updatedItem, {File? imageFile}) async {
    _setLoading(true);
    _clearError();

    try {
      // TODO: Upload new image to Firebase Storage if imageFile is provided
      String? newImageUrl = updatedItem.imageUrl;
      if (imageFile != null) {
        // For now, we'll use a placeholder URL
        // In a real app, you would upload to Firebase Storage here
        newImageUrl = 'updated_placeholder_image_url';
      }

      final itemWithUpdatedTime = updatedItem.copyWith(
        imageUrl: newImageUrl,
        updatedAt: DateTime.now(),
      );

      await _menuService.updateMenuItem(itemWithUpdatedTime);
      
      final index = _menuItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _menuItems[index] = itemWithUpdatedTime;
        _applyFilter();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Delete menu item
  Future<bool> deleteMenuItem(String menuItemId) async {
    _setLoading(true);
    _clearError();

    try {
      await _menuService.deleteMenuItem(menuItemId);
      _menuItems.removeWhere((item) => item.id == menuItemId);
      _applyFilter();
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }

  // Toggle menu item availability
  Future<bool> toggleItemAvailability(String menuItemId) async {
    try {
      final itemIndex = _menuItems.indexWhere((item) => item.id == menuItemId);
      if (itemIndex == -1) return false;

      final item = _menuItems[itemIndex];
      final newAvailability = !item.isAvailable;

      await _menuService.toggleMenuItemAvailability(menuItemId, newAvailability);
      
      _menuItems[itemIndex] = item.copyWith(
        isAvailable: newAvailability,
        updatedAt: DateTime.now(),
      );
      
      _applyFilter();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilter();
  }

  // Apply category filter
  void _applyFilter() {
    if (_selectedCategory == 'All') {
      _filteredMenuItems = [];
    } else {
      _filteredMenuItems = _menuItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
    notifyListeners();
  }

  // Get items by category
  List<MenuItemModel> getItemsByCategory(String category) {
    if (category == 'All') return _menuItems;
    return _menuItems.where((item) => item.category == category).toList();
  }

  // Get available items count
  int get availableItemsCount {
    return _menuItems.where((item) => item.isAvailable).length;
  }

  // Get items count by category
  int getItemsCountByCategory(String category) {
    if (category == 'All') return _menuItems.length;
    return _menuItems.where((item) => item.category == category).length;
  }

  // Stream menu items for real-time updates
  Stream<List<MenuItemModel>> streamMenuItems(String vendorId) {
    return _menuService.streamVendorMenuItems(vendorId);
  }

  // Clear menu items
  void clearMenuItems() {
    _menuItems.clear();
    _filteredMenuItems.clear();
    _selectedCategory = 'All';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}