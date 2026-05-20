import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/provider_service.dart';

class ProviderApprovalScreen extends StatelessWidget {
  final String providerId;

  const ProviderApprovalScreen({super.key, required this.providerId});

  @override
  Widget build(BuildContext context) {
    final providerService = ProviderService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Provider Approval'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: providerService.getProviderStream(providerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final provider = snapshot.data;
          if (provider == null) {
            return const Center(child: Text('Provider not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider Info Header
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 50, backgroundColor: AppColors.primary, child: Icon(Icons.person, size: 60, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(provider['name'] ?? 'Provider', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(provider['email'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXL),
                // Details Section
                _buildSection('Business Details', [
                  _buildInfoRow(Icons.business, 'Business Name', provider['businessName'] ?? 'N/A'),
                  _buildInfoRow(Icons.category, 'Category ID', provider['categoryId'] ?? 'N/A'),
                  _buildInfoRow(Icons.description, 'Description', provider['description'] ?? 'N/A'),
                  _buildInfoRow(Icons.work_history, 'Experience', provider['experience'] ?? 'N/A'),
                  _buildInfoRow(Icons.location_on, 'Service Area', provider['serviceArea'] ?? 'N/A'),
                  _buildInfoRow(Icons.phone, 'Phone', provider['phone'] ?? 'N/A'),
                ]),
                const SizedBox(height: AppConstants.paddingL),
                // Status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: _getStatusColor(provider['status'] ?? 'pending').withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: _getStatusColor(provider['status'] ?? 'pending').withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: _getStatusColor(provider['status'] ?? 'pending')),
                      const SizedBox(width: 8),
                      Text('Status: ${(provider['status'] ?? 'pending').toString().toUpperCase()}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(provider['status'] ?? 'pending'))),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingXL),
                // Action Buttons
                if (provider['status'] == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await providerService.rejectProvider(providerId, 'Does not meet requirements');
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await providerService.approveProvider(providerId);
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
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
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
