import 'medicine_item_model.dart';

class SearchMedicineResultModel {
  final int total;
  final List<MedicineItemModel> data;

  SearchMedicineResultModel({
    required this.total,
    required this.data,
  });

  factory SearchMedicineResultModel.fromJson(Map<String, dynamic> json) {
    return SearchMedicineResultModel(
      total: json['total'] ?? 0,
      data: (json['data'] as List)
          .map((item) => MedicineItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total': total,
    'data': data.map((item) => item.toJson()).toList(),
  };
}
