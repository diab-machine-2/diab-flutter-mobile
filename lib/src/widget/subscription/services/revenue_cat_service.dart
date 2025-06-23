import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/src/utils/const.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static String? _currentAppUserId;
  // Step 3: Initialize RevenueCat with your API keys
  static Future<void> initialize() async {
    await Purchases.setLogLevel(
        LogLevel.debug); // Set to debug during development

    // Configure with your API keys
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(Const.REVENUE_CAT_GOOGLE_API_KEY);
    } else if (Platform.isIOS) {
      configuration = PurchasesConfiguration(Const.REVENUE_CAT_APPLE_API_KEY);
    } else {
      throw PlatformException(
        code: 'UNSUPPORTED_PLATFORM',
        message: 'The current platform is not supported by RevenueCat',
      );
    }

    await Purchases.configure(configuration);
  }

  // Step 4: Get available products
  static Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        log('[SUBSCRIPTION] RevenueCat offerings: ${offerings.current!.availablePackages}');
        return offerings.current!.availablePackages;
      }
      return [];
    } on PlatformException catch (e) {
      log('[SUBSCRIPTION] Error RevenueCat offerings: ${e.message}');
      return [];
    }
  }

// Get the current offering (for RevenueCatUI.presentPaywall)
  static Future<Offering?> getCurrentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current;
    } on PlatformException catch (e) {
      debugPrint(
          '[SUBSCRIPTION] Error fetching current offering: ${e.message}');
      return null;
    }
  }

  // Step 5: Make a purchase
  static Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      return customerInfo.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      if (e.code == 'purchase_cancelled') {
        debugPrint('[SUBSCRIPTION] User cancelled the purchase');
      } else {
        debugPrint('[SUBSCRIPTION] Error making purchase: ${e.message}');
      }
      return false;
    }
  }

  // Step 6: Check subscription status
  static Future<bool> isSubscribed(String entitlementId) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(entitlementId);
    } on PlatformException catch (e) {
      debugPrint(
          '[SUBSCRIPTION] Error checking subscription status: ${e.message}');
      return false;
    }
  }

  // Step 7: Restore purchases
  static Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.active.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('[SUBSCRIPTION] Error restoring purchases: ${e.message}');
      return false;
    }
  }

  // Step 8: Identify user (for user management)
  static Future<void> login(String userId) async {
    if (userId.isEmpty) {
      print("Warning: Attempted to login with empty userId");
      return;
    }

    try {
      _currentAppUserId = userId;

      final result = await Purchases.logIn(userId);
      log('[SUBSCRIPTION] User logged in: ${result.customerInfo}');
    } on PlatformException catch (e) {
      debugPrint('[SUBSCRIPTION] Error logging in: ${e.message}');
    }
  }

  // Step 9: Log out user
  static Future<void> logout() async {
    try {
      _currentAppUserId = null;
      
      await Purchases.logOut();
    } on PlatformException catch (e) {
      debugPrint('[SUBSCRIPTION] Error logging out: ${e.message}');
    }
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      // Force sync with the store
      await Purchases.syncPurchases();

      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } on PlatformException catch (e) {
      debugPrint('[SUBSCRIPTION] Error fetching customerInfo: ${e.message}');
      return null;
    }
  }

  static Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Check if a different user has active subscriptions before allowing purchase
  static Future<bool> validateNoOtherUserHasActiveSubscription() async {
    try {
      // First, sync purchases from the store
      log('[SUBSCRIPTION] Syncing purchases to check for existing subscriptions');
      await Purchases.syncPurchases();

      // Get the current customer info to check active subscriptions
      final customerInfo = await Purchases.getCustomerInfo();

      // If there are active entitlements
      if (customerInfo.entitlements.active.isNotEmpty) {
        // Check if the original app user ID matches our current user
        final originalUserId = customerInfo.originalAppUserId;
        log('[SUBSCRIPTION] Found active subscriptions for user: $originalUserId');

        // If the subscription belongs to a different user (not our current user), block purchase
        if (originalUserId != _currentAppUserId && _currentAppUserId != null) {
          log('[SUBSCRIPTION] Warning: Found subscription belonging to a different user');
          return false; // Block the purchase
        }
      }

      // No active subscriptions or subscription belongs to current user
      return true;
    } catch (e) {
      log('[SUBSCRIPTION] Error validating subscription ownership: $e');
      return true; // Allow purchase by default if validation fails
    }
  }
}
