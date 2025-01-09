enum BloodSugarRangeType {
  very_low(1),
  low(2),
  normal(3),
  high(4),
  very_high(5),
  ;

  final int value;
  const BloodSugarRangeType(this.value);
}

extension BloodSugarRangeTypeExtension on BloodSugarRangeType {
  String get title => this.toString().split('.').last;
}
