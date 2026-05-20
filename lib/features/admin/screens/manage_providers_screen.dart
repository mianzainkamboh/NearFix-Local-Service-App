import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/provider_service.dart';
import '../../../shared/widgets/status_chip.dart';

class ManageProvidersScreen extends StatelessWidget {
  const ManageProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providerService = ProviderService();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Manage Providers'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: providerService.getAllProvidersStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final allProviders = snapshot.data ?? [];
            final pending = allProviders.where((p) => p['status'] == 'pending').toList();
            final approved = allProviders.where((p) => p['status'] == 'approved').toList();
            final rejected = allProviders.where((p) => p['status'] == 'rejected').toList();

            return TabBarView(
              children: [
                _buildProviderList(context, pending, providerService, showActions: true),
                _buildProviderList(context, approved, providerService),
                _buildProviderList(context, rejected, providerService),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProviderList(BuildContext context, List<Map<String, dynamic>> providers, ProviderService service, {bool showActions = false}) {
    if (providers.isEmpty) {
      return const Center(child: Text('No providers', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final p = providers[index];
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
                children: [
                  _buildProfileImage(p['profileImage'] ?? ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] ?? 'Provider', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(p['businessName'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        Text(p['email'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  StatusChip(status: p['status'] ?? 'pending'),
                ],
              ),
              const SizedBox(height: 8),
              if ((p['description'] ?? '').isNotEmpty)
                Text(p['description'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
              if ((p['experience'] ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Experience: ${p['experience']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => service.rejectProvider(p['uid'], 'Does not meet requirements'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => service.approveProvider(p['uid']),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
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
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 24, color: Colors.white),
      );
    }

    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http')) {
      // Network image
      return Container(
        width: 48,
        height: 48,
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
                child: const Icon(Icons.person, size: 24, color: Colors.white),
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
            width: 48,
            height: 48,
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
                    child: const Icon(Icons.person, size: 24, color: Colors.white),
                  );
                },
              ),
            ),
          );
        } else {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 24, color: Colors.white),
          );
        }
      } catch (e) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 24, color: Colors.white),
        );
      }
    }
  }
}
