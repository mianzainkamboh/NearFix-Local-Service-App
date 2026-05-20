import 'package:flutter/material.dart';

// Splash & Auth
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';

// User Screens
import '../../features/user/screens/user_main_screen.dart';
import '../../features/user/screens/user_home_screen.dart';
import '../../features/user/screens/category_services_screen.dart';
import '../../features/user/screens/provider_detail_screen.dart';
import '../../features/user/screens/booking_screen.dart';
import '../../features/user/screens/booking_confirmation_screen.dart';
import '../../features/user/screens/user_bookings_screen.dart';
import '../../features/user/screens/booking_detail_screen.dart';
import '../../features/user/screens/search_screen.dart';
import '../../features/user/screens/user_profile_screen.dart';
import '../../features/user/screens/edit_profile_screen.dart';
import '../../features/user/screens/notifications_screen.dart';
import '../../features/user/screens/review_screen.dart';
import '../../features/user/screens/service_selection_screen.dart';
import '../../features/user/screens/fcm_token_screen.dart';
import '../../features/user/screens/terms_of_service_screen.dart';
import '../../features/user/screens/privacy_policy_screen.dart';
import '../../features/user/screens/help_support_screen.dart';
import '../../features/user/screens/submit_feedback_screen.dart';

// Provider Screens
import '../../features/provider/screens/provider_main_screen.dart';
import '../../features/provider/screens/provider_registration_screen.dart';
import '../../features/provider/screens/provider_home_screen.dart';
import '../../features/provider/screens/provider_bookings_screen.dart';
import '../../features/provider/screens/provider_services_screen.dart';
import '../../features/provider/screens/add_service_screen.dart';
import '../../features/provider/screens/availability_screen.dart';
import '../../features/provider/screens/provider_profile_screen.dart';
import '../../features/provider/screens/earnings_screen.dart';

// Admin Screens
import '../../features/admin/screens/admin_main_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/manage_users_screen.dart';
import '../../features/admin/screens/manage_providers_screen.dart';
import '../../features/admin/screens/provider_applications_screen.dart';
import '../../features/admin/screens/provider_approval_screen.dart';
import '../../features/admin/screens/manage_categories_screen.dart';
import '../../features/admin/screens/add_category_screen.dart';
import '../../features/admin/screens/all_bookings_screen.dart';
import '../../features/admin/screens/feedback_screen.dart';
import '../../features/admin/screens/reviews_screen.dart';

class AppRoutes {
  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';
  
  // User Routes
  static const String userMain = '/user';
  static const String userHome = '/user/home';
  static const String categoryServices = '/user/category-services';
  static const String providerDetail = '/user/provider-detail';
  static const String booking = '/user/booking';
  static const String bookingConfirmation = '/user/booking-confirmation';
  static const String userBookings = '/user/bookings';
  static const String bookingDetail = '/user/booking-detail';
  static const String search = '/user/search';
  static const String userProfile = '/user/profile';
  static const String editProfile = '/user/edit-profile';
  static const String notifications = '/user/notifications';
  static const String review = '/user/review';
  static const String serviceSelection = '/user/service-selection';
  static const String fcmToken = '/user/fcm-token';
  static const String termsOfService = '/terms-of-service';
  static const String privacyPolicy = '/privacy-policy';
  static const String helpSupport = '/help-support';
  static const String submitFeedback = '/submit-feedback';
  
  // Provider Routes
  static const String providerMain = '/provider';
  static const String providerRegistration = '/provider/registration';
  static const String providerHome = '/provider/home';
  static const String providerBookings = '/provider/bookings';
  static const String providerServices = '/provider/services';
  static const String addService = '/provider/add-service';
  static const String availability = '/provider/availability';
  static const String providerProfile = '/provider/profile';
  static const String earnings = '/provider/earnings';
  
  // Admin Routes
  static const String adminMain = '/admin';
  static const String adminDashboard = '/admin/dashboard';
  static const String manageUsers = '/admin/users';
  static const String manageProviders = '/admin/providers';
  static const String providerApplications = '/admin/provider-applications';
  static const String providerApproval = '/admin/provider-approval';
  static const String manageCategories = '/admin/categories';
  static const String addCategory = '/admin/add-category';
  static const String allBookings = '/admin/bookings';
  static const String feedback = '/admin/feedback';
  static const String reviews = '/admin/reviews';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash & Onboarding
      case splash:
        return _buildRoute(const SplashScreen());
      case onboarding:
        return _buildRoute(const OnboardingScreen());
      
      // Auth
      case login:
        return _buildRoute(const LoginScreen());
      case register:
        return _buildRoute(const RegisterScreen());
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen());
      case otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(OtpVerificationScreen(
          email: args?['email'] ?? '',
          isPasswordReset: args?['isPasswordReset'] ?? false,
        ));
      case roleSelection:
        return _buildRoute(const RoleSelectionScreen());
      
      // User
      case userMain:
        return _buildRoute(const UserMainScreen());
      case userHome:
        return _buildRoute(const UserHomeScreen());
      case categoryServices:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(CategoryServicesScreen(
          categoryId: args?['categoryId'] ?? '',
          categoryName: args?['categoryName'] ?? '',
        ));
      case providerDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(ProviderDetailScreen(providerId: args?['providerId'] ?? ''));
      case booking:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(BookingScreen(
          providerId: args?['providerId'] ?? '',
          serviceId: args?['serviceId'] ?? '',
        ));
      case bookingConfirmation:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(BookingConfirmationScreen(bookingId: args?['bookingId'] ?? ''));
      case userBookings:
        return _buildRoute(const UserBookingsScreen());
      case bookingDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(BookingDetailScreen(bookingId: args?['bookingId'] ?? ''));
      case search:
        return _buildRoute(const SearchScreen());
      case userProfile:
        return _buildRoute(const UserProfileScreen());
      case editProfile:
        return _buildRoute(const EditProfileScreen());
      case notifications:
        return _buildRoute(const NotificationsScreen());
      case review:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(ReviewScreen(
          bookingId: args?['bookingId'] ?? '',
          providerId: args?['providerId'] ?? '',
        ));
      case serviceSelection:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(ServiceSelectionScreen(
          providerId: args?['providerId'] ?? '',
          providerName: args?['providerName'] ?? 'Provider',
        ));
      case fcmToken:
        return _buildRoute(const FcmTokenScreen());
      case termsOfService:
        return _buildRoute(const TermsOfServiceScreen());
      case privacyPolicy:
        return _buildRoute(const PrivacyPolicyScreen());
      case helpSupport:
        return _buildRoute(const HelpSupportScreen());
      case submitFeedback:
        return _buildRoute(const SubmitFeedbackScreen());
      
      // Provider
      case providerMain:
        return _buildRoute(const ProviderMainScreen());
      case providerRegistration:
        return _buildRoute(const ProviderRegistrationScreen());
      case providerHome:
        return _buildRoute(const ProviderHomeScreen());
      case providerBookings:
        return _buildRoute(const ProviderBookingsScreen());
      case providerServices:
        return _buildRoute(const ProviderServicesScreen());
      case addService:
        return _buildRoute(const AddServiceScreen());
      case availability:
        return _buildRoute(const AvailabilityScreen());
      case providerProfile:
        return _buildRoute(const ProviderProfileScreen());
      case earnings:
        return _buildRoute(const EarningsScreen());
      
      // Admin
      case adminMain:
        return _buildRoute(const AdminMainScreen());
      case adminDashboard:
        return _buildRoute(const AdminDashboardScreen());
      case manageUsers:
        return _buildRoute(const ManageUsersScreen());
      case manageProviders:
        return _buildRoute(const ManageProvidersScreen());
      case providerApplications:
        return _buildRoute(const ProviderApplicationsScreen());
      case providerApproval:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(ProviderApprovalScreen(providerId: args?['providerId'] ?? ''));
      case manageCategories:
        return _buildRoute(const ManageCategoriesScreen());
      case addCategory:
        return _buildRoute(const AddCategoryScreen());
      case allBookings:
        return _buildRoute(const AllBookingsScreen());
      case feedback:
        return _buildRoute(const FeedbackScreen());
      case reviews:
        return _buildRoute(const ReviewsScreen());
      
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
