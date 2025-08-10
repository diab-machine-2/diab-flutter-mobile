class Medicine {
  final String name;
  final String dosage;
  final int quantity;
  final String mealTime;
  final String frequency;
  final String time;
  final int dose;
  final String? note;

  Medicine({
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.mealTime,
    required this.frequency,
    required this.time,
    required this.dose,
    this.note,
  });
}