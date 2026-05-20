import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Refresh the streams
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.paddingM),
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your platform',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppConstants.paddingL),
                
                // Real-time Statistics
                StreamBuilder(
                  stream: _database.child('users').onValue,
                  builder: (context, AsyncSnapshot<DatabaseEvent> usersSnapshot) {
                    int totalUsers = 0;
                    int totalProviders = 0;
                    
                    if (usersSnapshot.hasData && usersSnapshot.data!.snapshot.value != null) {
                      final usersData = Map<String, dynamic>.from(
                        usersSnapshot.data!.snapshot.value as Map
                      );
                      totalUsers = usersData.length;
                      
                      // Count users with provider role
                      usersData.forEach((key, value) {
                        final userData = Map<String, dynamic>.from(value as Map);
                        final roles = List<String>.from(userData['roles'] ?? ['user']);
                        if (roles.contains('provider')) {
                          totalProviders++;
                        }
                      });
                    }

                    return StreamBuilder(
                      stream: _database.child('providers').onValue,
                      builder: (context, AsyncSnapshot<DatabaseEvent> appsSnapshot) {
                        int pendingApplications = 0;
                        
                        if (appsSnapshot.hasData && appsSnapshot.data!.snapshot.value != null) {
                          final appsData = Map<String, dynamic>.from(
                            appsSnapshot.data!.snapshot.value as Map
                          );
                          
                          appsData.forEach((key, value) {
                            final appData = Map<String, dynamic>.from(value as Map);
                            if (appData['status'] == 'pending') {
                              pendingApplications++;
                            }
                          });
                        }

                        return StreamBuilder(
                          stream: _database.child('bookings').onValue,
                          builder: (context, AsyncSnapshot<DatabaseEvent> bookingsSnapshot) {
                            int totalBookings = 0;
                            
                            if (bookingsSnapshot.hasData && 
                                bookingsSnapshot.data!.snapshot.value != null) {
                              final bookingsData = Map<String, dynamic>.from(
                                bookingsSnapshot.data!.snapshot.value as Map
                              );
                              totalBookings = bookingsData.length;
                            }

                            return Column(
                              children: [
                                // Statistics Cards
                                Row(
                                  children: [
                                    _buildStatCard(
                                      'Total Users',
                                      '$totalUsers',
                                      Icons.people,
                                      AppColors.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      'Providers',
                                      '$totalProviders',
                                      Icons.engineering,
                                      AppColors.info,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildStatCard(
                                      'Bookings',
                                      '$totalBookings',
                                      Icons.calendar_today,
                                      AppColors.success,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildStatCard(
                                      'Pending Apps',
                                      '$pendingApplications',
                                      Icons.pending_actions,
                                      AppColors.warning,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppConstants.paddingL),
                                
                                // Quick Actions Header
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Quick Actions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                
                                // Action Cards
                                Row(
                                  children: [
                                    _buildActionCard(
                                      context,
                                      Icons.person_add,
                                      'Pending\nApprovals',
                                      AppColors.warning,
                                      '$pendingApplications',
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.providerApplications,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildActionCard(
                                      context,
                                      Icons.category,
                                      'Manage\nCategories',
                                      AppColors.info,
                                      '',
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.manageCategories,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildActionCard(
                                      context,
                                      Icons.people,
                                      'Manage\nUsers',
                                      AppColors.primary,
                                      '',
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.manageUsers,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildActionCard(
                                      context,
                                      Icons.list_alt,
                                      'All\nBookings',
                                      AppColors.success,
                                      '',
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.allBookings,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildActionCard(
                                      context,
                                      Icons.rate_review,
                                      'Provider\nReviews',
                                      AppColors.warning,
                                      '',
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.reviews,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildActionCard(
                                      context,
                                      Icons.feedback,
                                      'User\nFeedback',
                                      AppColors.info,
                                      '',
                                      () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.feedback,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, Color color, String badge, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await AuthService().signOut();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging out: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
