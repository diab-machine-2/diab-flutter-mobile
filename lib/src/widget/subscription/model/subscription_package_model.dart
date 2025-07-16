import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class PackageFeature {
  final String text;
  final List<TextSpan> richText;
  final bool isHighlighted;

  PackageFeature({
    required this.text,
    this.richText = const [],
    this.isHighlighted = false,
  });

  factory PackageFeature.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('richText') && json['richText'] != null) {
      List<TextSpan> spans = [];
      for (var span in json['richText']) {
        spans.add(
          TextSpan(
            text: span['text'],
            style: TextStyle(
              fontSize: 15,
              fontWeight: span['isBold'] ? FontWeight.w700 : FontWeight.w400,
              color: span['isBold']
                  ? R.color.greenGradientBottom
                  : R.color.color0xff111515,
            ),
          ),
        );
      }
      return PackageFeature(
        text: json['text'],
        richText: spans,
        isHighlighted: json['isHighlighted'] ?? false,
      );
    }

    return PackageFeature(
      text: json['text'],
      isHighlighted: json['isHighlighted'] ?? false,
    );
  }
}

class SubscriptionPackage {
  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String duration;
  final String backgroundImagePath;
  final List<PackageFeature> features;
  final bool isRecommended;

  SubscriptionPackage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.duration,
    required this.backgroundImagePath,
    required this.features,
    this.isRecommended = false,
  });

  // String get priceText => '$price/$duration';
  String get priceText => '$duration';

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    List<PackageFeature> featuresList = [];
    for (var feature in json['features']) {
      featuresList.add(PackageFeature.fromJson(feature));
    }

    return SubscriptionPackage(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      price: json['price'],
      duration: json['duration'],
      backgroundImagePath: json['backgroundImagePath'],
      features: featuresList,
      isRecommended: json['isRecommended'] ?? false,
    );
  }

  static List<SubscriptionPackage> fromList(List<dynamic> jsonList) {
    return jsonList.map((json) => SubscriptionPackage.fromJson(json)).toList();
  }
}
