import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/category_card.dart';
import '../../../shared/widgets/provider_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final CategoryService _categoryService = CategoryService();
  final ProviderService _providerService = ProviderService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  String _userName = 'User';

  // Icon map for categories
  static const Map<String, IconData> _iconMap = {
    'electrical_services': Icons.electrical_services,
    'plumbing': Icons.plumbing,
    'cleaning_services': Icons.cleaning_services,
    'carpenter': Icons.carpenter,
    'build': Icons.build,
    'format_paint': Icons.format_paint,
    'school': Icons.school,
    'more_horiz': Icons.more_horiz,
    'home_repair_service': Icons.home_repair_service,
    'local_laundry_service': Icons.local_laundry_service,
    'content_cut': Icons.content_cut,
    'computer': Icons.computer,
    'directions_car': Icons.directions_car,
    'restaurant': Icons.restaurant,
    'fitness_center': Icons.fitness_center,
    'camera_alt': Icons.camera_alt,
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (mounted && userData != null) {
        setState(() => _userName = userData['name'] ?? 'User');
      }
    }
  }

  IconData _getIconData(String iconName) {
    return _iconMap[iconName] ?? Icons.miscellaneous_services;
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
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
                              'Hello, $_userName! 👋',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Find Your Service',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            // Real-time notification badge
                            StreamBuilder<int>(
                              stream: _notificationService.getUnreadCountStream(currentUid),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                return _buildIconButton(
                                  Icons.notifications_outlined,
                                  () => Navigator.pushNamed(context, AppRoutes.notifications),
                                  badge: count,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.userProfile),
                              child: const CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingL),
                    // Search Bar
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingM,
                          vertical: AppConstants.paddingM,
                        ),
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
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Text(
                              'Search for services...',
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Categories Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            // Categories Grid — REAL-TIME from Firebase
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _categoryService.getCategoriesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )),
                  );
                }
                final categories = snapshot.data ?? [];
                if (categories.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No categories available', style: TextStyle(color: AppColors.textSecondary))),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return CategoryCard(
                          name: category['name'] ?? '',
                          icon: _getIconData(category['icon'] ?? ''),
                          color: AppColors.categoryColors[index % AppColors.categoryColors.length],
                          isCompact: true,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.categoryServices,
                            arguments: {
                              'categoryId': category['id'],
                              'categoryName': category['name'],
                            },
                          ),
                        );
                      },
                      childCount: categories.length,
                    ),
                  ),
                );
              },
            ),
            // Top Providers Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Top Rated Providers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
            ),
            // Providers List — REAL-TIME from Firebase
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _providerService.getTopProvidersStream(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )),
                  );
                }
                final providers = snapshot.data ?? [];
                if (providers.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: Text('No providers available yet', style: TextStyle(color: AppColors.textSecondary))),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final provider = providers[index];
                        return ProviderCard(
                          name: provider['name'] ?? 'Provider',
                          service: provider['businessName'] ?? '',
                          imageUrl: provider['profileImage'] ?? '',
                          rating: (provider['rating'] ?? 0.0).toDouble(),
                          reviewCount: (provider['reviewCount'] ?? 0) as int,
                          price: (provider['totalEarnings'] ?? 0.0).toDouble(),
                          experience: provider['experience'] ?? '',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.providerDetail,
                            arguments: {'providerId': provider['uid']},
                          ),
                          onBookNow: () => Navigator.pushNamed(
                            context,
                            AppRoutes.serviceSelection,
                            arguments: {
                              'providerId': provider['uid'],
                              'providerName': provider['name'] ?? 'Provider',
                            },
                          ),
                        );
                      },
                      childCount: providers.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
