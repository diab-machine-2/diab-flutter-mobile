import 'package:flutter/material.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/helper.dart';

class HbA1cNavigationHelper {
  /// Handle HbA1C navigation - check if user has data and route accordingly
  /// - Users with data: navigate to dashboard (priority check)
  /// - First time users or users without data: navigate to intro page
  /// - Fallback: navigate to detail page
  static Future<void> navigateToHbA1C(BuildContext context) async {
    try {
      // Small delay to ensure data is updated after HbA1C input
      await Future.delayed(Duration(milliseconds: 300));

      // Check if user has HbA1c data from home model (priority check)
      // Check both index value and createDateTime to determine if there's real data
      // Backend may return default value (e.g., 9.0) even when there's no actual data
      bool hasHbA1cData = false;
      final homeModel = await AppSettings.getHome();

      if (homeModel != null) {
        final hasValidDateTime = homeModel.hbA1CIndex.createDateTime != null &&
            homeModel.hbA1CIndex.createDateTime! > 0;

        hasHbA1cData = homeModel.hbA1CIndex.index != null &&
            homeModel.hbA1CIndex.index! > 0 &&
            hasValidDateTime;

        print('🔍 HbA1C Navigation Check:');
        print('  index: ${homeModel.hbA1CIndex.index}');
        print('  createDateTime: ${homeModel.hbA1CIndex.createDateTime}');
        print('  hasValidDateTime: $hasValidDateTime');
        print('  hasHbA1cData: $hasHbA1cData');
      }

      // Priority: If user has data, always navigate to dashboard regardless of isFirstTime flag
      if (hasHbA1cData && homeModel != null) {
        // User has data, navigate to dashboard
        Navigator.pushNamed(context, NavigatorName.hba1c_dashboard, arguments: {
          'currentValue': homeModel.hbA1CIndex.index,
          'currentLevel': _getHbA1cLevel(homeModel.hbA1CIndex.index ?? 0),
          'currentColor': _getHbA1cColor(homeModel.hbA1CIndex.color)
        });
      } else {
        // No data - check if first time
        bool isFirstTime = await AppStorages.isFirstTimeHbA1C();

        if (isFirstTime || !hasHbA1cData) {
          // Navigate to onboarding for first time users or users without data
          Navigator.pushNamed(context, NavigatorName.hba1c_intro_1st_page);
        } else {
          // Fallback: navigate to detail view (which will show empty state)
          Navigator.pushNamed(context, NavigatorName.detail_hba1c);
        }
      }
    } catch (e) {
      // Fallback to dashboard if there's any error
      Navigator.pushNamed(context, NavigatorName.hba1c_dashboard);
    }
  }

  /// Call this when user completes onboarding
  static Future<void> completeOnboarding(BuildContext context) async {
    await AppStorages.setHbA1COnboardingCompleted();
    Navigator.pushReplacementNamed(context, NavigatorName.hba1c_dashboard);
  }

  /// Reset onboarding status (for testing purposes)
  static Future<void> resetOnboardingStatus() async {
    await AppStorages.resetHbA1COnboarding();
  }

  /// Get HbA1c level text based on value
  static String _getHbA1cLevel(double value) {
    // Match the standard HbA1c range classification
    // ≤ 6.5: Lý tưởng, > 6.5 và ≤ 7.0: Tốt, > 7.0 và ≤ 8.0: Cao, > 8.0: Rất cao
    if (value <= 6.5) {
      return 'Lý tưởng';
    } else if (value <= 7.0) {
      return 'Tốt';
    } else if (value <= 8.0) {
      return 'Cao';
    } else {
      return 'Rất cao';
    }
  }

  /// Get HbA1c color based on color string
  static Color _getHbA1cColor(String? colorString) {
    if (colorString != null && colorString.isNotEmpty) {
      return toColor(colorString);
    }
    return const Color(0xFF17B545); // Default green color
  }
}
