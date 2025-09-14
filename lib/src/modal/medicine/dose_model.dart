class DosageModel {
  // E.g. "Trước ăn", "Sau ăn", "Trong khi ăn"
  final String momentName;
  final int moment;
  // E.g. "Mỗi ngày", "Ngày trong tuần", "Cách ngày"
  final String frequencyName;
  final int frequency;

  // Use for "Mỗi ngày"
  final double quantityInMorning;
  final double quantityInNoon;
  final double quantityInAfternoon;
  final double quantityInNight;

  // Used for "Ngày trong tuần"
  final List<int> selectedDaysInWeek;
  final double quantityForDaysInWeek;

  // Used for "Cách ngày"
  final int everyOtherDayNumber;
  final double quantityForEveryOtherDay;

  DosageModel({
    required this.momentName,
    required this.frequencyName,

    this.moment = 1,
    this.frequency = 1,

    this.quantityInMorning = 0.0,
    this.quantityInNoon = 0.0,
    this.quantityInAfternoon = 0.0,
    this.quantityInNight = 0.0,

    this.selectedDaysInWeek = const [],
    this.quantityForDaysInWeek = 0.0,

    this.everyOtherDayNumber = 0,
    this.quantityForEveryOtherDay = 0,
  });

  factory DosageModel.fromJson(Map<String, dynamic> json) {
    return DosageModel(
      momentName: json['momentName'] ?? '',
      frequencyName: json['frequencyName'] ?? '',
      moment: json['moment'] ?? '',
      frequency: json['frequency'] ?? '',
      quantityInMorning: (json['quantityInMorning'] ?? 0).toDouble(),
      quantityInNoon: (json['quantityInNoon'] ?? 0).toDouble(),
      quantityInAfternoon: (json['quantityInAfternoon'] ?? 0).toDouble(),
      quantityInNight: (json['quantityInNight'] ?? 0).toDouble(),
      selectedDaysInWeek: List<int>.from(json['selectedDaysInWeek'] ?? []),
      quantityForDaysInWeek: (json['quantityForDaysInWeek'] ?? 0).toDouble(),
      everyOtherDayNumber: json['everyOtherDayNumber'] ?? 0,
      quantityForEveryOtherDay: (json['quantityForEveryOtherDay'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'momentName': momentName,
    'frequencyName': frequencyName,
    'moment': moment,
    'frequency': frequency,
    'quantityInMorning': quantityInMorning,
    'quantityInNoon': quantityInNoon,
    'quantityInAfternoon': quantityInAfternoon,
    'quantityInNight': quantityInNight,
    'selectedDaysInWeek': selectedDaysInWeek,
    'quantityForDaysInWeek': quantityForDaysInWeek,
    'everyOtherDayNumber': everyOtherDayNumber,
    'quantityForEveryOtherDay': quantityForEveryOtherDay,
  };
}