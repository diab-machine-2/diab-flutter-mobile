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
      return customerInfo.isActivelySubscribed;
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
      return customerInfo.entitlements.active.containsKey(entitlementId) || customerInfo.isActivelySubscribed;
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
      return customerInfo.entitlements.active.isNotEmpty || customerInfo.isActivelySubscribed;
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
      _currentAppUserId = Platform.isIOS ? "ios-$userId" : "android-$userId";

      final result = await Purchases.logIn(_currentAppUserId!);
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
      return customerInfo.entitlements.active.isNotEmpty || customerInfo.isActivelySubscribed;
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
      if (customerInfo.isActivelySubscribed) {
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

  // Debug method to verify iOS setup
  // static Future<void> debugiOSSetup() async {
  //   if (!Platform.isIOS) return;
    
  //   try {
  //     log('[SUBSCRIPTION] [iOS Debug] Checking RevenueCat configuration...');
      
  //     // Check if RevenueCat is configured
  //     final customerInfo = await Purchases.getCustomerInfo();
  //     log('[SUBSCRIPTION] [iOS Debug] Customer info retrieved: ${customerInfo.originalAppUserId}');
      
  //     // Check available offerings
  //     final offerings = await Purchases.getOfferings();
  //     log('[SUBSCRIPTION] [iOS Debug] Available offerings: ${offerings.all.keys.toList()}');
      
  //     if (offerings.current != null) {
  //       log('[SUBSCRIPTION] [iOS Debug] Current offering packages: ${offerings.current!.availablePackages.length}');
  //       for (var package in offerings.current!.availablePackages) {
  //         log('[SUBSCRIPTION] [iOS Debug] Package: ${package.storeProduct.identifier} - ${package.storeProduct.title}');
  //       }
  //     }
      
  //     // Check App Store connection
  //     try {
  //       await Purchases.syncPurchases();
  //       log('[SUBSCRIPTION] [iOS Debug] Successfully synced with App Store');
  //     } catch (e) {
  //       log('[SUBSCRIPTION] [iOS Debug] Failed to sync with App Store: $e');
  //     }
      
  //   } catch (e) {
  //     log('[SUBSCRIPTION] [iOS Debug] Error during setup verification: $e');
  //   }
  // }

  // Enhanced purchase method with iOS-specific handling
  static Future<bool> purchasePackageWithiOSHandling(Package package) async {
    // if (Platform.isIOS) {
    //   await debugiOSSetup();
    // }
    
    try {
      // log('[SUBSCRIPTION] Starting purchase for package: ${package.storeProduct.identifier}');
      // log('[SUBSCRIPTION] Package price: ${package.storeProduct.priceString}');
      
      // On iOS, ensure we're logged in first
      if (Platform.isIOS && _currentAppUserId != null) {
        // log('[SUBSCRIPTION] [iOS] Ensuring user is logged in: $_currentAppUserId');
        await login(_currentAppUserId!);
      }
      
      final customerInfo = await Purchases.purchasePackage(package);
      
      // log('[SUBSCRIPTION] Purchase completed. CustomerInfo: ${customerInfo.toString()}');
      // log('[SUBSCRIPTION] Active entitlements: ${customerInfo.entitlements.active.keys.toList()}');
      
      // On iOS, double-check the purchase by getting fresh customer info
      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 500)); // Brief delay for processing
        final freshCustomerInfo = await Purchases.getCustomerInfo();
        return freshCustomerInfo.isActivelySubscribed;
      }
      
      final hasActiveSubscription = customerInfo.entitlements.active.isNotEmpty;
      // log('[SUBSCRIPTION] Has active subscription: $hasActiveSubscription');
      
      return hasActiveSubscription;
    } on PlatformException catch (e) {
      log('[SUBSCRIPTION] PlatformException during purchase: ${e.code} - ${e.message}');
      log('[SUBSCRIPTION] PlatformException details: ${e.details}');
      
      if (e.code == 'purchase_cancelled') {
        log('[SUBSCRIPTION] User cancelled the purchase');
      } else if (e.code == 'user_cancelled') {
        log('[SUBSCRIPTION] User cancelled the purchase (alternative code)');
      } else if (e.code == 'payment_pending') {
        log('[SUBSCRIPTION] Payment is pending approval');
        // On iOS, some payments might be pending (like Ask to Buy)
        return false;
      } else if (e.code == 'product_already_purchased') {
        log('[SUBSCRIPTION] Product already purchased, checking entitlements');
        // Product already purchased, check current entitlements
        try {
          final customerInfo = await Purchases.getCustomerInfo();
          return customerInfo.entitlements.active.isNotEmpty;
        } catch (innerE) {
          log('[SUBSCRIPTION] Error checking entitlements after already purchased: $innerE');
          return false;
        }
      } else {
        log('[SUBSCRIPTION] Unexpected error making purchase: ${e.message}');
      }
      return false;
    } catch (e) {
      log('[SUBSCRIPTION] Unexpected error during purchase: $e');
      return false;
    }
  }
}

extension CustomerInfoApp on CustomerInfo {
  List<String> get productIdentifiers {
    return [
      'subscription_basic_06m',
      'subscription_basic_12m',
    ];
  }

  String? get purchasedProductIdentifier {
    if (this.allPurchasedProductIdentifiers.isNotEmpty) {
      return this.allPurchasedProductIdentifiers.any(
        (identifier) => productIdentifiers.contains(identifier),
      ) ? this.allPurchasedProductIdentifiers.first : null;
    }
    return null;
  }

  bool get isActivelySubscribed {
    final hasActiveEntitlements = this.entitlements.active.isNotEmpty;
    final hasActiveSubscriptions = this.activeSubscriptions.isNotEmpty;
    bool hasPurchasedProduct = this.purchasedProductIdentifier != null;
    return hasActiveEntitlements || hasActiveSubscriptions || hasPurchasedProduct;
  }
}
