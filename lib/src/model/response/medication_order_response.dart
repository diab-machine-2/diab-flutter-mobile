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

class Medication {
  final String name;
  final String quantity;

  Medication({required this.name, required this.quantity});
}

@JsonSerializable()
class MedicationOrderItem {
  final String? id;
  final String? code;
  final String? patientId;
  final String? accountId;
  final String? ocrType;
  final String? medicationName;
  final String? quantity;
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

  /// Splits a comma-separated string respecting parentheses nesting.
  static List<String> _splitTopLevelCommas(String input) {
    final result = <String>[];
    int depth = 0;
    int start = 0;
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '(') {
        depth++;
      } else if (char == ')') {
        depth--;
      } else if (char == ',' && depth == 0) {
        result.add(input.substring(start, i));
        start = i + 1;
      }
    }
    if (start < input.length) {
      result.add(input.substring(start));
    }
    return result;
  }

  /// Parses [medicationName] and [quantity] (both comma-separated strings)
  /// into a list of [Medication] objects, matched by position.
  List<Medication> get medications {
    if (medicationName == null || medicationName!.isEmpty) return [];
    final names = _splitTopLevelCommas(medicationName!);
    List<String> quantities;
    if (quantity == null || quantity!.isEmpty) {
      quantities = List.filled(names.length, '');
    } else {
      quantities = quantity!.split(',');
    }
    final result = <Medication>[];
    final len = names.length < quantities.length ? names.length : quantities.length;
    for (var i = 0; i < len; i++) {
      result.add(Medication(
        name: names[i].trim(),
        quantity: quantities[i].trim(),
      ));
    }
    return result;
  }

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
