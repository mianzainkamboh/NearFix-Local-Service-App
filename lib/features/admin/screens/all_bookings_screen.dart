import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/booking_service.dart';
import '../../../shared/widgets/status_chip.dart';

class AllBookingsScreen extends StatelessWidget {
  const AllBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('All Bookings'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: bookingService.getAllBookingsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final all = snapshot.data ?? [];
            final pending = all.where((b) => b['status'] == 'pending').toList();
            final accepted = all.where((b) => b['status'] == 'accepted').toList();
            final inProgress = all.where((b) => b['status'] == 'in_progress').toList();
            final completed = all.where((b) => b['status'] == 'completed' || b['status'] == 'cancelled' || b['status'] == 'rejected').toList();

            return TabBarView(
              children: [
                _buildList(all),
                _buildList(pending),
                _buildList(accepted),
                _buildList(inProgress),
                _buildList(completed),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final b = bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(b['serviceName'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold))),
                  StatusChip(status: b['status'] ?? 'pending'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildProviderImage(b['providerImage'] ?? ''),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.person, 'User: ${b['userName'] ?? 'Unknown'}'),
                        _infoRow(Icons.engineering, 'Provider: ${b['providerName'] ?? 'Unknown'}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _infoRow(Icons.calendar_today, '${b['date'] ?? ''} • ${b['timeSlot'] ?? ''}'),
              if ((b['price'] ?? 0) > 0) _infoRow(Icons.currency_rupee, '₹${(b['price'] as num).toInt()}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderImage(String imageUrl) {
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

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        ],
      ),
    );
  }
}
