import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingXL),
              // Header
              const Icon(
                Icons.handyman_rounded,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppConstants.paddingM),
              const Text(
                'Welcome to Nearfix',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              const Text(
                'How would you like to use the app?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingXXL),
              // Role Cards
              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      icon: Icons.person_outline,
                      title: 'I need services',
                      subtitle: 'Find and book local service providers',
                      color: AppColors.primary,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.login,
                        arguments: {'role': AppConstants.roleUser},
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    _RoleCard(
                      icon: Icons.work_outline,
                      title: 'I provide services',
                      subtitle: 'Offer your skills and grow your business',
                      color: AppColors.secondary,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.login,
                        arguments: {'role': AppConstants.roleProvider},
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    _RoleCard(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Access',
                      subtitle: 'Manage platform and users',
                      color: AppColors.warning,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.login,
                        arguments: {'role': AppConstants.roleAdmin},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
