import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/provider_service.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isUploadingImage = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Choose Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _isUploadingImage = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await Future.delayed(const Duration(seconds: 1));
        
        await AuthService().updateUserProfile(
          uid: user.uid,
          data: {'profileImage': image.path},
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final authService = AuthService();
    final providerService = ProviderService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: providerService.getProviderStream(uid),
        builder: (context, snapshot) {
          final provider = snapshot.data ?? {};
          final name = provider['name'] ?? 'Provider';
          final email = provider['email'] ?? '';
          final profileImage = provider['profileImage'] as String?;
          final rating = (provider['rating'] ?? 0.0).toDouble();
          final completedBookings = (provider['completedBookings'] ?? 0) as int;
          final totalEarnings = ((provider['totalEarnings'] ?? 0) as num).toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: Column(
                    children: [
                      // Avatar with image upload
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white24,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (profileImage != null && profileImage.isNotEmpty
                                    ? FileImage(File(profileImage))
                                    : null),
                            child: (_selectedImage == null && (profileImage == null || profileImage.isEmpty))
                                ? const Icon(Icons.person, size: 50, color: Colors.white)
                                : null,
                          ),
                          if (_isUploadingImage)
                            Positioned.fill(
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingImage ? null : _pickAndUploadImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 14, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem('$rating', 'Rating'),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _buildStatItem('$completedBookings', 'Jobs'),
                          Container(width: 1, height: 30, color: Colors.white24),
                          _buildStatItem('₹${totalEarnings.toInt()}', 'Earned'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingL),
                // Menu Items
                // Switch to User Mode
                _buildMenuItem(context, Icons.swap_horiz, 'Switch to User Mode', () => Navigator.pushReplacementNamed(context, AppRoutes.userMain), isDestructive: false),
                _buildDivider(),
                _buildMenuItem(context, Icons.edit, 'Edit Profile', () => Navigator.pushNamed(context, AppRoutes.editProfile)),
                _buildMenuItem(context, Icons.list_alt, 'My Services', () => Navigator.pushNamed(context, AppRoutes.providerServices)),
                _buildMenuItem(context, Icons.calendar_today, 'My Bookings', () => Navigator.pushNamed(context, AppRoutes.providerBookings)),
                _buildMenuItem(context, Icons.access_time, 'Availability', () => Navigator.pushNamed(context, AppRoutes.availability)),
                _buildMenuItem(context, Icons.account_balance_wallet, 'Earnings', () => Navigator.pushNamed(context, AppRoutes.earnings)),
                _buildDivider(),
                _buildMenuItem(context, Icons.logout, 'Logout', () => _showLogoutDialog(context), isDestructive: true),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.primary),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.textPrimary)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
