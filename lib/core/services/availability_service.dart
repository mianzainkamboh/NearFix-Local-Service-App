import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class AvailabilityService {
  final DatabaseReference _ref = DatabaseService.availability;

  /// Save provider availability
  Future<Map<String, dynamic>> saveAvailability({
    required String providerId,
    required List<String> workingDays,
    required String startTime,
    required String endTime,
    required int slotDuration, // in minutes
  }) async {
    try {
      await _ref.child(providerId).set({
        'providerId': providerId,
        'workingDays': workingDays,
        'startTime': startTime,
        'endTime': endTime,
        'slotDuration': slotDuration,
        'blockedDates': [],
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Availability saved successfully!'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to save availability: $e'};
    }
  }

  /// Get provider availability
  Future<Map<String, dynamic>?> getAvailability(String providerId) async {
    try {
      final snapshot = await _ref.child(providerId).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get provider availability stream
  Stream<Map<String, dynamic>?> getAvailabilityStream(String providerId) {
    return _ref.child(providerId).onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  /// Block a specific date
  Future<Map<String, dynamic>> blockDate(String providerId, String date) async {
    try {
      final snapshot = await _ref.child(providerId).child('blockedDates').get();
      List<String> blockedDates = [];
      if (snapshot.exists && snapshot.value != null) {
        blockedDates = List<String>.from(snapshot.value as List);
      }
      if (!blockedDates.contains(date)) {
        blockedDates.add(date);
      }
      await _ref.child(providerId).update({
        'blockedDates': blockedDates,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Date blocked.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to block date: $e'};
    }
  }

  /// Unblock a specific date
  Future<Map<String, dynamic>> unblockDate(String providerId, String date) async {
    try {
      final snapshot = await _ref.child(providerId).child('blockedDates').get();
      List<String> blockedDates = [];
      if (snapshot.exists && snapshot.value != null) {
        blockedDates = List<String>.from(snapshot.value as List);
      }
      blockedDates.remove(date);
      await _ref.child(providerId).update({
        'blockedDates': blockedDates,
        'updatedAt': ServerValue.timestamp,
      });
      return {'success': true, 'message': 'Date unblocked.'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to unblock date: $e'};
    }
  }

  /// Generate time slots based on availability
  List<String> generateTimeSlots(String startTime, String endTime, int slotDuration) {
    List<String> slots = [];
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);
    if (start == null || end == null) return slots;

    var current = start;
    while (current.isBefore(end)) {
      slots.add(_formatTime(current));
      current = current.add(Duration(minutes: slotDuration));
    }
    return slots;
  }

  DateTime? _parseTime(String time) {
    try {
      final parts = time.replaceAll(RegExp(r'[APMapm\s]'), '').split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      final isPM = time.toUpperCase().contains('PM');
      if (isPM && hours != 12) hours += 12;
      if (!isPM && hours == 12) hours = 0;
      return DateTime(2000, 1, 1, hours, minutes);
    } catch (e) {
      return null;
    }
  }

  String _formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
