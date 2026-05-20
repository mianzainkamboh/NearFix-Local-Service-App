import 'package:firebase_database/firebase_database.dart';

/// Central database reference helper for all Firebase Realtime Database operations.
class DatabaseService {
  static final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Node references
  static DatabaseReference get users => _db.child('users');
  static DatabaseReference get categories => _db.child('categories');
  static DatabaseReference get providers => _db.child('providers');
  static DatabaseReference get services => _db.child('services');
  static DatabaseReference get bookings => _db.child('bookings');
  static DatabaseReference get reviews => _db.child('reviews');
  static DatabaseReference get notifications => _db.child('notifications');
  static DatabaseReference get availability => _db.child('availability');

  // Helper to generate push IDs
  static String generateId(DatabaseReference ref) {
    return ref.push().key ?? DateTime.now().millisecondsSinceEpoch.toString();
  }
}
