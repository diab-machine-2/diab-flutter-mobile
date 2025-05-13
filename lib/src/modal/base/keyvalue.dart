class KeyValue {
  final String key;
  final String value;

  const KeyValue({
    required this.key,
    required this.value,
  });

  factory KeyValue.fromJson(Map<String, dynamic> json) {
    return KeyValue(
      key: json['key'],
      value: json['value'],
    );
  }

  static List<KeyValue> toList(List<dynamic> items) {
    return items.map((item) => KeyValue.fromJson(item)).toList();
  }
}
