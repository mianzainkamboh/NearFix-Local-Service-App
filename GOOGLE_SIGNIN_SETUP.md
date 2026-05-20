# 🔐 Google Sign-In Setup Guide

## ✅ Code Implementation Complete!

Google Sign-In has been fully implemented in your app. Now you just need to configure it in Firebase Console.

---

## 📋 Firebase Console Setup (5 Minutes)

### Step 1: Get SHA-1 Certificate Fingerprint

Open terminal and run:

```bash
cd android
./gradlew signingReport
```

**For Windows:**
```bash
cd android
gradlew signingReport
```

Look for the **SHA-1** fingerprint in the output. It will look like:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

Copy this SHA-1 value.

---

### Step 2: Add SHA-1 to Firebase

1. Go to [Firebase Project Settings](https://console.firebase.google.com/project/nearfix-c1f68/settings/general)
2. Scroll down to **"Your apps"** section
3. Find your Android app: **com.example.nearfix**
4. Click **"Add fingerprint"**
5. Paste the SHA-1 fingerprint
6. Click **"Save"**

---

### Step 3: Download Updated google-services.json

1. In the same page, click **"Download google-services.json"**
2. Replace the old file in: `android/app/google-services.json`
3. Make sure to replace the existing file

---

### Step 4: Verify Google Sign-In is Enabled

1. Go to [Authentication > Sign-in method](https://console.firebase.google.com/project/nearfix-c1f68/authentication/providers)
2. Find **"Google"** in the list
3. Should show **"Enabled"** ✅
4. If not enabled:
   - Click on Google
   - Toggle "Enable"
   - Add support email
   - Click "Save"

---

## 🚀 Test Google Sign-In

### Step 1: Restart Your App
```bash
# Stop the app (Ctrl+C)
flutter run
```

### Step 2: Try Google Sign-In
1. Open the app
2. Go to login screen
3. Click **"Continue with Google"**
4. Select your Google account
5. Grant permissions
6. You should be logged in! ✅

---

## 🎯 What Happens During Google Sign-In

1. **User clicks "Continue with Google"**
2. **Google Sign-In popup appears**
3. **User selects Google account**
4. **App receives Google credentials**
5. **Firebase authenticates user**
6. **App checks if user exists in database:**
   - If **new user**: Creates user data automatically
   - If **existing user**: Loads user data
7. **User is logged in and navigated to dashboard**

---

## 📊 User Data Structure (Google Sign-In)

When a user signs in with Google for the first time:

```json
{
  "uid": "google_user_id",
  "name": "User Name from Google",
  "email": "user@gmail.com",
  "role": "user",
  "profileImage": "https://google-profile-photo-url",
  "phone": "",
  "isActive": true,
  "isEmailVerified": true,
  "createdAt": timestamp,
  "updatedAt": timestamp
}
```

**Note:** Google accounts are automatically verified!

---

## 🔧 Troubleshooting

### Issue 1: "Sign in cancelled"
**Cause:** User closed the Google Sign-In popup
**Solution:** Normal behavior, user can try again

### Issue 2: "An error occurred during Google sign-in"
**Possible causes:**
1. SHA-1 not added to Firebase
2. google-services.json not updated
3. Google Sign-In not enabled in Firebase

**Solution:**
1. Verify SHA-1 is added
2. Download and replace google-services.json
3. Enable Google Sign-In in Firebase Console
4. Restart app

### Issue 3: "PlatformException"
**Cause:** SHA-1 fingerprint mismatch
**Solution:**
1. Run `gradlew signingReport` again
2. Add ALL SHA-1 fingerprints shown (debug and release)
3. Download new google-services.json
4. Restart app

### Issue 4: Google Sign-In button not working
**Solution:**
1. Check internet connection
2. Verify Google Sign-In is enabled in Firebase
3. Check console logs for errors

---

## 🎨 Features Implemented

### Login Screen:
- ✅ "Continue with Google" button
- ✅ Disabled state during loading
- ✅ Error handling
- ✅ Success feedback

### Auth Service:
- ✅ `signInWithGoogle()` method
- ✅ Automatic user creation for new users
- ✅ User data loading for existing users
- ✅ Account status checking
- ✅ Role-based navigation
- ✅ Sign out from Google

---

## 📱 User Experience

### First Time Google Sign-In:
```
1. Click "Continue with Google"
2. Select Google account
3. Grant permissions
4. Account created automatically
5. Logged in as User
6. Navigate to User Dashboard
```

### Returning User:
```
1. Click "Continue with Google"
2. Select Google account
3. User data loaded
4. Logged in
5. Navigate to appropriate dashboard
```

---

## 🔒 Security Features

- ✅ Google OAuth 2.0 authentication
- ✅ Secure token exchange
- ✅ Email verification (automatic for Google)
- ✅ Account status checking
- ✅ Role-based access control

---

## 📝 Important Notes

1. **SHA-1 Required:** Google Sign-In won't work without SHA-1 fingerprint
2. **Debug vs Release:** You may need different SHA-1 for debug and release builds
3. **Email Verified:** Google accounts are automatically marked as verified
4. **Default Role:** New Google users get "user" role by default
5. **Profile Photo:** Google profile photo is automatically saved

---

## 🎯 Testing Checklist

- [ ] SHA-1 added to Firebase
- [ ] google-services.json updated
- [ ] Google Sign-In enabled in Firebase Console
- [ ] App restarted
- [ ] "Continue with Google" button visible
- [ ] Button clickable (not disabled)
- [ ] Google Sign-In popup appears
- [ ] Can select Google account
- [ ] Login successful
- [ ] User data created/loaded
- [ ] Navigate to dashboard

---

## 🆓 Cost

Google Sign-In is **100% FREE** on Firebase Spark plan!
- ✅ Unlimited Google sign-ins
- ✅ No additional charges
- ✅ Included in free tier

---

## 📞 Support

If you encounter issues:
1. Check SHA-1 is correct
2. Verify google-services.json is updated
3. Check Firebase Console for errors
4. Look at Flutter console logs
5. Try with different Google account

---

## ✅ Summary

**What's Implemented:**
- ✅ Google Sign-In button on login screen
- ✅ Complete authentication flow
- ✅ Automatic user creation
- ✅ User data management
- ✅ Error handling
- ✅ Success feedback

**What You Need to Do:**
1. Get SHA-1 fingerprint
2. Add to Firebase
3. Download google-services.json
4. Replace in android/app/
5. Restart app
6. Test!

**Time Required:** 5-10 minutes

---

**🎉 Google Sign-In is ready to use!**
