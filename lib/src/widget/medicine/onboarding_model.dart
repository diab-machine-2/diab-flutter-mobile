class MedicineScheduleItem {
  // T2, T3, T4...
  String dayInWeek;
  // 21/08
  String date;
  bool isToday;
  List<MedicineSession> medicineSessions;

  MedicineScheduleItem({
    required this.dayInWeek,
    required this.date,
    required this.isToday,
    required this.medicineSessions,
  });
}

enum Session {
  MORNING, NOON, AFTERNOON, NIGHT
}

// Use medicine in Morning, Noon...
class MedicineSession {
  String name;
  String time;
  Session sessionType;
  List<DosageInSession> dosages;

  MedicineSession({
    required this.name,
    required this.time,
    required this.sessionType,
    required this.dosages,
  });
}

class DosageInSession {
  String name;
  double quantity;
  String unit;
  bool isUsed;
  // E.g. "Trước ăn", "Sau ăn", "Trong khi ăn"
  String timeOfUse;

  DosageInSession({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isUsed,
    required this.timeOfUse,
  });
}

class PrescriptionItem {
  // Ngưng thuốc
  bool isStopped;
  // Thuốc đã hết
  bool isOutOf;
  // Ngày lập
  String createdDate;
  String name;
  List<DosageSimpleItem> dosages;
  String description;
  String? photoUrl;

  PrescriptionItem({
    required this.isStopped,
    required this.isOutOf,
    required this.createdDate,
    required this.name,
    required this.dosages,
    required this.description,
    this.photoUrl,
  });
}

class DosageSimpleItem {
  String name;
  String imageUrl;
  double quantity;
  String unit;

  DosageSimpleItem({
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.unit,
  });
}
