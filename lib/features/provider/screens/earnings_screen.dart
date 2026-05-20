import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/booking_service.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final providerService = ProviderService();
    final bookingService = BookingService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Earnings Card — real-time
            StreamBuilder<Map<String, dynamic>?>(
              stream: providerService.getProviderStream(uid),
              builder: (context, snapshot) {
                final provider = snapshot.data ?? {};
                final total = ((provider['totalEarnings'] ?? 0) as num).toDouble();
                final completed = (provider['completedBookings'] ?? 0) as int;
                final totalBookings = (provider['totalBookings'] ?? 0) as int;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('₹${total.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildEarningsStat('Completed', '$completed', Colors.white),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _buildEarningsStat('Total', '$totalBookings', Colors.white),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _buildEarningsStat('Avg/Job', completed > 0 ? '₹${(total / completed).toInt()}' : '₹0', Colors.white),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.paddingL),
            // Recent Completed Bookings (Earnings history)
            const Text('Earnings History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: bookingService.getProviderBookingsStream(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allBookings = snapshot.data ?? [];
                final completedBookings = allBookings.where((b) => b['status'] == 'completed').toList();
                
                if (completedBookings.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No completed bookings yet', style: TextStyle(color: AppColors.textSecondary))),
                  );
                }

                // Calculate total from completed bookings
                double completedTotal = 0;
                for (var booking in completedBookings) {
                  completedTotal += ((booking['price'] ?? 0) as num).toDouble();
                }

                return Column(
                  children: [
                    // Show summary of completed bookings
                    Container(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Completed Bookings', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('${completedBookings.length} jobs', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            '₹${completedTotal.toInt()}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List all completed bookings
                    ...completedBookings.map((booking) {
                      final price = ((booking['price'] ?? 0) as num).toInt();
                      return Container(
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
                              decoration: BoxDecoration(
                                color: price > 0 ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                price > 0 ? Icons.check_circle : Icons.info,
                                color: price > 0 ? AppColors.success : AppColors.warning,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(booking['serviceName'] ?? 'Service', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${booking['userName'] ?? 'User'} • ${booking['date']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  if (price == 0)
                                    Text('No price set', style: TextStyle(color: AppColors.warning, fontSize: 11, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            Text(
                              '+₹$price',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: price > 0 ? AppColors.success : AppColors.warning,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildEarningsStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }
}
