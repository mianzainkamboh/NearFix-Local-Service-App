import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/services/review_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final BookingService _bookingService = BookingService();
  final ReviewService _reviewService = ReviewService();
  final ImagePicker _imagePicker = ImagePicker();
  
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _providerAppStatus;
  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      final data = await _authService.getUserData(user.uid);
      final appStatus = await _authService.getProviderApplicationStatus();
      if (mounted) {
        setState(() {
          _userData = data;
          _providerAppStatus = appStatus;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Show options dialog
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

      // Pick image
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

      // In a real app, you would upload to Firebase Storage here
      // For now, we'll just update the local state
      // TODO: Implement Firebase Storage upload
      
      final user = _authService.currentUser;
      if (user != null) {
        // Simulate upload delay
        await Future.delayed(const Duration(seconds: 1));
        
        // Update user profile with image path (in real app, this would be the download URL)
        await _authService.updateUserProfile(
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
          _loadUserData();
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

  void _handleApplyForProvider() async {
    // If already approved, navigate to provider registration
    if (_providerAppStatus == 'approved') {
      Navigator.pushNamed(context, AppRoutes.providerRegistration);
      return;
    }

    // If pending, show info
    if (_providerAppStatus == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your application is pending review. Please wait for admin approval.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Navigate to provider registration
    final result = await Navigator.pushNamed(context, AppRoutes.providerRegistration);
    
    // Reload data if application was submitted
    if (result == true) {
      _loadUserData();
    }
  }

  String _getProviderMenuTitle() {
    switch (_providerAppStatus) {
      case 'pending':
        return 'Provider Application (Pending)';
      case 'approved':
        return 'Set Up Provider Profile';
      case 'rejected':
        return 'Re-apply as Provider';
      default:
        return 'Apply to be a Provider';
    }
  }

  IconData _getProviderMenuIcon() {
    switch (_providerAppStatus) {
      case 'pending':
        return Icons.hourglass_top;
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.refresh;
      default:
        return Icons.work_outline;
    }
  }

  Color _getProviderStatusColor() {
    switch (_providerAppStatus) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userName = _userData?['name'] ?? 'John Doe';
    final userEmail = _userData?['email'] ?? 'john.doe@email.com';
    final profileImage = _userData?['profileImage'] as String?;
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppConstants.radiusXL),
                    bottomRight: Radius.circular(AppConstants.radiusXL),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppConstants.paddingM),
                    // Avatar with real-time image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
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
                              radius: 50,
                              backgroundColor: Colors.black.withValues(alpha: 0.5),
                              child: const CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploadingImage ? null : _pickAndUploadImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppConstants.paddingM),
                    // Real-time Stats Row
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _bookingService.getUserBookingsStream(currentUid),
                      builder: (context, bookingSnapshot) {
                        final bookings = bookingSnapshot.data ?? [];
                        final totalBookings = bookings.length;
                        final completedBookings = bookings.where((b) => b['status'] == 'completed').length;

                        return StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _reviewService.getAllReviewsStream(),
                          builder: (context, reviewSnapshot) {
                            final allReviews = reviewSnapshot.data ?? [];
                            final userReviews = allReviews.where((r) => r['userId'] == currentUid).length;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem('$totalBookings', 'Bookings'),
                                Container(height: 40, width: 1, color: AppColors.textLight.withValues(alpha: 0.3)),
                                _buildStatItem('$completedBookings', 'Completed'),
                                Container(height: 40, width: 1, color: AppColors.textLight.withValues(alpha: 0.3)),
                                _buildStatItem('$userReviews', 'Reviews'),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              // Menu Items
              // Role Switcher (only show if user is approved provider)
              if (_userData?['isApprovedProvider'] == true) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                  child: _buildMenuItem(
                    context,
                    Icons.swap_horiz,
                    'Switch to Provider Mode',
                    () => Navigator.pushReplacementNamed(context, AppRoutes.providerMain),
                    iconColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppConstants.paddingM),
              ],
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(context, Icons.person_outline, 'Edit Profile', () => Navigator.pushNamed(context, AppRoutes.editProfile)),
                    _buildDivider(),
                    // Apply to be a Provider
                    _buildMenuItem(
                      context,
                      _getProviderMenuIcon(),
                      _getProviderMenuTitle(),
                      _handleApplyForProvider,
                      iconColor: _getProviderStatusColor(),
                    ),
                    _buildDivider(),
                    _buildMenuItem(context, Icons.notifications_outlined, 'Notifications', () => Navigator.pushNamed(context, AppRoutes.notifications)),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(context, Icons.help_outline, 'Help & Support', () => Navigator.pushNamed(context, AppRoutes.helpSupport)),
                    _buildDivider(),
                    _buildMenuItem(context, Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.pushNamed(context, AppRoutes.privacyPolicy)),
                    _buildDivider(),
                    _buildMenuItem(context, Icons.description_outlined, 'Terms of Service', () => Navigator.pushNamed(context, AppRoutes.termsOfService)),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: _buildMenuItem(
                  context,
                  Icons.logout,
                  'Logout',
                  () => _showLogoutDialog(context),
                  isDestructive: true,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              Text(
                'Version ${AppConstants.appVersion}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppConstants.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isDestructive = false, Color? iconColor}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : (iconColor ?? AppColors.textPrimary)),
      title: Text(title, style: TextStyle(color: isDestructive ? AppColors.error : AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDestructive ? AppColors.error : AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, indent: 56, color: AppColors.textLight.withValues(alpha: 0.3));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Sign out from Firebase
              await _authService.signOut();
              // Navigate to login and clear all previous routes
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
