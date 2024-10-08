class GlucoseData {
  final double glucose;
  final int date;

  GlucoseData({dynamic glucose, dynamic date})
      : glucose = double.tryParse(glucose) ?? 0,
        date = int.tryParse(date) ?? 0;

  // toJson
  Map<String, String> toJson() {
    return {
      'glucose': glucose.toString(),
      'date': date.toString(),
    };
  }
}
