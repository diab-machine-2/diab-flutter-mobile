part of 'medicine_bloc.dart';

@immutable
abstract class MedicineEvent {}

class SearchMedicineEvent extends MedicineEvent {
  final String searchText;
  SearchMedicineEvent(this.searchText);
}

class UploadPrescriptionPhotoEvent extends MedicineEvent {
  final File photo;
  UploadPrescriptionPhotoEvent(this.photo);
}

class CreateNewPrescriptionEvent extends MedicineEvent {
  final PrescriptionModel prescription;
  CreateNewPrescriptionEvent(this.prescription);
}

class UpdatePrescriptionEvent extends MedicineEvent {
  final PrescriptionModel prescription;
  UpdatePrescriptionEvent(this.prescription);
}

class StopPrescriptionEvent extends MedicineEvent {
  final String id;
  StopPrescriptionEvent(this.id);
}

class FetchPrescriptionsEvent extends MedicineEvent {
  FetchPrescriptionsEvent();
}

class FetchPrescriptionEvent extends MedicineEvent {
  final String id;
  FetchPrescriptionEvent(this.id);
}

class FetchMedicineScheduleEvent extends MedicineEvent {
  final int timestamp;
  FetchMedicineScheduleEvent(this.timestamp);
}

class UseMedicineEvent extends MedicineEvent {
  final String id;
  UseMedicineEvent(this.id);
}