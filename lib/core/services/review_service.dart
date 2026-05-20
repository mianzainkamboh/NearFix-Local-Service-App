import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';
import 'provider_service.dart';

class ReviewService {
  final DatabaseReference _ref = DatabaseService.reviews;
  final ProviderService _providerService = ProviderService();

  /// Submit a review
  Future<Map<String, dynamic>> submitReview({
    required String bookingId,
    required String userId,
    required String providerId,
    required double rating,
    required String comment,
  }) async {
    try {
      // Check if review already exists for this booking
      final existing = await _ref.orderByChild('bookingId').equalTo(bookingId).get();
      if (existing.exists) {
        return {'success': false, 'message': 'You have already reviewed this booking.'};
      }

      final id = DatabaseService.generateId(_ref);
      // Get user name
      final userSnap = await DatabaseService.users.child(userId).get();
      String userName = 'User';
      if (userSnap.exists) {
        final userData = Map<String, dynamic>.from(userSnap.value as Map);
        userName = userData['name'] ?? 'User';
      }

      await _ref.child(id).set({
        'id': id,
        'bookingId': bookingId,
        'userId': userId,
        'userName': userName,
        'providerId': providerId,
        'rating': rating,
        'comment': comment,
        'createdAt': ServerValue.timestamp,
      });

      // Update provider's average rating
      await _providerService.updateRating(providerId, rating);

      // Mark booking as reviewed
      await DatabaseService.bookings.child(bookingId).update({
        'isReviewed': true,
      });

      return {'success': true, 'message': 'Review submitted successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit review: $e'};
    }
  }

  /// Get reviews for a provider (real-time stream)
  Stream<List<Map<String, dynamic>>> getProviderReviewsStream(String providerId) {
    return _ref.orderByChild('providerId').equalTo(providerId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      final reviews = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value as Map);
        val['id'] = e.key;
        return val;
      }).toList();
      reviews.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return reviews;
    });
  }

  /// Get all reviews (for admin)
  Stream<List<Map<String, dynamic>>> getAllReviewsStream() {
    return _ref.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> reviews = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['id'] = entry.key;
        // Get provider name
        if (val['providerId'] != null) {
          final provSnap = await DatabaseService.users.child(val['providerId']).get();
          if (provSnap.exists) {
            final provData = Map<String, dynamic>.from(provSnap.value as Map);
            val['providerName'] = provData['name'];
          }
        }
        reviews.add(val);
      }
      reviews.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return reviews;
    });
  }

  /// Delete a review (admin moderation)
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      await _ref.child(reviewId).remove();
      return {'success': true, 'message': 'Review deleted.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete review: $e'};
    }
  }
}
