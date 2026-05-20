import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().year}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppConstants.paddingL),
            
            _buildSection(
              'Introduction',
              'NearFix ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            
            _buildSection(
              '1. Information We Collect',
              'Personal Information:\n'
              '• Name, email address, and phone number\n'
              '• Profile picture (optional)\n'
              '• Location data for service matching\n'
              '• Payment information (processed securely)\n\n'
              'Usage Information:\n'
              '• Booking history and preferences\n'
              '• App usage patterns and interactions\n'
              '• Device information and IP address\n'
              '• Push notification tokens',
            ),
            
            _buildSection(
              '2. How We Use Your Information',
              'We use your information to:\n'
              '• Provide and maintain our services\n'
              '• Process bookings and payments\n'
              '• Match you with appropriate service providers\n'
              '• Send notifications about bookings and updates\n'
              '• Improve our services and user experience\n'
              '• Communicate with you about your account\n'
              '• Prevent fraud and ensure platform security\n'
              '• Comply with legal obligations',
            ),
            
            _buildSection(
              '3. Information Sharing',
              'We share your information with:\n\n'
              'Service Providers:\n'
              '• Your name, phone number, and address are shared with providers you book\n'
              '• Booking details and service requirements\n\n'
              'Third-Party Services:\n'
              '• Firebase for authentication and database\n'
              '• Payment processors for transactions\n'
              '• Analytics services for app improvement\n\n'
              'We do NOT sell your personal information to third parties.',
            ),
            
            _buildSection(
              '4. Data Security',
              'We implement appropriate security measures to protect your information:\n'
              '• Encryption of data in transit and at rest\n'
              '• Secure authentication using Firebase\n'
              '• Regular security audits and updates\n'
              '• Access controls and monitoring\n\n'
              'However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
            ),
            
            _buildSection(
              '5. Your Rights and Choices',
              'You have the right to:\n'
              '• Access your personal information\n'
              '• Update or correct your information\n'
              '• Delete your account and data\n'
              '• Opt-out of marketing communications\n'
              '• Disable location services\n'
              '• Control push notification preferences\n\n'
              'To exercise these rights, contact us through the Help & Support section.',
            ),
            
            _buildSection(
              '6. Location Data',
              'We collect location data to:\n'
              '• Match you with nearby service providers\n'
              '• Provide accurate service estimates\n'
              '• Improve service recommendations\n\n'
              'You can disable location services in your device settings, but this may limit app functionality.',
            ),
            
            _buildSection(
              '7. Push Notifications',
              'We send push notifications for:\n'
              '• Booking confirmations and updates\n'
              '• Messages from service providers\n'
              '• Payment confirmations\n'
              '• Important account updates\n\n'
              'You can disable notifications in your device settings.',
            ),
            
            _buildSection(
              '8. Children\'s Privacy',
              'NearFix is not intended for users under 18 years of age. We do not knowingly collect information from children. If you believe we have collected information from a child, please contact us immediately.',
            ),
            
            _buildSection(
              '9. Data Retention',
              'We retain your information for as long as your account is active or as needed to provide services. When you delete your account, we will delete or anonymize your personal information within 30 days, except where required by law.',
            ),
            
            _buildSection(
              '10. Cookies and Tracking',
              'We use cookies and similar tracking technologies to:\n'
              '• Maintain your session\n'
              '• Remember your preferences\n'
              '• Analyze app usage\n'
              '• Improve user experience',
            ),
            
            _buildSection(
              '11. Third-Party Links',
              'Our app may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies.',
            ),
            
            _buildSection(
              '12. Changes to Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the app and updating the "Last updated" date. Your continued use after changes constitutes acceptance.',
            ),
            
            _buildSection(
              '13. International Data Transfers',
              'Your information may be transferred to and processed in countries other than your own. We ensure appropriate safeguards are in place to protect your information in accordance with this Privacy Policy.',
            ),
            
            _buildSection(
              '14. Contact Us',
              'If you have questions or concerns about this Privacy Policy or our data practices, please contact us through:\n'
              '• Help & Support section in the app\n'
              '• Email: support@nearfix.com\n'
              '• In-app feedback form',
            ),
            
            const SizedBox(height: AppConstants.paddingL),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.success),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your privacy is important to us. We are committed to protecting your personal information.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}