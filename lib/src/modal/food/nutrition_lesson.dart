class NutritionLesson {
  final String id;
  final String name;
  final int type;
  final int status; // 1: active, 2: inactive
  final String? imageUrl;

  NutritionLesson({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.imageUrl,
  });

  factory NutritionLesson.fromJson(Map<String, dynamic> json) {
    return NutritionLesson(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      status: json['status'] ?? 1,
      imageUrl: json['image'] != null ? json['image']['url'] : null,
    );
  }
}

