
class MedicineItemModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final int status;
  final int isDeleted;

  MedicineItemModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.status,
    required this.isDeleted,
  });

  factory MedicineItemModel.fromJson(Map<String, dynamic> json) {
    return MedicineItemModel(
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