import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widget/subscription/subscription_navigation_mixin.dart';
import 'package:medical/src/widget/subscription/widgets/basic_subscription_bottom_sheet.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static Future<List<SubscriptionPackage>> getLocalPackages() async {
    try {
      // Load from local JSON file
      final String response = await rootBundle.loadString(
          'lib/src/widget/subscription/data/subscription_packages.json');
      final Map<String, dynamic> data = json.decode(response);
      return SubscriptionPackage.fromList(data['packages']);
    } catch (e) {
      print('Error loading local packages: $e');
      // Return empty list if there's an error
      return [];
    }
  }

  // This method will only be used for "Cơ bản" package
  static Future<Map<String, SubscriptionPackage>> mapBasicPackagesToRevenueCat(
      List<SubscriptionPackage> localPackages,
      List<Package> revenueCatPackages) async {
    final Map<String, SubscriptionPackage> packageMap = {};

    try {
      // Filter to only include "cơ bản" packages
      final cobanPackages = revenueCatPackages
          .where((p) =>
              p.storeProduct.identifier.contains('co_ban') ||
              p.storeProduct.identifier.contains('base') ||
              p.storeProduct.title.toLowerCase().contains('cơ bản'))
          .toList();

      for (var revenueCatPackage in cobanPackages) {
        // Find matching local package based on identifier
        final String productId = revenueCatPackage.storeProduct.identifier;
        final localPackage = localPackages.firstWhere(
          (package) => package.id == 'co_ban',
          orElse: () => SubscriptionPackage(
            id: productId,
            title: revenueCatPackage.storeProduct.title,
            subtitle: revenueCatPackage.storeProduct.description,
            price: revenueCatPackage.storeProduct.priceString,
            duration: _extractDuration(revenueCatPackage.storeProduct.title),
            backgroundImagePath: 'assets/images/bg_default.jpg',
            features: [],
          ),
        );

        packageMap[productId] = localPackage;
      }
    } catch (e) {
      print('Error mapping RevenueCat packages: $e');
    }

    return packageMap;
  }

  static String _extractDuration(String title) {
    // Simple logic to extract duration from title
    if (title.contains('3 month') || title.contains('3 tháng'))
      return '3 tháng';
    if (title.contains('6 month') || title.contains('6 tháng'))
      return '6 tháng';
    if (title.contains('12 month') || title.contains('12 tháng'))
      return '12 tháng';
    return 'tháng';
  }

  // This method handles rich text for features
  static List<TextSpan> parseRichText(String text) {
    // Simple implementation to handle bold text enclosed in ** markers
    // In a real implementation, you might want a more sophisticated parser
    List<TextSpan> spans = [];
    RegExp exp = RegExp(r'\*\*(.*?)\*\*|([^\*]+)');

    Iterable<RegExpMatch> matches = exp.allMatches(text);
    for (var match in matches) {
      if (match.group(1) != null) {
        // Bold text
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        // Regular text
        spans.add(TextSpan(
          text: match.group(2),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ));
      }
    }

    return spans;
  }

  static String getBackgroundImageFromId(String packageId) {
    switch (packageId) {
      case 'co_ban':
        return R.drawable.co_ban_bg;
      case 'dong_hanh':
        return R.drawable.dong_hanh_bg;
      case 'thau_cam':
        return R.drawable.thau_cam_bg;
      default:
        return R.drawable.dong_hanh_bg;
    }
  }

  static String getBadgeImageFromId(String packageId) {
    switch (packageId) {
      case 'co_ban':
        return R.drawable.co_ban_badge;
      case 'dong_hanh':
        return R.drawable.dong_hanh_badge;
      case 'thau_cam':
        return R.drawable.thau_cam_badge;
      default:
        return '';
    }
  }

  static void showSubscriptionOptionsSheet(
      BuildContext context, SubscriptionPackage package) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubscriptionOptionsBottomSheet(
        package: package,
        onPackageSelected: (selectedPackage) {
          // Handle the selected package
          print('Selected package: ${selectedPackage.title}');
        },
        onPurchaseSuccess: () {
          // Navigate to start program
          print('Purchase successful, starting program');
          // Navigate to package program list
          Observable.instance.notifyObservers([], notifyName: "refresh_home");
          SubscriptionNavigationMixin.navigationKey.currentState?.pushNamed(
            NavigatorName.package_program_list,
            arguments: <String, dynamic>{'lockBackAfterPurchase': true},
          );
        },
      ),
    );
  }

  static bool isBasicPackage(SubscriptionPackage? package) {
    if (package == null) return false;
    final isBasic = package.id.contains('co_ban') ||
        package.id.contains('base') ||
        package.title.toLowerCase().contains('cơ bản');
    return isBasic;
  }
}
