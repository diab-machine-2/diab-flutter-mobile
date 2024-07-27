class TargetRecommendation {
  String title;
  int type;

  TargetRecommendation({
    required this.title,
    required this.type,
  });

  factory TargetRecommendation.fromJson(Map<String, dynamic> json) {
    return TargetRecommendation(
      title: json['title'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
    };
  }
  
}