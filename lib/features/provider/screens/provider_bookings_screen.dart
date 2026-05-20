import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/booking_service.dart';
import '../../../shared/widgets/status_chip.dart';

class ProviderBookingsScreen extends StatelessWidget {
  const ProviderBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bookingService = BookingService();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: bookingService.getProviderBookingsStream(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allBookings = snapshot.data ?? [];

            final pending = allBookings.where((b) => b['status'] == 'pending').toList();
            final accepted = allBookings.where((b) => b['status'] == 'accepted').toList();
            final inProgress = allBookings.where((b) => b['status'] == 'in_progress').toList();
            final completed = allBookings.where((b) => b['status'] == 'completed' || b['status'] == 'cancelled' || b['status'] == 'rejected').toList();

            return TabBarView(
              children: [
                _buildBookingList(context, pending, bookingService, showActions: true),
                _buildBookingList(context, accepted, bookingService, showStartAction: true),
                _buildBookingList(context, inProgress, bookingService, showCompleteAction: true),
                _buildBookingList(context, completed, bookingService),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(
    BuildContext context,
    List<Map<String, dynamic>> bookings,
    BookingService bookingService, {
    bool showActions = false,
    bool showStartAction = false,
    bool showCompleteAction = false,
  }) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(booking['serviceName'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  StatusChip(status: booking['status'] ?? 'pending'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildUserImage(booking['userImage'] ?? ''),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('User', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('${booking['date']} • ${booking['timeSlot']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const Spacer(),
                  if ((booking['price'] ?? 0) > 0)
                    Text('₹${(booking['price'] as num).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
              if ((booking['address'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(booking['address'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
              // Action buttons
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => bookingService.updateBookingStatus(bookingId: booking['id'], status: 'rejected', reason: 'Provider declined'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => bookingService.updateBookingStatus(bookingId: booking['id'], status: 'accepted'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
              if (showStartAction) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => bookingService.updateBookingStatus(bookingId: booking['id'], status: 'in_progress'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, foregroundColor: Colors.white),
                    child: const Text('Start Service'),
                  ),
                ),
              ],
              if (showCompleteAction) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => bookingService.updateBookingStatus(bookingId: booking['id'], status: 'completed'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    child: const Text('Mark Completed'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 20, color: Colors.white),
      );
    }

    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http')) {
      // Network image
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.inputFill,
        ),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.primary,
                child: const Icon(Icons.person, size: 20, color: Colors.white),
              );
            },
          ),
        ),
      );
    } else {
      // Local file path
      try {
        final file = File(imageUrl);
        if (file.existsSync()) {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputFill,
            ),
            child: ClipOval(
              child: Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary,
                    child: const Icon(Icons.person, size: 20, color: Colors.white),
                  );
                },
              ),
            ),
          );
        } else {
          return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          );
        }
      } catch (e) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 20, color: Colors.white),
        );
      }
    }
  }
}
