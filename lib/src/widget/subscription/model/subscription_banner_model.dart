class BannerModel {
  final String value; // This maybe image id or image url
  final String title;
  final int order;

  BannerModel({
    required this.value,
    required this.title,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      value: json['value'],
      title: json['title'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'title': title,
      'order': order,
    };
  }
}