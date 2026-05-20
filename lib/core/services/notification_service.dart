import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class NotificationService {
  final DatabaseReference _ref = DatabaseService.notifications;

  /// Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    try {
      final id = DatabaseService.generateId(_ref);
      await _ref.child(id).set({
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'referenceId': referenceId ?? '',
        'isRead': false,
        'createdAt': ServerValue.timestamp,
      });
    } catch (e) {
      // Silently fail — notifications are non-critical
    }
  }

  /// Create multiple notifications for different users
  Future<void> createBulkNotifications({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    try {
      final updates = <String, dynamic>{};
      for (final userId in userIds) {
        final id = DatabaseService.generateId(_ref);
        updates['$id'] = {
          'id': id,
          'userId': userId,
          'title': title,
          'message': message,
          'type': type,
          'referenceId': referenceId ?? '',
          'isRead': false,
          'createdAt': ServerValue.timestamp,
        };
      }
      await _ref.update(updates);
    } catch (e) {
      // Silently fail — notifications are non-critical
    }
  }

  /// Get notifications for a user (real-time stream)
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _ref.orderByChild('userId').equalTo(userId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      final notifications = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value as Map);
        val['id'] = e.key;
        return val;
      }).toList();
      notifications.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return notifications;
    });
  }

  /// Get new notifications stream (only unread notifications)
  Stream<List<Map<String, dynamic>>> getNewNotificationsStream(String userId) {
    return _ref
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      
      final notifications = data.entries
          .map((e) {
            final val = Map<String, dynamic>.from(e.value as Map);
            val['id'] = e.key;
            return val;
          })
          .where((notification) => notification['isRead'] != true)
          .toList();
      
      notifications.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return notifications;
    });
  }

  /// Get unread count stream
  Stream<int> getUnreadCountStream(String userId) {
    return _ref.orderByChild('userId').equalTo(userId).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return 0;
      return data.values.where((v) {
        final val = v as Map<dynamic, dynamic>;
        return val['isRead'] != true;
      }).length;
    });
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _ref.child(notificationId).update({'isRead': true});
  }

  /// Mark all as read for a user
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _ref.orderByChild('userId').equalTo(userId).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      for (var entry in data.entries) {
        await _ref.child(entry.key.toString()).update({'isRead': true});
      }
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _ref.child(notificationId).remove();
  }

  /// Helper method to create booking notifications
  Future<void> createBookingNotification({
    required String userId,
    required String bookingId,
    required String status,
    String? providerName,
    String? serviceName,
  }) async {
    String title = 'Booking Update';
    String message = 'Your booking status has been updated to $status';
    
    switch (status.toLowerCase()) {
      case 'confirmed':
        title = 'Booking Confirmed';
        message = 'Your booking${serviceName != null ? ' for $serviceName' : ''} has been confirmed';
        break;
      case 'completed':
        title = 'Service Completed';
        message = 'Your service${serviceName != null ? ' ($serviceName)' : ''} has been completed';
        break;
      case 'cancelled':
        title = 'Booking Cancelled';
        message = 'Your booking${serviceName != null ? ' for $serviceName' : ''} has been cancelled';
        break;
      case 'in_progress':
        title = 'Service Started';
        message = 'Your service${serviceName != null ? ' ($serviceName)' : ''} has started';
        break;
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'booking',
      referenceId: bookingId,
    );
  }

  /// Helper method to create payment notifications
  Future<void> createPaymentNotification({
    required String userId,
    required String amount,
    required String status,
    String? bookingId,
  }) async {
    String title = 'Payment Update';
    String message = 'Payment of ₹$amount is $status';
    
    switch (status.toLowerCase()) {
      case 'success':
        title = 'Payment Successful';
        message = 'Payment of ₹$amount has been processed successfully';
        break;
      case 'failed':
        title = 'Payment Failed';
        message = 'Payment of ₹$amount has failed. Please try again';
        break;
      case 'pending':
        title = 'Payment Pending';
        message = 'Payment of ₹$amount is being processed';
        break;
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: 'payment',
      referenceId: bookingId,
    );
  }
}
