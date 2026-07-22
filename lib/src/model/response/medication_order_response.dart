import 'package:json_annotation/json_annotation.dart';

part 'medication_order_response.g.dart';

@JsonSerializable()
class MedicationOrderResponse {
  final int? total;
  final int? page;
  final int? size;
  final List<MedicationOrderItem>? items;

  MedicationOrderResponse({
    this.total,
    this.page,
    this.size,
    this.items,
  });

  factory MedicationOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicationOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationOrderResponseToJson(this);
}

@JsonSerializable()
class MedicationOrderItem {
  final String? id;
  final String? code;
  final String? patientId;
  final String? accountId;
  final String? ocrType;
  final String? medicationName;
  final num? quantity;
  final String? prescriptionName;
  final String? diagnose;
  final String? servicesRequest;
  final String? gptParsedResult;
  final int? isSuccess;
  final String? imageUrl;
  final String? note;
  final int? createDatetime;
  final int? updateDatetime;

  MedicationOrderItem({
    this.id,
    this.code,
    this.patientId,
    this.accountId,
    this.ocrType,
    this.medicationName,
    this.quantity,
    this.prescriptionName,
    this.diagnose,
    this.servicesRequest,
    this.gptParsedResult,
    this.isSuccess,
    this.imageUrl,
    this.note,
    this.createDatetime,
    this.updateDatetime,
  });

  bool get isMedicine => ocrType == 'prescription';
  bool get isLabTest => ocrType == 'result_clinic';

  DateTime? get createDate => createDatetime != null
      ? DateTime.fromMillisecondsSinceEpoch(createDatetime! * 1000)
      : null;

  List<String> get parsedServices {
    if (servicesRequest == null || servicesRequest!.isEmpty) return [];
    try {
      final raw = servicesRequest!.trim();
      if (raw.startsWith('[')) {
        final content = raw.substring(1, raw.length - 1);
        return content
            .split(',')
            .map((s) => s.trim().replaceAll('"', ''))
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [raw];
    } catch (_) {
      return [];
    }
  }

  factory MedicationOrderItem.fromJson(Map<String, dynamic> json) =>
      _$MedicationOrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationOrderItemToJson(this);
}
