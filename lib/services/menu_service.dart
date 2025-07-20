import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../constants/app_constants.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add menu item
  Future<void> addMenuItem(MenuItemModel menuItem) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(menuItem.id)
        .set(menuItem.toMap());
  }

  // Get menu items for a vendor
  Future<List<MenuItemModel>> getVendorMenuItems(String vendorId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.menuItemsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .orderBy('category')
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => MenuItemModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching menu items: $e');
    }
  }

  // Update menu item
  Future<void> updateMenuItem(MenuItemModel menuItem) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(menuItem.id)
        .update(menuItem.toMap());
  }

  // Delete menu item
  Future<void> deleteMenuItem(String menuItemId) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(menuItemId)
        .delete();
  }

  // Toggle menu item availability
  Future<void> toggleMenuItemAvailability(String menuItemId, bool isAvailable) async {
    await _firestore
        .collection(AppConstants.menuItemsCollection)
        .doc(menuItemId)
        .update({
      'isAvailable': isAvailable,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // Get menu items by category
  Future<List<MenuItemModel>> getMenuItemsByCategory(String vendorId, String category) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(AppConstants.menuItemsCollection)
          .where('vendorId', isEqualTo: vendorId)
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      return query.docs
          .map((doc) => MenuItemModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching menu items by category: $e');
    }
  }

  // Stream menu items for real-time updates
  Stream<List<MenuItemModel>> streamVendorMenuItems(String vendorId) {
    return _firestore
        .collection(AppConstants.menuItemsCollection)
        .where('vendorId', isEqualTo: vendorId)
        .orderBy('category')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromMap(doc.data()))
            .toList());
  }
}