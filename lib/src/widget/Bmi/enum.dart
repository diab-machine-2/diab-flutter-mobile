
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

  static const _mapRequestValue = {
    BmiDateFilterType.aWeek: 1,
    BmiDateFilterType.twoWeeks: 2,
    BmiDateFilterType.aMonth: 3,
    BmiDateFilterType.threeMonths: 4,
  };

  int get days => _mapDate[this]!;

  int get requestValue => _mapRequestValue[this]!;
}