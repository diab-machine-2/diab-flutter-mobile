import 'medicine_tablet_model.dart';

class SearchMedicineResultModel {
  final int total;
  final List<MedicineTabletModel> data;

  SearchMedicineResultModel({
    required this.total,
    required this.data,
  });

  factory SearchMedicineResultModel.fromJson(Map<String, dynamic> json) {
    return SearchMedicineResultModel(
      total: json['total'] ?? 0,
      data: (json['data'] as List)
          .map((item) => MedicineTabletModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'data': data.map((item) => item.toJson()).toList(),
  };
}
