class ImagesUrlModel {
  final String? id;
  final String? url;

  ImagesUrlModel({required this.id, required this.url});
  @override
  factory ImagesUrlModel.fromJson(Map<String, dynamic> json) {
    return ImagesUrlModel(
      id: json['id'],
      url: json['url'],
    );
  }
  static List<ImagesUrlModel> toList(List<dynamic> items) {
    return items.map((item) => ImagesUrlModel.fromJson(item)).toList();
  }
}
