import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/modal/home/home_model.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/modal/medicine/medicine_schedule_model.dart';
import 'package:medical/src/modal/medicine/prescription_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/learning_post_response.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/learning/learning_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';
import 'package:medical/src/widget/home/welcome_package_screen/bloc/welcome_package_screen_cubit.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../modal/medicine/search_medicine_result_model.dart';
import '../../repo/medicine/medicine_client.dart';

part 'medicine_bloc_event.dart';
part 'medicine_bloc_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  MedicineBloc() : super(MedicineInitial()) {
    on<SearchMedicineEvent>(_onSearchMedicine);
    on<UploadPrescriptionPhotoEvent>(_onUploadPrescriptionPhoto);
    on<CreateNewPrescriptionEvent>(_onCreateNewPrescription);
    on<UpdatePrescriptionEvent>(_onUpdatePrescription);
    on<StopPrescriptionEvent>(_onStopPrescription);
    on<FetchPrescriptionsEvent>(_onFetchPrescriptions);
    on<FetchPrescriptionEvent>(_onFetchPrescription);
    on<FetchMedicineScheduleEvent>(_onFetchMedicineSchedule);
    on<UseMedicineEvent>(_onUseMedicine);
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

  Future<void> _onUploadPrescriptionPhoto(
      UploadPrescriptionPhotoEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.uploadPrescriptionPhoto(file: event.photo);
      emit(UploadPrescriptionPhotoSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }

  Future<void> _onCreateNewPrescription(
      CreateNewPrescriptionEvent event, Emitter<MedicineState> emit) async {
    emit(MedicineLoading());
    final client = MedicineClient();
    try {
      final result = await client.createNewPrescription(prescription: event.prescription);
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
      final result = await client.updatePrescription(prescription: event.prescription);
      emit(CreatePrescriptionSuccess(result));
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
      final result = await client.useMedicine(id: event.id);
      emit(UseMedicineSuccess(result));
    } catch (e) {
      emit(MedicineError(message: e.toString()));
    }
  }
}