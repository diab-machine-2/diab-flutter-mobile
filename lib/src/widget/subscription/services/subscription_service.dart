import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';

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

  static bool isBasicPackage(SubscriptionPackage? package) {
    if (package == null) return false;
    final isBasic = package.id.contains('co_ban') ||
        package.id.contains('base') ||
        package.title.toLowerCase().contains('cơ bản');
    return isBasic;
  }
}
