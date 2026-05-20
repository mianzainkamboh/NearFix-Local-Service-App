import 'package:flutter/material.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/service_service.dart';
import '../../../core/services/review_service.dart';

class ProviderDetailScreen extends StatefulWidget {
  final String providerId;

  const ProviderDetailScreen({super.key, required this.providerId});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProviderService _providerService = ProviderService();
  final ServiceService _serviceService = ServiceService();
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: _providerService.getProviderStream(widget.providerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final provider = snapshot.data;
          if (provider == null) {
            return const Center(child: Text('Provider not found'));
          }

          final name = provider['name'] ?? 'Provider';
          final business = provider['businessName'] ?? '';
          final rating = (provider['rating'] ?? 0.0).toDouble();
          final reviewCount = (provider['reviewCount'] ?? 0) as int;
          final description = provider['description'] ?? '';
          final experience = provider['experience'] ?? '';
          final serviceArea = provider['serviceArea'] ?? '';

          return CustomScrollView(
            slivers: [
              // App Bar with provider image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white24,
                            child: ClipOval(
                              child: _buildProfileImage(provider['profileImage'] ?? ''),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(business, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Stats Row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Row(
                    children: [
                      _buildStat(Icons.star, '$rating', 'Rating'),
                      _buildStat(Icons.reviews, '$reviewCount', 'Reviews'),
                      _buildStat(Icons.work_history, experience, 'Exp.'),
                      _buildStat(Icons.location_on, serviceArea.isNotEmpty ? serviceArea : 'Local', 'Area'),
                    ],
                  ),
                ),
              ),
              // Tabs
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'About'),
                    Tab(text: 'Services'),
                    Tab(text: 'Reviews'),
                  ],
                ),
              ),
              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // About Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.paddingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(description.isNotEmpty ? description : 'No description provided.', style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                        ],
                      ),
                    ),
                    // Services Tab — real-time
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _serviceService.getProviderServicesStream(widget.providerId),
                      builder: (context, snapshot) {
                        final services = snapshot.data ?? [];
                        if (services.isEmpty) {
                          return const Center(child: Text('No services listed', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          itemCount: services.length,
                          itemBuilder: (context, index) {
                            final service = services[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(service['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if ((service['description'] ?? '').isNotEmpty)
                                          Text(service['description'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    children: [
                                      Text('₹${((service['price'] ?? 0) as num).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pushNamed(context, AppRoutes.booking, arguments: {
                                          'providerId': widget.providerId,
                                          'serviceId': service['id'],
                                        }),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          minimumSize: Size.zero,
                                        ),
                                        child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Reviews Tab — real-time
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _reviewService.getProviderReviewsStream(widget.providerId),
                      builder: (context, snapshot) {
                        final reviews = snapshot.data ?? [];
                        if (reviews.isEmpty) {
                          return const Center(child: Text('No reviews yet', style: TextStyle(color: AppColors.textSecondary)));
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.paddingM),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(AppConstants.paddingM),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(radius: 16, backgroundColor: AppColors.primary, child: Icon(Icons.person, size: 18, color: Colors.white)),
                                      const SizedBox(width: 8),
                                      Text(review['userName'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      ...List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < (review['rating'] ?? 0).round() ? AppColors.warning : AppColors.textLight)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(review['comment'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.booking, arguments: {
              'providerId': widget.providerId,
              'serviceId': '',
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
            ),
            child: const Text('Book Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.white);
    }

    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('http')) {
      // Network image
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 50, color: Colors.white);
        },
      );
    } else {
      // Local file path
      try {
        final file = File(imageUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.person, size: 50, color: Colors.white);
            },
          );
        } else {
          return const Icon(Icons.person, size: 50, color: Colors.white);
        }
      } catch (e) {
        return const Icon(Icons.person, size: 50, color: Colors.white);
      }
    }
  }
}
