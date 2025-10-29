
class MedicineTabletModel {
  final String? id;
  final String? code;
  final String name;
  final String? description;
  final int? status;
  final int? isDeleted;

  MedicineTabletModel({
    this.id,
    this.code,
    required this.name,
    this.description,
    this.status,
    this.isDeleted,
  });

  factory MedicineTabletModel.fromJson(Map<String, dynamic> json) {
    return MedicineTabletModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 0,
      isDeleted: json['isDeleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
    'status': status,
    'isDeleted': isDeleted,
  };
}