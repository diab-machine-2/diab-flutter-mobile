part of 'medicine_bloc.dart';

@immutable
abstract class MedicineEvent {}

class SearchMedicineEvent extends MedicineEvent {
  final String searchText;
  SearchMedicineEvent(this.searchText);
}

class AddNewMedicineEvent extends MedicineEvent {
  final String medicineName;
  AddNewMedicineEvent(this.medicineName);
}

class UploadPrescriptionPhotoEvent extends MedicineEvent {
  final File photo;
  UploadPrescriptionPhotoEvent(this.photo);
}

class CreateNewPrescriptionEvent extends MedicineEvent {
  final PrescriptionModel prescription;
  final Map<String, String>? paths;
  CreateNewPrescriptionEvent(this.prescription, this.paths);
}

class UpdatePrescriptionEvent extends MedicineEvent {
  final PrescriptionModel prescription;
  final Map<String, String>? paths;
  UpdatePrescriptionEvent(this.prescription, this.paths);
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
  final String patientMedicationId;
  final double dosage;
  UseMedicineEvent(this.id, this.patientMedicationId, this.dosage);
}

class UseMedicinesEvent extends MedicineEvent {
  final List<String> ids;
  UseMedicinesEvent(this.ids);
}