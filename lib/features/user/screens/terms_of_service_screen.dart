import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using NearFix, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms of Service, please do not use our services.',
            ),
            
            _buildSection(
              '2. Description of Service',
              'NearFix is a platform that connects users with local service providers. We facilitate bookings for various home services including plumbing, electrical work, cleaning, carpentry, and more. NearFix acts as an intermediary and is not directly responsible for the services provided by third-party service providers.',
            ),
            
            _buildSection(
              '3. User Accounts',
              '• You must be at least 18 years old to use NearFix\n'
              '• You are responsible for maintaining the confidentiality of your account\n'
              '• You agree to provide accurate and complete information\n'
              '• You are responsible for all activities under your account\n'
              '• You must notify us immediately of any unauthorized use',
            ),
            
            _buildSection(
              '4. Service Provider Terms',
              '• Service providers must be qualified and licensed where required\n'
              '• Providers are independent contractors, not employees of NearFix\n'
              '• Providers must maintain appropriate insurance\n'
              '• Providers agree to complete bookings professionally and on time\n'
              '• NearFix reserves the right to remove providers who violate terms',
            ),
            
            _buildSection(
              '5. Bookings and Payments',
              '• All bookings are subject to provider availability\n'
              '• Payment terms are agreed upon between users and providers\n'
              '• Cancellation policies apply as specified in the booking\n'
              '• Users agree to pay for services rendered\n'
              '• Disputes should be resolved directly with the service provider',
            ),
            
            _buildSection(
              '6. User Conduct',
              'You agree not to:\n'
              '• Use the service for any illegal purpose\n'
              '• Harass, abuse, or harm other users or providers\n'
              '• Post false or misleading information\n'
              '• Attempt to gain unauthorized access to the platform\n'
              '• Interfere with the proper functioning of the service',
            ),
            
            _buildSection(
              '7. Intellectual Property',
              'All content, features, and functionality of NearFix are owned by us and are protected by copyright, trademark, and other intellectual property laws. You may not copy, modify, or distribute any part of our service without permission.',
            ),
            
            _buildSection(
              '8. Limitation of Liability',
              'NearFix is not liable for:\n'
              '• Quality of services provided by third-party providers\n'
              '• Damages or injuries resulting from service provision\n'
              '• Loss of data or service interruptions\n'
              '• Indirect, incidental, or consequential damages\n'
              '• Actions or omissions of service providers',
            ),
            
            _buildSection(
              '9. Indemnification',
              'You agree to indemnify and hold NearFix harmless from any claims, damages, losses, or expenses arising from your use of the service, violation of these terms, or infringement of any rights of another party.',
            ),
            
            _buildSection(
              '10. Modifications to Service',
              'We reserve the right to modify or discontinue the service at any time without notice. We shall not be liable to you or any third party for any modification, suspension, or discontinuance of the service.',
            ),
            
            _buildSection(
              '11. Termination',
              'We may terminate or suspend your account and access to the service immediately, without prior notice, for any reason, including breach of these Terms of Service.',
            ),
            
            _buildSection(
              '12. Governing Law',
              'These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.',
            ),
            
            _buildSection(
              '13. Changes to Terms',
              'We reserve the right to update these Terms of Service at any time. We will notify users of any material changes. Your continued use of the service after changes constitutes acceptance of the new terms.',
            ),
            
            _buildSection(
              '14. Contact Information',
              'If you have any questions about these Terms of Service, please contact us through the Help & Support section in the app.',
            ),
            
            const SizedBox(height: AppConstants.paddingL),
            
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'By using NearFix, you acknowledge that you have read and understood these Terms of Service.',
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