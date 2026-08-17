class GlucoseData {
  final double glucose;
  final int date;
  final String? timeFrameId;

  GlucoseData({dynamic glucose, dynamic date, this.timeFrameId})
      : glucose = double.tryParse(glucose) ?? 0,
        date = int.tryParse(date) ?? 0;

  // toJson
  Map<String, String> toJson() {
    final json = {
      'glucose': glucose.toString(),
      'date': date.toString(),
    };
    if (timeFrameId != null && timeFrameId!.isNotEmpty) {
      json['timeFrameId'] = timeFrameId!;
    }
    return json;
  }
}
