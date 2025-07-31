class MedicationModel {
  final String id;
  final String name;
  final int quantity;
  final String usage;
  final String frequency;
  final List<String> times; // ["Sáng", "Tối"]
  final String? note;

  MedicationModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.usage,
    required this.frequency,
    required this.times,
    this.note,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      usage: json['usage'],
      frequency: json['frequency'],
      times: List<String>.from(json['times']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'usage': usage,
    'frequency': frequency,
    'times': times,
    'note': note,
  };
}