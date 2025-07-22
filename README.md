# medical

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building APK for Development

To build an APK file for the development environment that can be shared with clients, follow these steps:

### Using Command Line

1. Navigate to the project root directory:
```bash
cd /path/to/diab-flutter-mobile
```

2. Clean the project (recommended before building):
```bash
flutter clean
```

3. Get dependencies:
```bash
flutter pub get
```

4. Build the APK for development:
```bash
flutter build apk --debug
```
   
   Or for a release version (optimized for performance):
```bash
flutter build apk --release
```

5. The APK file will be generated at:
   - Debug build: `build/app/outputs/flutter-apk/app-debug.apk`
   - Release build: `build/app/outputs/flutter-apk/app-release.apk`

### Using Android Studio

1. Open the project in Android Studio
2. Select the build variant (debug/release) from Build Variants panel
3. Click on Build > Build Bundle(s) / APK(s) > Build APK(s)
4. After build completes, click on "locate" in the notification to find the APK

adb shell setprop debug.firebase.analytics.app com.vbhc.diab
