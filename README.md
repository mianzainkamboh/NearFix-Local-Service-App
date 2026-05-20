# NearFix - Local Service Booking Platform

![Flutter](https://img.shields.io/badge/Flutter-3.10.4-blue)
![Firebase](https://img.shields.io/badge/Firebase-Realtime%20Database-orange)
![License](https://img.shields.io/badge/License-Private-red)

## 📱 About NearFix

NearFix is a comprehensive mobile application that connects users with local service providers. Whether you need a plumber, electrician, cleaner, or any other service professional, NearFix makes it easy to find, book, and manage services in your area.

### 🎯 Key Features

- **Multi-Role System**: Users, Service Providers, and Admins
- **Real-time Notifications**: Push notifications with sound for booking updates
- **Secure Authentication**: Email/Password and Google Sign-In
- **Service Management**: Browse, search, and book services
- **Rating & Reviews**: Rate and review service providers
- **Booking Management**: Track booking status in real-time
- **Admin Dashboard**: Complete platform management tools

---

## 🏗️ Project Architecture

### Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
  - Firebase Authentication
  - Firebase Realtime Database
  - Firebase Cloud Messaging (FCM)
  - Firebase Storage
- **State Management**: StatefulWidget with StreamBuilder
- **Navigation**: Named Routes

### Project Structure

```
nearfix/
├── lib/
│   ├── core/                      # Core functionality
│   │   ├── constants/             # App-wide constants
│   │   ├── routes/                # Navigation routes
│   │   ├── services/              # Business logic services
│   │   ├── theme/                 # App theme and colors
│   │   └── utils/                 # Utility functions
│   │
│   ├── features/                  # Feature modules
│   │   ├── auth/                  # Authentication
│   │   ├── user/                  # User features
│   │   ├── provider/              # Provider features
│   │   ├── admin/                 # Admin features
│   │   ├── splash/                # Splash screen
│   │   └── onboarding/            # Onboarding screens
│   │
│   ├── shared/                    # Shared components
│   │   └── widgets/               # Reusable widgets
│   │
│   └── main.dart                  # App entry point
│
├── android/                       # Android configuration
├── ios/                          # iOS configuration (if applicable)
└── pubspec.yaml                  # Dependencies
```

---

## 👥 User Roles & Features

### 1. 👤 Regular Users

**What Users Can Do:**
- Browse service categories (Plumbing, Electrical, Cleaning, etc.)
- Search for service providers by name or service
- View provider profiles with ratings and reviews
- Book services with date and time selection
- Track booking status (Pending → Accepted → Completed)
- Cancel bookings
- Rate and review completed services
- Manage profile with password verification
- Receive real-time push notifications
- View booking history
- Submit feedback to admin
- Access Help & Support, Terms of Service, Privacy Policy

**User Journey:**
1. Register/Login → Browse Categories → Select Provider → Choose Service → Book Appointment → Track Status → Complete & Review

### 2. 🔧 Service Providers

**What Providers Can Do:**
- Register as a service provider (requires admin approval)
- Create and manage service listings
- Set service prices and descriptions
- Manage availability schedule (working days and hours)
- Accept or reject booking requests
- Mark bookings as completed
- View earnings and booking history
- Manage profile and services
- Receive notifications for new bookings

**Provider Journey:**
1. Apply as Provider → Wait for Admin Approval → Add Services → Set Availability → Receive Bookings → Accept/Reject → Complete Service → Earn Money

### 3. 👨‍💼 Administrators

**What Admins Can Do:**
- View comprehensive dashboard with statistics
- Manage all users (activate/deactivate accounts)
- Approve or reject provider applications
- Manage service categories (add/edit/delete)
- View all bookings across the platform
- Monitor provider reviews
- Read and manage user feedback
- Search and filter users
- Logout securely

**Admin Dashboard Features:**
- Total Users count
- Total Providers count
- Total Bookings count
- Pending Applications count
- Quick action cards for all management tasks

---

## 🔐 Authentication System

### Supported Methods
1. **Email & Password**
   - Registration with email verification
   - Login with credentials
   - Password reset via email
   - OTP verification

2. **Google Sign-In**
   - One-tap Google authentication
   - Automatic profile creation

### Security Features
- Password verification for profile changes
- Firebase Authentication security rules
- Secure token management
- Session management

---

## 📊 Database Structure

### Firebase Realtime Database Schema

```
nearfix-database/
├── users/
│   └── {userId}/
│       ├── name
│       ├── email
│       ├── phone
│       ├── profileImage
│       ├── roles: ["user", "provider", "admin"]
│       ├── isActive
│       └── createdAt
│
├── providers/
│   └── {providerId}/
│       ├── userId
│       ├── businessName
│       ├── description
│       ├── categoryId
│       ├── experience
│       ├── certifications
│       ├── status: "pending" | "approved" | "rejected"
│       └── createdAt
│
├── services/
│   └── {serviceId}/
│       ├── providerId
│       ├── name
│       ├── description
│       ├── price
│       ├── duration
│       ├── categoryId
│       └── isActive
│
├── bookings/
│   └── {bookingId}/
│       ├── userId
│       ├── providerId
│       ├── serviceId
│       ├── date
│       ├── time
│       ├── status: "pending" | "accepted" | "completed" | "cancelled"
│       ├── totalAmount
│       └── createdAt
│
├── reviews/
│   └── {reviewId}/
│       ├── userId
│       ├── providerId
│       ├── bookingId
│       ├── rating (1-5)
│       ├── comment
│       └── createdAt
│
├── categories/
│   └── {categoryId}/
│       ├── name
│       ├── description
│       ├── icon
│       └── isActive
│
├── notifications/
│   └── {userId}/
│       └── {notificationId}/
│           ├── title
│           ├── message
│           ├── type
│           ├── isRead
│           └── createdAt
│
├── feedback/
│   └── {feedbackId}/
│       ├── userId
│       ├── userName
│       ├── userEmail
│       ├── category
│       ├── subject
│       ├── message
│       ├── rating
│       ├── status: "pending" | "reviewed" | "resolved"
│       └── createdAt
│
└── availability/
    └── {providerId}/
        ├── workingDays: ["Monday", "Tuesday", ...]
        ├── startTime
        └── endTime
```

---

## 🔔 Notification System

### Push Notifications (Firebase Cloud Messaging)

**How It Works:**
1. App initializes FCM on startup
2. User receives FCM token
3. Token stored in Firebase (for future backend integration)
4. Notifications sent from Firebase Console or backend server
5. Notifications appear in system tray with sound

**Notification Types:**
- New booking received (for providers)
- Booking accepted/rejected (for users)
- Booking completed (for users)
- Provider application status (for providers)
- General announcements (for all users)

**Important Note:** 
Push notifications with sound require sending from Firebase Console or a backend server. The app cannot send push notifications to itself due to FCM security features.

### In-App Notifications
- Real-time database notifications
- Notification badge on bell icon
- Notification list screen
- Mark as read functionality

---

## 🎨 UI/UX Features

### Design System
- **Color Scheme**: Modern purple primary color (#4F46E5)
- **Typography**: Clean, readable fonts
- **Components**: Reusable custom widgets
- **Responsive**: Adapts to different screen sizes
- **Animations**: Smooth transitions and interactions

### Key Screens

#### User Screens (20+)
- Splash & Onboarding
- Login & Registration
- Home with Categories
- Search & Filter
- Provider Details
- Service Selection
- Booking Flow
- Booking History
- Notifications
- Profile Management
- Reviews
- Help & Support
- Terms & Privacy

#### Provider Screens (10+)
- Provider Registration
- Dashboard
- Service Management
- Booking Management
- Availability Settings
- Earnings Tracker
- Profile Management

#### Admin Screens (10+)
- Admin Dashboard
- User Management (with search)
- Provider Management
- Provider Approvals
- Category Management
- Booking Overview
- Reviews Management
- Feedback Management

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase Account
- Android/iOS Device or Emulator

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd nearfix
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android app to Firebase project
   - Download `google-services.json`
   - Place it in `android/app/`
   - Enable Authentication (Email/Password & Google)
   - Enable Realtime Database
   - Enable Cloud Messaging
   - Enable Storage

4. **Configure Firebase**
   - Update `android/app/build.gradle.kts` with your package name
   - Update Firebase configuration files

5. **Run the App**
   ```bash
   flutter run
   ```

### First Time Setup

1. **Create Admin Account**
   - Register a new account
   - Manually add "admin" to roles in Firebase Database:
     ```json
     users/{userId}/roles: ["user", "admin"]
     ```

2. **Add Categories**
   - Login as admin
   - Navigate to Manage Categories
   - Add service categories (Plumbing, Electrical, etc.)

3. **Test the Flow**
   - Register as a regular user
   - Apply to become a provider
   - Login as admin and approve the provider
   - Add services as provider
   - Book a service as user

---

## 📦 Dependencies

### Main Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.4
  firebase_database: ^11.3.5
  firebase_storage: ^12.3.8
  firebase_messaging: ^15.1.8
  
  # Authentication
  google_sign_in: ^6.2.1
  
  # Utilities
  url_launcher: ^6.3.1
  image_picker: ^1.1.2
  intl: ^0.19.0
  
  # UI
  cupertino_icons: ^1.0.8
```

---

## 🔧 Configuration Files

### Important Files to Configure

1. **android/app/google-services.json**
   - Firebase configuration for Android

2. **android/app/src/main/AndroidManifest.xml**
   - App permissions
   - FCM configuration
   - Notification channels

3. **database.rules.json**
   - Firebase Realtime Database security rules

4. **firebase.json**
   - Firebase project configuration

---

## 🎯 Key Features Explained

### 1. Booking System
**Flow:**
```
User selects service → Chooses date/time → Confirms booking → 
Provider receives notification → Provider accepts → 
Service completed → User reviews → Payment processed
```

**Status Lifecycle:**
- `pending`: Waiting for provider response
- `accepted`: Provider confirmed the booking
- `completed`: Service finished
- `cancelled`: Booking cancelled by user/provider

### 2. Provider Approval System
**Flow:**
```
User applies as provider → Fills application form → 
Admin reviews application → Admin approves/rejects → 
Provider receives notification → Provider can add services
```

### 3. Rating & Review System
- Users can only review completed bookings
- 5-star rating system
- Optional text comment
- Reviews visible on provider profiles
- Admin can moderate reviews

### 4. Search & Filter
- Search by provider name
- Search by service name
- Filter by category
- Filter by rating
- Real-time search results

### 5. Profile Management
- Edit name, phone, address
- Upload profile picture
- Password verification required for changes
- View booking history
- Manage account settings

---

## 🔒 Security Features

### Authentication Security
- Firebase Authentication rules
- Password strength validation
- Email verification
- Secure token management

### Database Security
- Role-based access control
- User can only edit own data
- Admin has full access
- Provider can only edit own services

### Data Validation
- Input validation on all forms
- Server-side validation via Firebase rules
- XSS protection
- SQL injection prevention (NoSQL database)

---

## 📱 Supported Platforms

- ✅ Android (Tested)
- ⚠️ iOS (Not tested, may require additional configuration)
- ❌ Web (Not configured)
- ❌ Desktop (Not configured)

---

## 🐛 Known Issues & Limitations

1. **Push Notifications**: Require backend server or Firebase Console to send (app cannot self-send)
2. **Image Upload**: Limited to local storage and Firebase Storage
3. **Payment Integration**: Not implemented (placeholder for future)
4. **Real-time Chat**: Not implemented
5. **Location Services**: Not implemented (manual address entry)
6. **Multi-language**: Not supported (English only)

---

## 🔮 Future Enhancements

### Planned Features
- [ ] Payment gateway integration (Stripe, PayPal, Razorpay)
- [ ] Real-time chat between users and providers
- [ ] Location-based provider search (GPS)
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Provider analytics dashboard
- [ ] Promotional codes and discounts
- [ ] Subscription plans for providers
- [ ] Advanced search filters
- [ ] Service packages
- [ ] Recurring bookings
- [ ] Provider verification badges
- [ ] In-app wallet system
- [ ] Referral program
- [ ] Social media integration

### Technical Improvements
- [ ] Backend API (Node.js/Express)
- [ ] State management (Provider/Riverpod/Bloc)
- [ ] Unit and integration tests
- [ ] CI/CD pipeline
- [ ] Performance optimization
- [ ] Offline mode support
- [ ] App analytics (Firebase Analytics)
- [ ] Crash reporting (Firebase Crashlytics)

---

## 📞 Support & Contact

### Help & Support
- In-app Help & Support section
- Email: nearfixx@gmail.com
- Phone: +92 1234567890
- WhatsApp: +92 1234567890

### Feedback
Users can submit feedback directly through the app:
- Navigate to Profile → Help & Support → Send Feedback
- Admins can view and manage feedback in the admin panel

---

## 📄 Legal

### Terms of Service
Complete terms of service available in-app at:
Profile → Help & Support → Terms of Service

### Privacy Policy
Complete privacy policy available in-app at:
Profile → Help & Support → Privacy Policy

**Key Points:**
- We collect minimal personal information
- Data stored securely in Firebase
- No data sold to third parties
- Users can request data deletion
- GDPR compliant (with proper configuration)

---

## 🤝 Contributing

This is a private project. For contributions or inquiries, please contact the project owner.

---

## 📊 Project Statistics

- **Total Screens**: 50+
- **Total Services**: 10+
- **Total Widgets**: 20+
- **Lines of Code**: ~15,000+
- **Development Time**: Multiple months
- **Flutter Version**: 3.10.4
- **Minimum Android SDK**: 21 (Android 5.0)

---

## 🎓 Learning Resources

If you're new to Flutter or Firebase, here are some helpful resources:

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)

---

## 📝 Version History

### Version 1.0.0 (Current)
- Initial release
- Multi-role system (User, Provider, Admin)
- Complete booking system
- Push notifications
- Rating & reviews
- Admin dashboard
- User feedback system
- Search functionality
- Profile management with password verification

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend services
- All contributors and testers
- Open-source community

---

## 📧 Contact Information

**Project Name**: NearFix  
**Version**: 1.0.0  
**Last Updated**: 2026  
**Status**: Active Development  

---

**Made with ❤️ using Flutter**
#   N e a r F i x - L o c a l - S e r v i c e - A p p  
 