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

## Build runner

flutter pub run build_runner build --delete-conflicting-outputs

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


Case 1.1
 Cả máy đường huyết và máy điện thoại không có kết nối với nhau.
 (Đã xóa pair)

Case 2.1
 Máy điện thoại xóa pair, máy đường huyết giữ thông tin pair

Case 3.1
 Máy điện thoại giữ thông tin pair, máy đường huyết xóa thông tin pair

Case 4.1 
Cả 2 đang pair với nhau và send data

Với case 1.1 và 4.1 thì mong muốn send data thành công
Case 2.1 và 3.1 thì show nội dung hướng dẫn cách xử lý