import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<Map<String, dynamic>> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create user
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Update display name
      await credential.user?.updateDisplayName(name.trim());

      // Send email verification
      await credential.user?.sendEmailVerification();

      // Store user data in Realtime Database with roles array
      await _database.child('users').child(credential.user!.uid).set({
        'uid': credential.user?.uid,
        'name': name.trim(),
        'email': email.trim(),
        'roles': [role], // Store as array to support multiple roles
        'currentRole': role, // Active role
        'profileImage': '',
        'phone': '',
        'isActive': true,
        'isEmailVerified': false,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      return {
        'success': true,
        'message': 'Account created successfully! Please verify your email.',
        'user': credential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Admin credentials
  static const String adminEmail = 'admin@admin.com';
  static const String adminPassword = 'admin123';

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final bool isAdmin = (email.trim() == adminEmail && password.trim() == adminPassword);

      UserCredential credential;

      if (isAdmin) {
        // Admin login - try to sign in, create account if doesn't exist
        try {
          credential = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            // Create admin account
            credential = await _auth.createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );
            await credential.user?.updateDisplayName('Admin');

            // Create admin user data in database
            try {
              await _database.child('users').child(credential.user!.uid).set({
                'uid': credential.user!.uid,
                'name': 'Admin',
                'email': email.trim(),
                'roles': ['admin'],
                'currentRole': 'admin',
                'profileImage': '',
                'phone': '',
                'isActive': true,
                'isEmailVerified': true,
                'createdAt': ServerValue.timestamp,
                'updatedAt': ServerValue.timestamp,
              });
            } catch (dbError) {
              print('Warning: Could not write admin data to DB: $dbError');
            }
          } else {
            rethrow;
          }
        }

        // Admin always returns success with admin role
        return {
          'success': true,
          'message': 'Admin login successful!',
          'user': credential.user,
          'role': 'admin',
          'roles': ['admin'],
          'isEmailVerified': true,
        };
      }

      // Regular user login
      credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Try to get user role from Realtime Database (but don't fail login if DB is unreachable)
      String currentRole = 'user';
      List<String> roles = ['user'];
      bool isEmailVerified = credential.user?.emailVerified ?? false;

      try {
        final snapshot = await _database.child('users').child(credential.user!.uid).get();

        if (snapshot.value == null) {
          // User exists in Auth but not in Database — create profile
          try {
            await _database.child('users').child(credential.user!.uid).set({
              'uid': credential.user!.uid,
              'name': credential.user!.displayName ?? 'User',
              'email': credential.user!.email ?? email.trim(),
              'roles': ['user'],
              'currentRole': 'user',
              'profileImage': credential.user!.photoURL ?? '',
              'phone': '',
              'isActive': true,
              'isEmailVerified': isEmailVerified,
              'createdAt': ServerValue.timestamp,
              'updatedAt': ServerValue.timestamp,
            });
          } catch (dbWriteError) {
            print('Warning: Could not create user profile in DB: $dbWriteError');
          }
        } else {
          final Map<dynamic, dynamic> userData;
          try {
            userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
          } catch (e) {
            print('Error parsing user data: $e');
            // Return success anyway — user is authenticated
            return {
              'success': true,
              'message': 'Login successful!',
              'user': credential.user,
              'role': 'user',
              'roles': ['user'],
              'isEmailVerified': isEmailVerified,
            };
          }

          // Check if user is active
          if (userData['isActive'] == false) {
            await _auth.signOut();
            return {
              'success': false,
              'message': 'Your account has been deactivated. Please contact support.',
            };
          }

          // Handle both old (single role) and new (multiple roles) format
          if (userData.containsKey('roles')) {
            roles = List<String>.from(userData['roles'] ?? ['user']);
            currentRole = userData['currentRole'] ?? roles.first;
          } else {
            currentRole = userData['role'] ?? 'user';
            roles = [currentRole];

            // Update database to new format
            try {
              await _database.child('users').child(credential.user!.uid).update({
                'roles': roles,
                'currentRole': currentRole,
                'updatedAt': ServerValue.timestamp,
              });
            } catch (dbUpdateError) {
              print('Warning: Could not migrate role format: $dbUpdateError');
            }
          }
        }
      } catch (dbError) {
        // Database read failed (permission denied, network, etc.)
        // Still allow login since the user IS authenticated
        print('Warning: Database read failed after auth: $dbError');
      }

      return {
        'success': true,
        'message': 'Login successful!',
        'user': credential.user,
        'role': currentRole,
        'roles': roles,
        'isEmailVerified': isEmailVerified,
      };
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      print('Unexpected Sign-In Error: $e');
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Sign in with Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return {
          'success': false,
          'message': 'Sign in cancelled.',
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user data exists in database
      final snapshot = await _database.child('users').child(userCredential.user!.uid).get();
      
      if (snapshot.value == null) {
        // First time Google sign-in, create user data
        await _database.child('users').child(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'User',
          'email': userCredential.user!.email ?? '',
          'roles': ['user'], // Default role as array
          'currentRole': 'user', // Active role
          'profileImage': userCredential.user!.photoURL ?? '',
          'phone': '',
          'isActive': true,
          'isEmailVerified': true, // Google accounts are pre-verified
          'createdAt': ServerValue.timestamp,
          'updatedAt': ServerValue.timestamp,
        });
        
        return {
          'success': true,
          'message': 'Account created successfully!',
          'user': userCredential.user,
          'role': 'user',
          'roles': ['user'],
          'isEmailVerified': true,
        };
      }

      // Existing user, get their data
      final Map<dynamic, dynamic> userData;
      try {
        userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
      } catch (e) {
        print('Error parsing Google user data: $e');
        return {
          'success': false,
          'message': 'Error loading profile data. Please try again.',
        };
      }
      
      // Check if user is active
      if (userData['isActive'] == false) {
        await _auth.signOut();
        await _googleSignIn.signOut();
        return {
          'success': false,
          'message': 'Your account has been deactivated. Please contact support.',
        };
      }

      // Handle both old (single role) and new (multiple roles) format
      List<String> roles;
      String currentRole;
      
      if (userData.containsKey('roles')) {
        roles = List<String>.from(userData['roles'] ?? ['user']);
        currentRole = userData['currentRole'] ?? roles.first;
      } else {
        // Old format - migrate
        currentRole = userData['role'] ?? 'user';
        roles = [currentRole];
        await _database.child('users').child(userCredential.user!.uid).update({
          'roles': roles,
          'currentRole': currentRole,
          'updatedAt': ServerValue.timestamp,
        });
      }

      return {
        'success': true,
        'message': 'Login successful!',
        'user': userCredential.user,
        'role': currentRole,
        'roles': roles,
        'isEmailVerified': true,
      };
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Google Error: ${e.code} - ${e.message}');
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      print('Unexpected Google Sign-In Error: $e');
      return {
        'success': false,
        'message': 'An error occurred during Google sign-in. Please try again.',
      };
    }
  }

  // Add a new role to user account
  Future<Map<String, dynamic>> addRole(String newRole) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      final snapshot = await _database.child('users').child(user.uid).get();
      if (!snapshot.exists) {
        return {
          'success': false,
          'message': 'User data not found.',
        };
      }

      final userData = snapshot.value as Map<dynamic, dynamic>;
      List<String> roles = List<String>.from(userData['roles'] ?? ['user']);

      // Check if role already exists
      if (roles.contains(newRole)) {
        return {
          'success': false,
          'message': 'You already have this role.',
        };
      }

      // Add new role
      roles.add(newRole);
      await _database.child('users').child(user.uid).update({
        'roles': roles,
        'updatedAt': ServerValue.timestamp,
      });

      return {
        'success': true,
        'message': 'Role added successfully!',
        'roles': roles,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add role. Please try again.',
      };
    }
  }

  // Switch current role
  Future<Map<String, dynamic>> switchRole(String newRole) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      final snapshot = await _database.child('users').child(user.uid).get();
      if (!snapshot.exists) {
        return {
          'success': false,
          'message': 'User data not found.',
        };
      }

      final userData = snapshot.value as Map<dynamic, dynamic>;
      List<String> roles = List<String>.from(userData['roles'] ?? ['user']);

      // Check if user has this role
      if (!roles.contains(newRole)) {
        return {
          'success': false,
          'message': 'You do not have access to this role.',
        };
      }

      // Switch to new role
      await _database.child('users').child(user.uid).update({
        'currentRole': newRole,
        'updatedAt': ServerValue.timestamp,
      });

      return {
        'success': true,
        'message': 'Role switched successfully!',
        'currentRole': newRole,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to switch role. Please try again.',
      };
    }
  }

  // Send password reset email
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent! Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Send email verification
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Reload user to check email verification status
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Update email verification status in Realtime Database
  Future<void> updateEmailVerificationStatus() async {
    final user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      await _database.child('users').child(user.uid).update({
        'isEmailVerified': true,
        'updatedAt': ServerValue.timestamp,
      });
    }
  }

  // Apply to become a service provider (creates a pending application)
  Future<Map<String, dynamic>> applyForProvider() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      // Check if already applied
      final existingApp = await _database.child('provider_applications').child(user.uid).get();
      if (existingApp.exists) {
        final appData = Map<dynamic, dynamic>.from(existingApp.value as Map);
        final status = appData['status'] ?? 'pending';
        if (status == 'pending') {
          return {
            'success': false,
            'message': 'You already have a pending application.',
          };
        }
        if (status == 'approved') {
          return {
            'success': false,
            'message': 'You are already approved as a provider.',
          };
        }
      }

      // Create provider application
      await _database.child('provider_applications').child(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'status': 'pending', // pending, approved, rejected
        'appliedAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });

      return {
        'success': true,
        'message': 'Your application has been submitted! An admin will review it shortly.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit application. Please try again.',
      };
    }
  }

  // Get provider application status
  Future<String?> getProviderApplicationStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _database.child('provider_applications').child(user.uid).get();
      if (!snapshot.exists) return null;

      final appData = Map<dynamic, dynamic>.from(snapshot.value as Map);
      return appData['status'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Realtime Database
        await _database.child('users').child(user.uid).remove();
        
        // Delete user account
        await user.delete();
        
        return {
          'success': true,
          'message': 'Account deleted successfully.',
        };
      }
      return {
        'success': false,
        'message': 'No user logged in.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _database.child('users').child(uid).update({
        ...data,
        'updatedAt': ServerValue.timestamp,
      });
      return {
        'success': true,
        'message': 'Profile updated successfully!',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile. Please try again.',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        return {
          'success': false,
          'message': 'No user logged in.',
        };
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password changed successfully!',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Get error message from Firebase error code
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please logout and login again to perform this action.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
