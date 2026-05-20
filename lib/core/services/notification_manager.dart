import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import '../../shared/widgets/notification_popup.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();
  StreamSubscription<List<Map<String, dynamic>>>? _notificationSubscription;
  OverlayEntry? _currentOverlay;
  final List<String> _processedNotifications = [];
  BuildContext? _context;

  /// Initialize the notification manager with context
  void initialize(BuildContext context) {
    _context = context;
    _startListening();
  }

  /// Start listening for new notifications
  void _startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationService
        .getNotificationsStream(user.uid)
        .listen(_handleNotifications);
  }

  /// Handle incoming notifications
  void _handleNotifications(List<Map<String, dynamic>> notifications) {
    if (_context == null || !_context!.mounted) return;

    // Find new notifications that haven't been processed
    for (final notification in notifications) {
      final id = notification['id'] as String;
      final isRead = notification['isRead'] as bool? ?? false;
      
      // Only show popup for new, unread notifications
      if (!isRead && !_processedNotifications.contains(id)) {
        _processedNotifications.add(id);
        _showNotificationPopup(notification);
        
        // Keep only last 50 processed notifications to prevent memory issues
        if (_processedNotifications.length > 50) {
          _processedNotifications.removeRange(0, _processedNotifications.length - 50);
        }
        
        // Only show one popup at a time
        break;
      }
    }
  }

  /// Show notification popup
  void _showNotificationPopup(Map<String, dynamic> notification) {
    if (_context == null || !_context!.mounted) return;

    // Remove existing overlay if any
    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: NotificationPopup(
          title: notification['title'] ?? 'Notification',
          message: notification['message'] ?? '',
          type: notification['type'] ?? 'info',
          onTap: () => _handleNotificationTap(notification),
          onDismiss: _removeCurrentOverlay,
        ),
      ),
    );

    Overlay.of(_context!).insert(_currentOverlay!);
  }

  /// Handle notification tap
  void _handleNotificationTap(Map<String, dynamic> notification) {
    if (_context == null || !_context!.mounted) return;

    // Mark as read
    final id = notification['id'] as String?;
    if (id != null) {
      _notificationService.markAsRead(id);
    }

    // Navigate based on notification type
    final type = notification['type'] as String? ?? '';
    final referenceId = notification['referenceId'] as String? ?? '';

    switch (type.toLowerCase()) {
      case 'booking':
        if (referenceId.isNotEmpty) {
          Navigator.of(_context!).pushNamed('/booking-detail', arguments: referenceId);
        } else {
          Navigator.of(_context!).pushNamed('/user-bookings');
        }
        break;
      case 'payment':
        Navigator.of(_context!).pushNamed('/user-bookings');
        break;
      case 'message':
        Navigator.of(_context!).pushNamed('/notifications');
        break;
      default:
        Navigator.of(_context!).pushNamed('/notifications');
    }
  }

  /// Remove current overlay
  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Update context (useful for navigation changes)
  void updateContext(BuildContext context) {
    _context = context;
  }

  /// Restart listening (useful after login/logout)
  void restart() {
    _processedNotifications.clear();
    _removeCurrentOverlay();
    _startListening();
  }

  /// Stop listening and cleanup
  void dispose() {
    _notificationSubscription?.cancel();
    _removeCurrentOverlay();
    _processedNotifications.clear();
    _context = null;
  }

  /// Manually show a notification popup (for testing or immediate notifications)
  void showManualNotification({
    required String title,
    required String message,
    required String type,
    VoidCallback? onTap,
  }) {
    if (_context == null || !_context!.mounted) return;

    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: NotificationPopup(
          title: title,
          message: message,
          type: type,
          onTap: onTap,
          onDismiss: _removeCurrentOverlay,
        ),
      ),
    );

    Overlay.of(_context!).insert(_currentOverlay!);
  }
}