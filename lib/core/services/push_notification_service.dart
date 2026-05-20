import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import 'database_service.dart';

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  
  BuildContext? _context;
  bool _isInitialized = false;

  /// Initialize push notifications
  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;
    
    _context = context;
    
    // Initialize Firebase Messaging
    await _initializeFirebaseMessaging();
    
    _isInitialized = true;
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
      announcement: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ User granted provisional notification permission');
    } else {
      print('❌ User declined notification permission');
      return;
    }

    // Configure foreground notification presentation options
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
      print('📱 FCM Token: $token');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);

    // Handle foreground messages - FCM will show notification automatically
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Save FCM token to database
  Future<void> _saveTokenToDatabase(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await DatabaseService.users.child(user.uid).update({
        'fcmToken': token,
        'lastTokenUpdate': DateTime.now().millisecondsSinceEpoch,
      });
      print('💾 FCM token saved to database');
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔔 Received foreground message: ${message.messageId}');
    print('📬 Title: ${message.notification?.title}');
    print('📝 Body: ${message.notification?.body}');
    
    // FCM will automatically show the notification in the system tray
    // We just need to save it to database for the in-app notification list
    await _saveNotificationToDatabase(message);
    
    // Optionally show an in-app banner as well
    if (_context != null && _context!.mounted) {
      _showInAppBanner(message);
    }
  }

  /// Show in-app banner (optional, in addition to system notification)
  void _showInAppBanner(RemoteMessage message) {
    if (_context == null || !_context!.mounted) return;

    final String title = message.notification?.title ?? 'Nearfix';
    final String body = message.notification?.body ?? 'You have a new notification';

    ScaffoldMessenger.of(_context!).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _handleNotificationTap(message),
        ),
      ),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.messageId}');
    
    if (_context != null && _context!.mounted) {
      _navigateBasedOnNotification(message);
    }
  }

  /// Save notification to database
  Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String title = message.notification?.title ?? 'Notification';
    final String body = message.notification?.body ?? '';
    final Map<String, dynamic> data = message.data;
    
    await _notificationService.createNotification(
      userId: user.uid,
      title: title,
      message: body,
      type: data['type'] ?? 'general',
      referenceId: data['referenceId'],
    );
    
    print('💾 Notification saved to database');
  }

  /// Navigate based on notification data
  void _navigateBasedOnNotification(RemoteMessage message) {
    _navigateBasedOnData(message.data);
  }

  /// Navigate based on data
  void _navigateBasedOnData(Map<String, dynamic> data) {
    if (_context == null || !_context!.mounted) return;

    final String type = data['type'] ?? '';
    final String? referenceId = data['referenceId'];

    print('🧭 Navigating based on type: $type');

    switch (type) {
      case 'booking':
      case 'booking_new':
      case 'booking_accepted':
      case 'booking_rejected':
      case 'booking_completed':
      case 'booking_in_progress':
        if (referenceId != null && referenceId.isNotEmpty) {
          Navigator.of(_context!).pushNamed('/booking-detail', arguments: referenceId);
        } else {
          Navigator.of(_context!).pushNamed('/user-bookings');
        }
        break;
      case 'payment':
      case 'payment_success':
      case 'payment_failed':
        Navigator.of(_context!).pushNamed('/user-bookings');
        break;
      case 'message':
        Navigator.of(_context!).pushNamed('/notifications');
        break;
      default:
        Navigator.of(_context!).pushNamed('/notifications');
    }
  }

  /// Send push notification to specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    try {
      // Get user's FCM token
      final userSnapshot = await DatabaseService.users.child(userId).get();
      if (!userSnapshot.exists) return;
      
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      final String? fcmToken = userData['fcmToken'];
      
      if (fcmToken == null) {
        print('⚠️ No FCM token found for user: $userId');
        return;
      }

      // Save to database - this will trigger real-time listener
      await _notificationService.createNotification(
        userId: userId,
        title: title,
        message: message,
        type: type,
        referenceId: referenceId,
      );
      
      print('✅ Notification saved for user: $userId');
      print('📱 FCM Token available: $fcmToken');
      print('ℹ️ Note: To send actual push notifications, implement server-side FCM using this token');
      
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Update context
  void updateContext(BuildContext context) {
    _context = context;
  }

  /// Dispose
  void dispose() {
    _context = null;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Handling background message: ${message.messageId}');
  print('📬 Title: ${message.notification?.title}');
  print('📝 Body: ${message.notification?.body}');
  
  // Background notifications are automatically displayed by FCM
  // This handler is for additional processing if needed
}