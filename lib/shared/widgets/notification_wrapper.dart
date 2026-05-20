import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/push_notification_service.dart';

class NotificationWrapper extends StatefulWidget {
  final Widget child;

  const NotificationWrapper({
    super.key,
    required this.child,
  });

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  final PushNotificationService _pushNotificationService = PushNotificationService();
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
    
    // Listen for auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in, initialize push notifications
        _initializePushNotifications();
      } else {
        // User logged out, dispose notifications
        _pushNotificationService.dispose();
      }
    });
  }

  void _initializeNotifications() {
    if (mounted) {
      _initializePushNotifications();
    }
  }

  void _initializePushNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      await _pushNotificationService.initialize(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update context when dependencies change (e.g., navigation)
    _pushNotificationService.updateContext(context);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _pushNotificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}