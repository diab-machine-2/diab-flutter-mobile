import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/medicine/medicine_schedule_model.dart';
import 'package:medical/src/modal/medicine/prescription_model.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../modal/medicine/medicine_item_model.dart';
import '../../modal/medicine/search_medicine_result_model.dart';
import '../../repo/medicine/medicine_client.dart';

part 'medicine_bloc_event.dart';
part 'medicine_bloc_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  MedicineBloc() : super(MedicineInitial()) {
    on<SearchMedicineEvent>(_onSearchMedicine);
    on<AddNewMedicineEvent>(_onAddNewMedicine);
    on<UploadPrescriptionPhotoEvent>(_onUploadPrescriptionPhoto);
    on<CreateNewPrescriptionEvent>(_onCreateNewPrescription);
    on<UpdatePrescriptionEvent>(_onUpdatePrescription);
    on<StopPrescriptionEvent>(_onStopPrescription);
    on<FetchPrescriptionsEvent>(_onFetchPrescriptions);
    on<FetchPrescriptionEvent>(_onFetchPrescription);
    on<FetchMedicineScheduleEvent>(_onFetchMedicineSchedule);
    on<UseMedicineEvent>(_onUseMedicine);
    on<UseMedicinesEvent>(_onUseMedicines);
  }

  Future<void> _onSearchMedicine(
      SearchMedicineEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.searchMedicine(searchText: event.searchText);
      emit(MedicineSearchSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onAddNewMedicine(
      AddNewMedicineEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.addNewMedicine(medicineName: event.medicineName);
      emit(MedicineSearchSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onUploadPrescriptionPhoto(
      UploadPrescriptionPhotoEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.uploadPrescriptionPhoto(file: event.photo);
      if (result != null) {
        emit(UploadPrescriptionPhotoSuccess(result));
      } else {
        emit(MedicineError(message: R.string.can_not_read_prescription.tr()));
      }
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onCreateNewPrescription(
      CreateNewPrescriptionEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.createNewPrescription(prescription: event.prescription, paths: event.paths);
      emit(CreatePrescriptionSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePrescription(
      UpdatePrescriptionEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.updatePrescription(prescription: event.prescription, paths: event.paths);
      emit(UpdatePrescriptionSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }


  Future<void> _onFetchPrescriptions(FetchPrescriptionsEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.fetchPrescriptions();
      emit(FetchPrescriptionsSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onFetchPrescription(FetchPrescriptionEvent event, Emitter<MedicineState> emit) async {
    final client = MedicineClient();
    try {
      final result = await client.fetchPrescription(id: event.id);
      emit(FetchPrescriptionSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onStopPrescription(StopPrescriptionEvent event, Emitter<MedicineState> emit) async {
    final client = MedicineClient();
    try {
      final result = await client.stopPrescription(id: event.id);
      emit(StopPrescriptionSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onFetchMedicineSchedule(FetchMedicineScheduleEvent event, Emitter<MedicineState> emit) async {
    final client = MedicineClient();
    try {
      final result = await client.fetchMedicineScheduleByDate(timestamp: event.timestamp);
      emit(FetchMedicineScheduleSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onUseMedicine(UseMedicineEvent event, Emitter<MedicineState> emit) async {
    final client = MedicineClient();
    try {
      final result = await client.useMedicine(id: event.id, patientMedicationId: event.patientMedicationId, dosage: event.dosage);
      emit(UseMedicineSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onUseMedicines(UseMedicinesEvent event, Emitter<MedicineState> emit) async {
    final client = MedicineClient();
    bool result = false;
    try {
      for (final id in event.ids) {
        result = await client.useMedicine(id: id, patientMedicationId: id, dosage: 1);
      }

      emit(UseMedicinesSuccess(true));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }
}