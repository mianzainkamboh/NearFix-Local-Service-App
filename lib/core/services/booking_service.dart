import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';
import 'notification_service.dart';

class BookingService {
  final DatabaseReference _ref = DatabaseService.bookings;
  final DatabaseReference _providersRef = DatabaseService.providers;
  final DatabaseReference _usersRef = DatabaseService.users;
  final NotificationService _notificationService = NotificationService();

  /// Create a new booking
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String providerId,
    required String serviceId,
    required String serviceName,
    required String date,
    required String timeSlot,
    required String address,
    required double price,
    String notes = '',
    String paymentMethod = 'cash',
  }) async {
    try {
      final id = DatabaseService.generateId(_ref);
      await _ref.child(id).set({
        'id': id,
        'userId': userId,
        'providerId': providerId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'date': date,
        'timeSlot': timeSlot,
        'address': address,
        'notes': notes,
        'price': price,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      // Update provider total bookings
      final provSnap = await _providersRef.child(providerId).get();
      if (provSnap.exists) {
        final provData = Map<String, dynamic>.from(provSnap.value as Map);
        await _providersRef.child(providerId).update({
          'totalBookings': ((provData['totalBookings'] ?? 0) as int) + 1,
        });
      }

      // Create notification for provider
      await _notificationService.createNotification(
        userId: providerId,
        title: 'New Booking Request',
        message: 'You have a new booking for $serviceName on $date at $timeSlot',
        type: 'booking_new',
        referenceId: id,
      );

      return {'success': true, 'message': 'Booking created successfully!', 'bookingId': id};
    } catch (e) {
      return {'success': false, 'message': 'Failed to create booking: $e'};
    }
  }

  /// Update booking status
  Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
    String? reason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updatedAt': ServerValue.timestamp,
      };
      if (reason != null) updateData['rejectionReason'] = reason;
      await _ref.child(bookingId).update(updateData);

      // Get booking data for notification
      final bookingSnap = await _ref.child(bookingId).get();
      if (bookingSnap.exists) {
        final booking = Map<String, dynamic>.from(bookingSnap.value as Map);
        final userId = booking['userId'] as String;
        final providerId = booking['providerId'] as String;
        final serviceName = booking['serviceName'] ?? 'Service';

        // If completed, update provider stats
        if (status == 'completed') {
          final provSnap = await _providersRef.child(providerId).get();
          if (provSnap.exists) {
            final provData = Map<String, dynamic>.from(provSnap.value as Map);
            final price = (booking['price'] ?? 0) as num;
            await _providersRef.child(providerId).update({
              'completedBookings': ((provData['completedBookings'] ?? 0) as int) + 1,
              'totalEarnings': ((provData['totalEarnings'] ?? 0.0) as num) + price,
            });
          }
        }

        // Create notification for user
        String notifTitle;
        String notifMessage;
        switch (status) {
          case 'accepted':
            notifTitle = 'Booking Accepted';
            notifMessage = 'Your booking for $serviceName has been accepted!';
            break;
          case 'rejected':
            notifTitle = 'Booking Rejected';
            notifMessage = 'Your booking for $serviceName was rejected. ${reason ?? ''}';
            break;
          case 'in_progress':
            notifTitle = 'Service In Progress';
            notifMessage = 'Your $serviceName service is now in progress.';
            break;
          case 'completed':
            notifTitle = 'Service Completed';
            notifMessage = 'Your $serviceName service has been completed. Please leave a review!';
            break;
          default:
            notifTitle = 'Booking Update';
            notifMessage = 'Your booking for $serviceName has been updated.';
        }

        await _notificationService.createNotification(
          userId: userId,
          title: notifTitle,
          message: notifMessage,
          type: 'booking_$status',
          referenceId: bookingId,
        );
      }

      return {'success': true, 'message': 'Booking status updated!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update booking: $e'};
    }
  }

  /// Cancel a booking (by user)
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    return updateBookingStatus(bookingId: bookingId, status: 'cancelled');
  }

  /// Get a single booking
  Future<Map<String, dynamic>?> getBooking(String bookingId) async {
    try {
      final snapshot = await _ref.child(bookingId).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        // Enrich with user and provider names
        if (data['userId'] != null) {
          final userSnap = await _usersRef.child(data['userId']).get();
          if (userSnap.exists) {
            final userData = Map<String, dynamic>.from(userSnap.value as Map);
            data['userName'] = userData['name'];
            data['userPhone'] = userData['phone'];
          }
        }
        if (data['providerId'] != null) {
          final provSnap = await _usersRef.child(data['providerId']).get();
          if (provSnap.exists) {
            final provData = Map<String, dynamic>.from(provSnap.value as Map);
            data['providerName'] = provData['name'];
          }
        }
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get booking stream by ID
  Stream<Map<String, dynamic>?> getBookingStream(String bookingId) {
    return _ref.child(bookingId).onValue.asyncMap((event) async {
      if (!event.snapshot.exists) return null;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      if (data['userId'] != null) {
        final userSnap = await _usersRef.child(data['userId']).get();
        if (userSnap.exists) {
          final userData = Map<String, dynamic>.from(userSnap.value as Map);
          data['userName'] = userData['name'];
        }
      }
      if (data['providerId'] != null) {
        final provSnap = await _usersRef.child(data['providerId']).get();
        if (provSnap.exists) {
          final provData = Map<String, dynamic>.from(provSnap.value as Map);
          data['providerName'] = provData['name'];
        }
      }
      return data;
    });
  }

  /// Get bookings by user (real-time stream)
  Stream<List<Map<String, dynamic>>> getUserBookingsStream(String userId) {
    return _ref.orderByChild('userId').equalTo(userId).onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> bookings = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['id'] = entry.key;
        // Get provider name
        if (val['providerId'] != null) {
          final provSnap = await _usersRef.child(val['providerId']).get();
          if (provSnap.exists) {
            final provData = Map<String, dynamic>.from(provSnap.value as Map);
            val['providerName'] = provData['name'];
          }
        }
        bookings.add(val);
      }
      bookings.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return bookings;
    });
  }

  /// Get bookings by provider (real-time stream)
  Stream<List<Map<String, dynamic>>> getProviderBookingsStream(String providerId) {
    return _ref.orderByChild('providerId').equalTo(providerId).onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> bookings = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['id'] = entry.key;
        if (val['userId'] != null) {
          final userSnap = await _usersRef.child(val['userId']).get();
          if (userSnap.exists) {
            final userData = Map<String, dynamic>.from(userSnap.value as Map);
            val['userName'] = userData['name'];
            val['userPhone'] = userData['phone'];
          }
        }
        bookings.add(val);
      }
      bookings.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return bookings;
    });
  }

  /// Get all bookings (for admin)
  Stream<List<Map<String, dynamic>>> getAllBookingsStream() {
    return _ref.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Map<String, dynamic>>[];
      List<Map<String, dynamic>> bookings = [];
      for (var entry in data.entries) {
        final val = Map<String, dynamic>.from(entry.value as Map);
        val['id'] = entry.key;
        if (val['userId'] != null) {
          final userSnap = await _usersRef.child(val['userId']).get();
          if (userSnap.exists) {
            final userData = Map<String, dynamic>.from(userSnap.value as Map);
            val['userName'] = userData['name'];
          }
        }
        if (val['providerId'] != null) {
          final provSnap = await _usersRef.child(val['providerId']).get();
          if (provSnap.exists) {
            final provData = Map<String, dynamic>.from(provSnap.value as Map);
            val['providerName'] = provData['name'];
          }
        }
        bookings.add(val);
      }
      bookings.sort((a, b) => ((b['createdAt'] ?? 0) as num).compareTo((a['createdAt'] ?? 0) as num));
      return bookings;
    });
  }
}
