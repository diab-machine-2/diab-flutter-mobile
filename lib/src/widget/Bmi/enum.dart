
enum BmiDateFilterType {
  aWeek,
  twoWeeks,
  aMonth,
  threeMonths
}

extension BmiDateFilterTypeExt on BmiDateFilterType {
  static const _mapDate = {
    BmiDateFilterType.aWeek: 7,
    BmiDateFilterType.twoWeeks: 14,
    BmiDateFilterType.aMonth: 30,
    BmiDateFilterType.threeMonths: 90,
  };

  int get days => _mapDate[this]!;
}