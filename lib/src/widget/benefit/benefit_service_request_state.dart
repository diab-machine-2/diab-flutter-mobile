part of 'benefit_service_request_cubit.dart';

sealed class BenefitServiceRequestState {
  const BenefitServiceRequestState();
}

class BenefitServiceRequestInitial extends BenefitServiceRequestState {
  const BenefitServiceRequestInitial();
}

class BenefitServiceRequestLoading extends BenefitServiceRequestState {
  const BenefitServiceRequestLoading();
}

class BenefitScanMedicineSuccess extends BenefitServiceRequestState {
  final List<MedicineItemModel> medicines;
  final File capturedImage;

  const BenefitScanMedicineSuccess({
    required this.medicines,
    required this.capturedImage,
  });
}

class BenefitScanLabTestSuccess extends BenefitServiceRequestState {
  final ClinicResultScanData? scanData;
  final File capturedImage;

  const BenefitScanLabTestSuccess({
    required this.scanData,
    required this.capturedImage,
  });
}

class BenefitServiceRequestSubmitSuccess extends BenefitServiceRequestState {
  final BenefitServiceType type;

  const BenefitServiceRequestSubmitSuccess({required this.type});
}

class BenefitServiceRequestError extends BenefitServiceRequestState {
  final String message;

  const BenefitServiceRequestError(this.message);
}
