import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/booking_service.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/custom_button.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: bookingService.getBookingStream(bookingId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final booking = snapshot.data;
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          final status = booking['status'] ?? 'pending';
          final isUser = booking['userId'] == currentUid;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Column(
                    children: [
                      Icon(_getStatusIcon(status), size: 48, color: _getStatusColor(status)),
                      const SizedBox(height: 8),
                      Text(_getStatusTitle(status), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                      const SizedBox(height: 4),
                      Text('Booking ID: ${booking['id']?.substring(0, 8) ?? ''}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
                // Service Info
                _buildInfoCard('Service Details', [
                  _buildInfoRow('Service', booking['serviceName'] ?? 'N/A'),
                  _buildInfoRow('Provider', booking['providerName'] ?? 'N/A'),
                  _buildInfoRow('Date', booking['date'] ?? 'N/A'),
                  _buildInfoRow('Time', booking['timeSlot'] ?? 'N/A'),
                  _buildInfoRow('Price', booking['price'] != null ? '₹${(booking['price'] as num).toInt()}' : 'N/A'),
                  _buildInfoRow('Payment', booking['paymentMethod'] ?? 'cash'),
                ]),
                const SizedBox(height: 12),
                _buildInfoCard('Location', [
                  _buildInfoRow('Address', booking['address'] ?? 'N/A'),
                  if ((booking['notes'] ?? '').isNotEmpty)
                    _buildInfoRow('Notes', booking['notes']),
                ]),
                const SizedBox(height: 12),
                if (isUser && status == 'pending')
                  CustomButton(
                    text: 'Cancel Booking',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Booking?'),
                          content: const Text('Are you sure you want to cancel this booking?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await bookingService.cancelBooking(bookingId);
                      }
                    },
                    backgroundColor: AppColors.error,
                  ),
                if (isUser && status == 'completed' && booking['isReviewed'] != true) ...[
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Leave a Review',
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.review, arguments: {
                      'bookingId': bookingId,
                      'providerId': booking['providerId'],
                    }),
                  ),
                ],
                const SizedBox(height: AppConstants.paddingL),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.pending;
      case 'accepted': return AppColors.accepted;
      case 'in_progress': return AppColors.info;
      case 'completed': return AppColors.completed;
      case 'cancelled': return AppColors.cancelled;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending_actions;
      case 'accepted': return Icons.check_circle;
      case 'in_progress': return Icons.engineering;
      case 'completed': return Icons.task_alt;
      case 'cancelled': return Icons.cancel;
      default: return Icons.info;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'pending': return 'Booking Pending';
      case 'accepted': return 'Booking Accepted';
      case 'in_progress': return 'Service In Progress';
      case 'completed': return 'Service Completed';
      case 'cancelled': return 'Booking Cancelled';
      default: return status;
    }
  }
}
