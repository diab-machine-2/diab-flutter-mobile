// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationOrderResponse _$MedicationOrderResponseFromJson(
        Map<String, dynamic> json) =>
    MedicationOrderResponse(
      total: (json['total'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      size: (json['size'] as num?)?.toInt(),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => MedicationOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MedicationOrderResponseToJson(
        MedicationOrderResponse instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'size': instance.size,
      'items': instance.items,
    };

MedicationOrderItem _$MedicationOrderItemFromJson(Map<String, dynamic> json) =>
    MedicationOrderItem(
      id: json['id'] as String?,
      code: json['code'] as String?,
      patientId: json['patientId'] as String?,
      accountId: json['accountId'] as String?,
      ocrType: json['ocrType'] as String?,
      medicationName: json['medicationName'] as String?,
      quantity: json['quantity'] as String?,
      prescriptionName: json['prescriptionName'] as String?,
      diagnose: json['diagnose'] as String?,
      servicesRequest: json['servicesRequest'] as String?,
      gptParsedResult: json['gptParsedResult'] as String?,
      isSuccess: (json['isSuccess'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      note: json['note'] as String?,
      createDatetime: (json['createDatetime'] as num?)?.toInt(),
      updateDatetime: (json['updateDatetime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MedicationOrderItemToJson(
        MedicationOrderItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'patientId': instance.patientId,
      'accountId': instance.accountId,
      'ocrType': instance.ocrType,
      'medicationName': instance.medicationName,
      'quantity': instance.quantity,
      'prescriptionName': instance.prescriptionName,
      'diagnose': instance.diagnose,
      'servicesRequest': instance.servicesRequest,
      'gptParsedResult': instance.gptParsedResult,
      'isSuccess': instance.isSuccess,
      'imageUrl': instance.imageUrl,
      'note': instance.note,
      'createDatetime': instance.createDatetime,
      'updateDatetime': instance.updateDatetime,
    };
