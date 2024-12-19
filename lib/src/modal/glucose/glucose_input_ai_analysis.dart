class GlucoseInputAIAnalysis {
  final String id;
  final String message;

  GlucoseInputAIAnalysis({
    required this.id,
    required this.message,
  });

  factory GlucoseInputAIAnalysis.fromJson(Map<String, dynamic> json) {
    return GlucoseInputAIAnalysis(
      id: json['id'],
      message: json['message'],
    );
  }
}
