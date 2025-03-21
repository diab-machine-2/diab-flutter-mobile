class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final int order;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.order,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      imageUrl: json['image_url'],
      title: json['title'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'title': title,
      'order': order,
    };
  }
}