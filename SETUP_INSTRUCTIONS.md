# StreetBite Setup Instructions

## 🎉 Milestone 1 Complete!

The basic app structure is now ready with:
- ✅ Complete authentication flow
- ✅ User type selection (Vendor/Customer)
- ✅ Basic dashboards for both user types
- ✅ Proper folder structure and state management
- ✅ All required dependencies

## 🔥 Next Steps: Firebase Configuration

To run the app, you need to set up Firebase:

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "streetbite" or your preferred name
4. Enable Google Analytics (optional)

### 2. Add Android App
1. Click "Add app" → Android
2. Package name: `com.example.streetbite` (or update in `android/app/build.gradle`)
3. Download `google-services.json`
4. Place it in `android/app/` folder

### 3. Add iOS App (if needed)
1. Click "Add app" → iOS
2. Bundle ID: `com.example.streetbite` (or update in iOS project)
3. Download `GoogleService-Info.plist`
4. Add to `ios/Runner/` folder

### 4. Enable Firebase Services
In Firebase Console:
1. **Authentication** → Sign-in method → Enable "Phone"
2. **Firestore Database** → Create database (start in test mode)
3. **Storage** → Get started (for image uploads)
4. **Cloud Messaging** → No additional setup needed

### 5. Run the App
```bash
flutter pub get
flutter run
```

## 📱 App Flow
1. **Splash Screen** → checks auth state
2. **Login Screen** → phone number input
3. **OTP Verification** → 6-digit code
4. **User Type Selection** → Vendor or Customer
5. **Profile Setup** → name and email
6. **Dashboard** → role-specific home screen

## 🚀 Ready for Milestone 2
Once Firebase is configured, we can start implementing:
- Vendor registration with location picker
- Real-time status updates
- Menu management
- Customer discovery features

## 🛠️ Development Notes
- All models are defined for Firestore integration
- Services are ready for Firebase operations
- UI is responsive and follows Material Design 3
- Error handling and loading states implemented
- Clean architecture with separation of concerns