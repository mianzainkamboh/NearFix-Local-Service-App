import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class CategoryService {
  final DatabaseReference _ref = DatabaseService.categories;

  /// Add a new category
  Future<Map<String, dynamic>> addCategory({
    required String name,
    required String icon,
    String description = '',
  }) async {
    try {
      final id = DatabaseService.generateId(_ref);
      await _ref.child(id).set({
        'id': id,
        'name': name,
        'icon': icon,
        'description': description,
        'isActive': true,
        'providerCount': 0,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Category added successfully!', 'id': id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to add category: $e'};
    }
  }

  /// Update an existing category
  Future<Map<String, dynamic>> updateCategory({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _ref.child(id).update({
        ...data,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Category updated successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update category: $e'};
    }
  }

  /// Delete (deactivate) a category
  Future<Map<String, dynamic>> deleteCategory(String id) async {
    try {
      await _ref.child(id).update({
        'isActive': false,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Category deleted successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete category: $e'};
    }
  }

  /// Get all active categories (real-time stream)
  Stream<List<Map<String, dynamic>>> getCategoriesStream() {
    return _ref.orderByChild('isActive').equalTo(true).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value as Map);
        val['id'] = e.key;
        return val;
      }).toList();
    });
  }

  /// Get all categories (for admin, including inactive)
  Stream<List<Map<String, dynamic>>> getAllCategoriesStream() {
    return _ref.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value as Map);
        val['id'] = e.key;
        return val;
      }).toList();
    });
  }

  /// Get a single category by ID
  Future<Map<String, dynamic>?> getCategory(String id) async {
    try {
      final snapshot = await _ref.child(id).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update provider count for a category
  Future<void> updateProviderCount(String categoryId, int delta) async {
    final snapshot = await _ref.child(categoryId).child('providerCount').get();
    final current = (snapshot.value as int?) ?? 0;
    await _ref.child(categoryId).update({
      'providerCount': current + delta,
    });
  }
}
