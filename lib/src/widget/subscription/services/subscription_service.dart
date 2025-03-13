import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static Future<List<SubscriptionPackage>> getLocalPackages() async {
    // Load from local JSON file
    final String response = await rootBundle.loadString(
        'lib/src/widget/subscription/data/subscription_packages.json');
    final Map<String, dynamic> data = json.decode(response);
    return SubscriptionPackage.fromList(data['packages']);
  }

  static Future<Map<String, SubscriptionPackage>> mapLocalPackagesToRevenueCat(
      List<SubscriptionPackage> localPackages,
      List<Package> revenueCatPackages) async {
    final Map<String, SubscriptionPackage> packageMap = {};

    for (var revenueCatPackage in revenueCatPackages) {
      // Find matching local package based on identifier
      final String productId = revenueCatPackage.storeProduct.identifier;
      final localPackage = localPackages.firstWhere(
        (package) => package.id == productId,
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

    return packageMap;
  }

  static String _extractDuration(String title) {
    // Simple logic to extract duration from title
    if (title.contains('3 month')) return '3 tháng';
    if (title.contains('12 month')) return '12 tháng';
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
      case 'dong_hanh':
        return R.drawable.dong_hanh_badge;
      case 'thau_cam':
        return R.drawable.thau_cam_badge;
      default:
        return '';
    }
  }
}
