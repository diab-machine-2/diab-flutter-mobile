import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/modal/medicine/medicine_item_model.dart';
import 'package:medical/src/model/request/medication_request_body.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/clinic_result_scan_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/benefit/benefit_availability_guard.dart';
import 'package:medical/src/repo/medicine/medicine_client.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

part 'benefit_service_request_state.dart';

enum BenefitServiceType { medicine, labTest }

class BenefitServiceRequestCubit extends Cubit<BenefitServiceRequestState> {
  final AppRepository _repository;
  final MedicineClient _medicineClient = MedicineClient();
  /// Originating [MyBenefitItem.itemId] when this flow started from a tap on
  /// a bundle item in `BenefitIntroduceBundlePage` — `null` otherwise. When
  /// set, a successful submit marks the item used via `useBenefitService`.
  final String? itemId;
  /// The item's raw wire `itemType` (see `BenefitBundleItemType.resolve`),
  /// passed through to `useBenefitService` alongside [itemId].
  final int? itemType;

  BenefitServiceRequestCubit(this._repository, {this.itemId, this.itemType})
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

      if (!await _submit(body.toJson())) return;
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

      if (!await _submit(body.toJson())) return;
      emit(const BenefitServiceRequestSubmitSuccess(
          type: BenefitServiceType.labTest));
    } catch (e) {
      emit(BenefitServiceRequestError(e.toString()));
    }
  }

  /// Submits the request and, when started from a bundle item, marks it
  /// used. Returns `true` once the submit succeeded (a failing mark-used is
  /// only logged) — otherwise it has already emitted
  /// [BenefitServiceRequestError] / [BenefitServiceRequestUnavailable], so
  /// the UI never shows a fake success.
  Future<bool> _submit(Map<String, dynamic> body) async {
    final bool fromBundle = itemId != null && itemType != null;
    // Don't submit against a bundle removed server-side since the flow began
    // (the guard shows the dialog and pops back to root).
    if (fromBundle && !await BenefitAvailabilityGuard.ensureAvailable()) {
      emit(const BenefitServiceRequestUnavailable());
      return false;
    }

    final submitResult = await _repository.submitMedicationRequest(body);
    if (submitResult is Failure<CommonResponse>) {
      emit(BenefitServiceRequestError(
          NetworkExceptions.getErrorMessage(submitResult.error)));
      return false;
    }

    if (fromBundle) {
      final useResult = await _repository.useBenefitService(
          itemId: itemId!, itemType: itemType!);
      // The request is already sent — surfacing an error here would invite a
      // retry that duplicates it, so only log and still report success.
      if (useResult is Failure<CommonResponse>) {
        debugPrint('[BenefitServiceRequestCubit] useBenefitService failed '
            'after submit (itemId=$itemId): '
            '${NetworkExceptions.getErrorMessage(useResult.error)}');
      }
    }
    return true;
  }
}
