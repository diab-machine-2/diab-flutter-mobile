class BannerModel {
  final String value; // This maybe image id or image url
  final String title;
  final String subtitle;
  final int order;

  BannerModel({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      value: json['value'] ?? '',
      title: json['title']  ?? '',
      subtitle: json['subtitle'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'title': title,
      'subtitle': subtitle,
      'order': order,
    };
  }
}