import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class ServiceService {
  final DatabaseReference _ref = DatabaseService.services;

  /// Add a new service for a provider
  Future<Map<String, dynamic>> addService({
    required String providerId,
    required String name,
    required String description,
    required double price,
    required String categoryId,
  }) async {
    try {
      final id = DatabaseService.generateId(_ref);
      await _ref.child(id).set({
        'id': id,
        'providerId': providerId,
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'isActive': true,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Service added successfully!', 'id': id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to add service: $e'};
    }
  }

  /// Update a service
  Future<Map<String, dynamic>> updateService({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _ref.child(id).update({
        ...data,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Service updated successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update service: $e'};
    }
  }

  /// Delete (deactivate) a service
  Future<Map<String, dynamic>> deleteService(String id) async {
    try {
      await _ref.child(id).update({
        'isActive': false,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Service deleted successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete service: $e'};
    }
  }

  /// Get services by provider (real-time stream)
  Stream<List<Map<String, dynamic>>> getProviderServicesStream(String providerId) {
    return _ref.orderByChild('providerId').equalTo(providerId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      return data.entries
          .map((e) {
            final val = Map<String, dynamic>.from(e.value as Map);
            val['id'] = e.key;
            return val;
          })
          .where((s) => s['isActive'] == true)
          .toList();
    });
  }

  /// Get a single service by ID
  Future<Map<String, dynamic>?> getService(String id) async {
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

  /// Get all services (for search)
  Future<List<Map<String, dynamic>>> searchServices(String query) async {
    try {
      final snapshot = await _ref.get();
      if (!snapshot.exists) return [];
      final data = snapshot.value as Map<dynamic, dynamic>;
      final queryLower = query.toLowerCase();
      return data.entries
          .map((e) {
            final val = Map<String, dynamic>.from(e.value as Map);
            val['id'] = e.key;
            return val;
          })
          .where((s) =>
              s['isActive'] == true &&
              ((s['name'] ?? '').toString().toLowerCase().contains(queryLower) ||
               (s['description'] ?? '').toString().toLowerCase().contains(queryLower)))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
