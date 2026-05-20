import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/status_chip.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  final BookingService _bookingService = BookingService();
  final ProviderService _providerService = ProviderService();
  final NotificationService _notificationService = NotificationService();
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Provider Panel',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StreamBuilder<int>(
                        stream: _notificationService.getUnreadCountStream(_uid),
                        builder: (context, snap) {
                          final count = snap.data ?? 0;
                          return _buildIconButton(Icons.notifications_outlined, () => Navigator.pushNamed(context, AppRoutes.notifications), badge: count);
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.providerProfile),
                        child: const CircleAvatar(radius: 22, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Stats Cards — Real-time from Firebase
              StreamBuilder<Map<String, dynamic>?>(
                stream: _providerService.getProviderStream(_uid),
                builder: (context, snapshot) {
                  final provider = snapshot.data ?? {};
                  return Row(
                    children: [
                      _buildStatCard('Total\nBookings', '${provider['totalBookings'] ?? 0}', Icons.calendar_today, AppColors.primary),
                      const SizedBox(width: 12),
                      _buildStatCard('Completed', '${provider['completedBookings'] ?? 0}', Icons.check_circle, AppColors.success),
                      const SizedBox(width: 12),
                      _buildStatCard('Earnings', '₹${((provider['totalEarnings'] ?? 0) as num).toInt()}', Icons.account_balance_wallet, AppColors.warning),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Quick Actions
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildActionCard(Icons.access_time, 'Availability', AppColors.info, () => Navigator.pushNamed(context, AppRoutes.availability)),
                  const SizedBox(width: 12),
                  _buildActionCard(Icons.add_circle, 'Add Service', AppColors.success, () => Navigator.pushNamed(context, AppRoutes.addService)),
                  const SizedBox(width: 12),
                  _buildActionCard(Icons.list_alt, 'My Services', AppColors.primary, () => Navigator.pushNamed(context, AppRoutes.providerServices)),
                  const SizedBox(width: 12),
                  _buildActionCard(Icons.bar_chart, 'Earnings', AppColors.warning, () => Navigator.pushNamed(context, AppRoutes.earnings)),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Recent Bookings — real-time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.providerBookings),
                    child: const Text('View All'),
                  ),
                ],
              ),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _bookingService.getProviderBookingsStream(_uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                  }
                  final bookings = snapshot.data ?? [];
                  if (bookings.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No bookings yet', style: TextStyle(color: AppColors.textSecondary))),
                    );
                  }
                  final recent = bookings.take(5).toList();
                  return Column(
                    children: recent.map((booking) => _buildBookingTile(booking)).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingTile(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.bookingDetail, arguments: {'bookingId': booking['id']}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.handyman, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking['serviceName'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${booking['userName'] ?? 'User'} • ${booking['date']} ${booking['timeSlot']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(status: status),
                if ((booking['price'] ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('₹${(booking['price'] as num).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {int badge = 0}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          if (badge > 0)
            Positioned(
              right: 0, top: 0,
              child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle), child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            ),
        ],
      ),
    );
  }
}
