class GlucoseLesson {
  final String id;
  final String name;
  final String? imageUrl;

  GlucoseLesson({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory GlucoseLesson.fromJson(Map<String, dynamic> json) {
    return GlucoseLesson(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image'] != null ? json['image']['url'] : null,
    );
  }
}
