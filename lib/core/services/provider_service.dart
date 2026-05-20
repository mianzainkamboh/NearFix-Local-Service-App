import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class ProviderService {
  final DatabaseReference _ref = DatabaseService.providers;
  final DatabaseReference _usersRef = DatabaseService.users;

  /// Register as a provider (creates application for admin approval)
  Future<Map<String, dynamic>> registerProvider({
    required String uid,
    required String categoryId,
    required String businessName,
    required String description,
    required String experience,
    required String serviceArea,
    String phone = '',
  }) async {
    try {
      // Create provider application (not direct provider)
      await _ref.child(uid).set({
        'uid': uid,
        'categoryId': categoryId,
        'businessName': businessName,
        'description': description,
        'experience': experience,
        'serviceArea': serviceArea,
        'phone': phone,
        'status': 'pending', // pending, approved, rejected
        'rating': 0.0,
        'reviewCount': 0,
        'totalBookings': 0,
        'completedBookings': 0,
        'totalEarnings': 0.0,
        'isActive': false, // Will be set to true when approved
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      // DO NOT update user role yet - wait for admin approval
      // Just mark that they have a pending application
      await _usersRef.child(uid).update({
        'hasProviderApplication': true,
        'providerApplicationStatus': 'pending',
        'updatedAt': ServerValue.timestamp,
      });

      return {'success': true, 'message': 'Application submitted successfully! Please wait for admin approval.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit application: $e'};
    }
  }

  /// Get provider profile
  Future<Map<String, dynamic>?> getProvider(String uid) async {
    try {
      final snapshot = await _ref.child(uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        // Also get user info
        final userSnapshot = await _usersRef.child(uid).get();
        if (userSnapshot.exists) {
          final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
          data['name'] = userData['name'];
          data['email'] = userData['email'];
          data['profileImage'] = userData['profileImage'];
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get provider profile as stream
  Stream<Map<String, dynamic>?> getProviderStream(String uid) {
    return _ref.child(uid).onValue.asyncMap((event) async {
      if (!event.snapshot.exists) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final userSnapshot = await _usersRef.child(uid).get();
      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        data['name'] = userData['name'];
        data['email'] = userData['email'];
        data['profileImage'] = userData['profileImage'];
      }
      return data;
    });
  }

  /// Get providers by category (real-time stream)
  Stream<List<Map<String, dynamic>>> getProvidersByCategoryStream(String categoryId) {
    return _ref.orderByChild('categoryId').equalTo(categoryId).onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> providers = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['uid'] = entry.key;
        // Only include approved and active providers
        if (val['status'] == 'approved' && val['isActive'] == true) {
          // Get user name
          final userSnap = await _usersRef.child(entry.key.toString()).get();
          if (userSnap.exists) {
            final userData = Map<String, dynamic>.from(userSnap.value as Map);
            val['name'] = userData['name'];
            val['profileImage'] = userData['profileImage'];
          }
          providers.add(val);
        }
      }
      return providers;
    });
  }

  /// Get all providers (for admin)
  Stream<List<Map<String, dynamic>>> getAllProvidersStream() {
    return _ref.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> providers = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['uid'] = entry.key;
        final userSnap = await _usersRef.child(entry.key.toString()).get();
        if (userSnap.exists) {
          final userData = Map<String, dynamic>.from(userSnap.value as Map);
          val['name'] = userData['name'];
          val['email'] = userData['email'];
          val['profileImage'] = userData['profileImage'];
        }
        providers.add(val);
      }
      return providers;
    });
  }

  /// Get top-rated providers (real-time stream)
  Stream<List<Map<String, dynamic>>> getTopProvidersStream({int limit = 10}) {
    return _ref.orderByChild('rating').onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> providers = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['uid'] = entry.key;
        if (val['status'] == 'approved' && val['isActive'] == true) {
          final userSnap = await _usersRef.child(entry.key.toString()).get();
          if (userSnap.exists) {
            final userData = Map<String, dynamic>.from(userSnap.value as Map);
            val['name'] = userData['name'];
            val['profileImage'] = userData['profileImage'];
          }
          providers.add(val);
        }
      }
      // Sort by rating descending
      providers.sort((a, b) => ((b['rating'] ?? 0.0) as num).compareTo((a['rating'] ?? 0.0) as num));
      return providers.take(limit).toList();
    });
  }

  /// Update provider profile
  Future<Map<String, dynamic>> updateProvider({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _ref.child(uid).update({
        ...data,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Profile updated successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile: $e'};
    }
  }

  /// Approve provider (admin) - This grants provider role
  Future<Map<String, dynamic>> approveProvider(String uid) async {
    try {
      // Update provider status
      await _ref.child(uid).update({
        'status': 'approved',
        'isActive': true,
        'updatedAt': ServerValue.timestamp,
      });

      // Grant provider role to user
      final userSnapshot = await _usersRef.child(uid).get();
      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        List<String> roles = List<String>.from(userData['roles'] ?? ['user']);
        if (!roles.contains('provider')) {
          roles.add('provider');
        }
        await _usersRef.child(uid).update({
          'roles': roles,
          'hasProviderApplication': false,
          'providerApplicationStatus': 'approved',
          'isApprovedProvider': true,
          'updatedAt': ServerValue.timestamp,
        });
      }

      return {'success': true, 'message': 'Provider approved successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to approve provider: $e'};
    }
  }

  /// Reject provider (admin)
  Future<Map<String, dynamic>> rejectProvider(String uid, String reason) async {
    try {
      await _ref.child(uid).update({
        'status': 'rejected',
        'rejectionReason': reason,
        'isActive': false,
        'updatedAt': ServerValue.timestamp,
      });

      // Update user application status
      await _usersRef.child(uid).update({
        'hasProviderApplication': false,
        'providerApplicationStatus': 'rejected',
        'providerRejectionReason': reason,
        'updatedAt': ServerValue.timestamp,
      });

      return {'success': true, 'message': 'Provider application rejected.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to reject provider: $e'};
    }
  }

  /// Toggle provider active status (admin)
  Future<Map<String, dynamic>> toggleProviderStatus(String uid, bool isActive) async {
    try {
      await _ref.child(uid).update({
        'isActive': isActive,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': isActive ? 'Provider activated.' : 'Provider deactivated.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update status: $e'};
    }
  }

  /// Update provider rating (called after a review is submitted)
  Future<void> updateRating(String providerId, double newRating) async {
    final snapshot = await _ref.child(providerId).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final currentRating = (data['rating'] ?? 0.0) as num;
      final reviewCount = (data['reviewCount'] ?? 0) as int;
      final updatedCount = reviewCount + 1;
      final updatedRating = ((currentRating * reviewCount) + newRating) / updatedCount;
      await _ref.child(providerId).update({
        'rating': double.parse(updatedRating.toStringAsFixed(1)),
        'reviewCount': updatedCount,
      });
    }
  }

  /// Search providers by name or service
  Future<List<Map<String, dynamic>>> searchProviders(String query) async {
    try {
      final snapshot = await _ref.get();
      if (!snapshot.exists) return [];
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> results = [];
      final queryLower = query.toLowerCase();
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['uid'] = entry.key;
        if (val['status'] != 'approved' || val['isActive'] != true) continue;
        // Get user name
        final userSnap = await _usersRef.child(entry.key.toString()).get();
        String name = '';
        if (userSnap.exists) {
          final userData = Map<String, dynamic>.from(userSnap.value as Map);
          name = userData['name'] ?? '';
          val['name'] = name;
          val['profileImage'] = userData['profileImage'];
        }
        final businessName = (val['businessName'] ?? '').toString().toLowerCase();
        final desc = (val['description'] ?? '').toString().toLowerCase();
        if (name.toLowerCase().contains(queryLower) ||
            businessName.contains(queryLower) ||
            desc.contains(queryLower)) {
          results.add(val);
        }
      }
      return results;
    } catch (e) {
      return [];
    }
  }
}
