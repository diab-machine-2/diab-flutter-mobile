import 'package:medical/src/widget/subscription/phone_validation_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneValidationManager {
  static const String _shouldShowPhoneValidationKey =
      'should_show_phone_validation';

  /// Check if phone validation should be shown
  static Future<bool> shouldShowPhoneValidation() async {
    try {
      // Check if flag is set to true
      final shouldShow = await _getBool(_shouldShowPhoneValidationKey) ?? false;

      if (!shouldShow) {
        return false;
      }

      // Check if phone number is valid
      final isPhoneValid = await PhoneValidationHelper.isValidUserPhoneNumber();

      // Only show if phone is invalid
      return !isPhoneValid;
    } catch (e) {
      return false;
    }
  }

  /// Set flag to show phone validation (call this after successful measurement input)
  static Future<void> setShouldShowPhoneValidation() async {
    await _setBool(_shouldShowPhoneValidationKey, true);
  }

  /// Reset flag (call this after successful phone verification)
  static Future<void> resetShouldShowPhoneValidation() async {
    await _setBool(_shouldShowPhoneValidationKey, false);
  }

  /// Check if flag is currently set
  static Future<bool> isFlagSet() async {
    return await _getBool(_shouldShowPhoneValidationKey) ?? false;
  }

  /// Check if phone validation should be shown and reset flag if shown
  static Future<bool> shouldShowAndResetPhoneValidation() async {
    try {
      final shouldShow = await shouldShowPhoneValidation();
      if (shouldShow) {
        // Reset the flag so it doesn't show again
        await resetShouldShowPhoneValidation();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to get boolean value from SharedPreferences
  static Future<bool?> _getBool(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      return null;
    }
  }

  /// Helper method to set boolean value in SharedPreferences
  static Future<void> _setBool(String key, bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      // Handle error silently
    }
  }
}
