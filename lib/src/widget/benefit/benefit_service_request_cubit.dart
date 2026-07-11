import 'dart:convert';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/medicine/medicine_item_model.dart';
import 'package:medical/src/model/request/medication_request_body.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/clinic_result_scan_response.dart';
import 'package:medical/src/repo/medicine/medicine_client.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

part 'benefit_service_request_state.dart';

enum BenefitServiceType { medicine, labTest }

class BenefitServiceRequestCubit extends Cubit<BenefitServiceRequestState> {
  final AppRepository _repository;
  final MedicineClient _medicineClient = MedicineClient();

  BenefitServiceRequestCubit(this._repository)
      : super(const BenefitServiceRequestInitial());

  // ── Scan prescription (medicine) ──────────────────────────────────────────

  Future<void> scanPrescription({required File image}) async {
    emit(const BenefitServiceRequestLoading());
    try {
      final medicines = await _medicineClient.uploadPrescriptionPhoto(file: image);
      emit(BenefitScanMedicineSuccess(
        medicines: medicines ?? [],
        capturedImage: image,
      ));
    } catch (e) {
      emit(BenefitServiceRequestError(e.toString()));
    }
  }

  // ── Scan clinic result (lab test) ─────────────────────────────────────────

  Future<void> scanClinicResult({required File image}) async {
    emit(const BenefitServiceRequestLoading());
    try {
      final client = FetchClient();
      final response = await client.postHttp(
        path: '/App/Image/UploadAI/ClinicResult',
        files: [image.path],
        params: {'filePath': image.path},
      );

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final json = jsonDecode(data) as Map<String, dynamic>;
        final result = ClinicResultScanResponse.fromJson(json);
        emit(BenefitScanLabTestSuccess(
          scanData: result.data,
          capturedImage: image,
        ));
      } else {
        throw response.reasonPhrase ?? 'Unknown error';
      }
    } catch (e) {
      emit(BenefitServiceRequestError(e.toString()));
    }
  }

  // ── Submit request ─────────────────────────────────────────────────────────

  Future<void> submitMedicineRequest({
    required List<MedicineItemModel> selectedMedicines,
    required String gptParsedResult,
    required String? imageUrl,
    required String? note,
  }) async {
    emit(const BenefitServiceRequestLoading());
    try {
      final now = DateTime.now();
      final prescriptionName =
          'Đơn thuốc ngày ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final medicationNames =
          selectedMedicines.map((m) => m.medicationName ?? '').join(',');
      final quantities =
          selectedMedicines.map((m) => m.amount?.toString() ?? '').join(',');

      final body = MedicationRequestBody(
        ocrType: 'prescription',
        prescriptionName: prescriptionName,
        medicationName: medicationNames,
        quantity: quantities,
        gptParsedResult: gptParsedResult,
        imageUrl: imageUrl,
        isSuccess: 1,
        note: note,
      );

      await _repository.submitMedicationRequest(body.toJson());
      emit(const BenefitServiceRequestSubmitSuccess(
          type: BenefitServiceType.medicine));
    } catch (e) {
      emit(BenefitServiceRequestError(e.toString()));
    }
  }

  Future<void> submitLabTestRequest({
    required List<String> selectedServices,
    required String? diagnose,
    required String gptParsedResult,
    required String? imageUrl,
    required String? note,
  }) async {
    emit(const BenefitServiceRequestLoading());
    try {
      final servicesJson = jsonEncode(selectedServices);

      final body = MedicationRequestBody(
        ocrType: 'result_clinic',
        diagnose: diagnose,
        servicesRequest: servicesJson,
        gptParsedResult: gptParsedResult,
        imageUrl: imageUrl,
        isSuccess: 1,
        note: note,
      );

      await _repository.submitMedicationRequest(body.toJson());
      emit(const BenefitServiceRequestSubmitSuccess(
          type: BenefitServiceType.labTest));
    } catch (e) {
      emit(BenefitServiceRequestError(e.toString()));
    }
  }
}
