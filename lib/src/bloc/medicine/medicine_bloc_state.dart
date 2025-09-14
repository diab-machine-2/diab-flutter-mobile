part of 'medicine_bloc.dart';

@immutable
abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineNoData extends MedicineState {}

class MedicineError extends MedicineState {
  final String? message;

  MedicineError({
    required this.message,
  });
}

class MedicineLoading extends MedicineState {

}

class MedicineLoaded extends MedicineState {
  
}

class MedicineSearchSuccess extends MedicineState {
  final SearchMedicineResultModel? searchResult;

  MedicineSearchSuccess(this.searchResult);
}

class UploadPrescriptionPhotoSuccess extends MedicineState {
  final bool createResult;

  UploadPrescriptionPhotoSuccess(this.createResult);
}

class CreatePrescriptionSuccess extends MedicineState {
  final bool createResult;

  CreatePrescriptionSuccess(this.createResult);
}

class UpdatePrescriptionSuccess extends MedicineState {
  final bool createResult;

  UpdatePrescriptionSuccess(this.createResult);
}

class StopPrescriptionSuccess extends MedicineState {
  final bool createResult;

  StopPrescriptionSuccess(this.createResult);
}

class FetchPrescriptionsSuccess extends MedicineState {
  final List<PrescriptionModel> prescriptionsResult;

  FetchPrescriptionsSuccess(this.prescriptionsResult);
}

class FetchPrescriptionSuccess extends MedicineState {
  final PrescriptionModel prescriptionResult;

  FetchPrescriptionSuccess(this.prescriptionResult);
}

class FetchMedicineScheduleSuccess extends MedicineState {
  final MedicineScheduleModel medicineScheduleResult;

  FetchMedicineScheduleSuccess(this.medicineScheduleResult);

  @override
  List<Object?> get props => [medicineScheduleResult.daily];
}

class UseMedicineSuccess extends MedicineState {
  final bool isSuccess;

  UseMedicineSuccess(this.isSuccess);
}