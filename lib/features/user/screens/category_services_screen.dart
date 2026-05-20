import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/provider_service.dart';
import '../../../shared/widgets/provider_card.dart';

class CategoryServicesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryServicesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final providerService = ProviderService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: providerService.getProvidersByCategoryStream(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final providers = snapshot.data ?? [];
          if (providers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text('No providers found for $categoryName', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Check back later!', style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              return ProviderCard(
                name: provider['name'] ?? 'Provider',
                service: provider['businessName'] ?? '',
                imageUrl: provider['profileImage'] ?? '',
                rating: (provider['rating'] ?? 0.0).toDouble(),
                reviewCount: (provider['reviewCount'] ?? 0) as int,
                price: 0,
                experience: provider['experience'] ?? '',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.providerDetail,
                  arguments: {'providerId': provider['uid']},
                ),
                onBookNow: () => Navigator.pushNamed(
                  context,
                  AppRoutes.booking,
                  arguments: {'providerId': provider['uid'], 'serviceId': ''},
                ),
              );
            },
          );
        },
      ),
    );
  }
}
