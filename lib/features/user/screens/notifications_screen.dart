import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final notificationService = NotificationService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => notificationService.markAllAsRead(userId),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: notificationService.getNotificationsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  const Text('No notifications', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isRead = notif['isRead'] == true;
              return Dismissible(
                key: Key(notif['id'] ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => notificationService.deleteNotification(notif['id']),
                child: GestureDetector(
                  onTap: () {
                    if (!isRead) notificationService.markAsRead(notif['id']);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(AppConstants.paddingM),
                    decoration: BoxDecoration(
                      color: isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      border: isRead ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getTypeColor(notif['type'] ?? '').withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getTypeIcon(notif['type'] ?? ''), size: 20, color: _getTypeColor(notif['type'] ?? '')),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notif['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(notif['message'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    if (type.contains('accepted')) return AppColors.success;
    if (type.contains('rejected') || type.contains('cancelled')) return AppColors.error;
    if (type.contains('completed')) return AppColors.completed;
    if (type.contains('new')) return AppColors.info;
    return AppColors.primary;
  }

  IconData _getTypeIcon(String type) {
    if (type.contains('accepted')) return Icons.check_circle;
    if (type.contains('rejected')) return Icons.cancel;
    if (type.contains('completed')) return Icons.task_alt;
    if (type.contains('new')) return Icons.notifications_active;
    if (type.contains('cancelled')) return Icons.cancel;
    return Icons.notifications;
  }
}
