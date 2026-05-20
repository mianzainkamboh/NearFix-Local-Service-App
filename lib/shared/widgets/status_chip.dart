import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class StatusChip extends StatelessWidget {
  final String status;
  final bool isLarge;

  const StatusChip({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color get backgroundColor {
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
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'active':
        return AppColors.success;
      case 'inactive':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get displayText {
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
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'active':
        return 'Active';
      case 'inactive':
        return 'Inactive';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 16 : 12,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusRound),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: isLarge ? 14 : 12,
          fontWeight: FontWeight.w600,
          color: backgroundColor,
        ),
      ),
    );
  }
}
