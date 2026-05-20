import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/custom_button.dart';
import 'dart:async';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isPasswordReset = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = AuthService();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;
  Timer? _timer;
  bool _isCheckingVerification = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    _startVerificationCheck();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _startVerificationCheck() {
    // Check email verification status every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted || _isCheckingVerification) {
        timer.cancel();
        return;
      }

      final isVerified = await _authService.checkEmailVerified();
      if (isVerified && mounted) {
        timer.cancel();
        await _authService.updateEmailVerificationStatus();
        _handleVerificationSuccess();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleVerificationSuccess() {
    if (widget.isPasswordReset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! You can now reset your password.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.popUntil(context, (route) => route.settings.name == AppRoutes.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.userMain);
    }
  }

  void _handleManualCheck() async {
    setState(() => _isCheckingVerification = true);

    final isVerified = await _authService.checkEmailVerified();

    if (mounted) {
      setState(() => _isCheckingVerification = false);

      if (isVerified) {
        await _authService.updateEmailVerificationStatus();
        _handleVerificationSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email not verified yet. Please check your inbox.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }

  void _handleResend() async {
    if (_canResend) {
      setState(() => _isLoading = true);

      final result = await _authService.sendEmailVerification();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _resendTimer = 60;
          _canResend = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: result['success'] ? AppColors.success : AppColors.error,
          ),
        );

        if (result['success']) {
          _startResendTimer();
        }
      }
    }
  }

  void _handleSkip() {
    // Sign out and go back to login
    _authService.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
      arguments: {'role': AppConstants.roleUser},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppConstants.paddingL),
              // Back button
              GestureDetector(
                onTap: _handleSkip,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: AppConstants.paddingXL),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Header
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppConstants.paddingS),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We have sent a verification link to '),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: '\n\nPlease check your inbox and click the verification link.'),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingXXL),
              // Info card
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Checking verification status automatically...',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.paddingXL),
              // Manual check button
              CustomButton(
                text: 'I\'ve Verified - Check Now',
                onPressed: _handleManualCheck,
                isLoading: _isCheckingVerification,
              ),
              const SizedBox(height: AppConstants.paddingM),
              // Resend button
              OutlinedButton(
                onPressed: _canResend && !_isLoading ? _handleResend : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: _canResend ? AppColors.primary : AppColors.textLight,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _canResend ? 'Resend Verification Email' : 'Resend in ${_resendTimer}s',
                        style: TextStyle(
                          fontSize: 16,
                          color: _canResend ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
              const SizedBox(height: AppConstants.paddingL),
              // Help text
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Didn't receive the email?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Check your spam folder or resend',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
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
