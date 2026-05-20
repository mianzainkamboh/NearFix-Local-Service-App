import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class BookingCard extends StatelessWidget {
  final String? bookingId;
  final String serviceName;
  final String providerName;
  final String? userName;
  final String date;
  final String time;
  final String status;
  final double? amount;
  final double? price;
  final bool isProvider;
  final String? providerImage;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  const BookingCard({
    super.key,
    this.bookingId,
    required this.serviceName,
    required this.providerName,
    this.userName,
    required this.date,
    required this.time,
    required this.status,
    this.amount,
    this.price,
    this.isProvider = false,
    this.providerImage,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onComplete,
    this.onCancel,
    this.onReview,
  });

  double get displayAmount => amount ?? price ?? 0;

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'accepted':
        return AppColors.accepted;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
        return AppColors.completed;
      case 'cancelled':
        return AppColors.cancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusL),
                  topRight: Radius.circular(AppConstants.radiusL),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (bookingId != null)
                    Text(
                      '#$bookingId',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    const SizedBox(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildProviderImage(),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isProvider ? (userName ?? '') : providerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isProvider ? 'User' : 'Provider',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoItem(Icons.calendar_today_outlined, date),
                      const SizedBox(width: 16),
                      _buildInfoItem(Icons.access_time, time),
                      const Spacer(),
                      Text(
                        '₹${displayAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions for Provider
            if (isProvider && status.toLowerCase() == 'pending')
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.inputFill)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ),
            // Complete action for accepted bookings
            if (isProvider && status.toLowerCase() == 'accepted')
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.inputFill)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    child: const Text('Mark as Completed'),
                  ),
                ),
              ),
            // User actions - Cancel for pending/accepted, Review for completed
            if (!isProvider && (onCancel != null || onReview != null))
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.inputFill)),
                ),
                child: Row(
                  children: [
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    if (onReview != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onReview,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Write Review', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProviderImage() {
    if (providerImage == null || providerImage!.isEmpty) {
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
    if (providerImage!.startsWith('http')) {
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
            providerImage!,
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
        final file = File(providerImage!);
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
