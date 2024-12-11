import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_list_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';

class DsmesAppointmentCubit extends Cubit<DsmesAppointmentState> {
  final AppRepository appRepository;

  late List<DsmesAppointment> myAppointments = [];
  late List<DsmesAppointment> listFilteredData = [];
  late List<DsmesClinicModel> listClinic = [];

  DsmesClinicModel? selectedClinic;
  DsmesAppointment? currentDsmesAppointment;

  CreateDsmesBookingRequest? createDsmesBookingRequest;

  int currentPage = 1;
  bool hasMore = true;

  DsmesAppointmentCubit(this.appRepository)
      : super(InitialDsmesAppointmentState());

  Future<void> getDsmesAppointmentList(
      {int page = 1, bool isRefresh = false}) async {
    if (isRefresh) {
      // myAppointments.clear();
      currentPage = 1;
      hasMore = true;
    }

    if (!hasMore) return;

    emit(
        isRefresh ? InitialDsmesAppointmentState() : DsmesAppointmentLoading());
    ApiResult<GetDsmesAppointmentResponse> apiResult =
        await appRepository.getDsmesAppointmentList(page: page);
    apiResult.when(success: (GetDsmesAppointmentResponse response) {
      currentPage = page;
      hasMore = response.hasMore;

      if (isRefresh) {
        myAppointments = response.data;
        listFilteredData = _getFilteredData();
      } else {
        myAppointments.addAll(response.data);
        listFilteredData = _getFilteredData();
      }
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> getClinicList() async {
    emit(DsmesAppointmentLoading());
    ApiResult<DsmesClinicListResponse> apiResult =
        await appRepository.getClinicList();
    apiResult.when(success: (DsmesClinicListResponse response) {
      listClinic = response.data;

      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<void> getClinicDetail({required int id}) async {
    emit(DsmesAppointmentLoading());
    ApiResult<DsmesClinicDetailResponse> apiResult =
        await appRepository.getClinicDetail(id: id);
    apiResult.when(success: (DsmesClinicDetailResponse response) {
      setSelectedClinic(response.data);

      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  _getFilteredData() {
    List<DsmesAppointment> filteredData = myAppointments.where((data) {
      DateTime startTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.startTime);
      DateTime now = DateTime.now();
      DateTime threeDaysAgo = now.subtract(Duration(days: 3));

      return (
              // startTime.isAfter(now) &&
              (data.status == DSMES_STATUS_REQUEST ||
                  data.status == DSMES_STATUS_ON_HOLD)) ||
          (startTime.isAfter(threeDaysAgo) &&
              data.status == DSMES_STATUS_APPROVE);
    }).toList();
    return filteredData;
  }

  initCreateDsmesBookingRequest() {
    createDsmesBookingRequest = CreateDsmesBookingRequest(
      startTime: '',
      endTime: '',
      clinicId: selectedClinic!.id,
      doctorId: 0,
      patientPhoneNumber: AppSettings.userInfo?.phoneNumber ?? '',
      patientName: AppSettings.userInfo?.fullName ?? '',
      birthday: DateFormat('yyyy-MM-dd').format(
          DateTime.fromMillisecondsSinceEpoch(
              AppSettings.userInfo!.dateOfBirth! ~/ 1000)),
      patientGender: AppSettings.userInfo?.gender == 'Nam' ? 1 : 0,
      patientEmail: AppSettings.userInfo?.email ?? '',
      bookingForClinic: 1, // 1: Booking phòng khám, 2: Booking bác sĩ
      language: 'en',
    );
  }

  setSelectedClinic(DsmesClinicModel? clinic) {
    selectedClinic = clinic;
  }

  updateCreateDsmesBookingRequestTime(
      {required String startTime, required String endTime}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
        startTime: startTime, endTime: endTime);
  }

  String getItemTitle(DsmesAppointmentMode mode) {
    switch (mode) {
      case DsmesAppointmentMode.atClinic:
        return R.string.consult_at_clinic.tr();
      case DsmesAppointmentMode.telemedicine:
        return R.string.consult_online.tr();
      default:
        return '';
    }
  }

  String getItemStatus(String status, bool isPast) {
    switch (status) {
      case DSMES_STATUS_REQUEST:
      case DSMES_STATUS_ON_HOLD:
        return R.string.requested.tr();
      case DSMES_STATUS_APPROVE:
        return isPast ? R.string.completed.tr() : R.string.confirmed.tr();
      case DSMES_STATUS_REJECT:
        return R.string.rejected.tr();
      default:
        return '';
    }
  }

  Color getItemStatusTextColor(String status, bool isPast) {
    switch (status) {
      case DSMES_STATUS_REQUEST:
      case DSMES_STATUS_ON_HOLD:
        return R.color.color0xffD59200;
      case DSMES_STATUS_APPROVE:
        return isPast ? R.color.color0xff009D0D : R.color.color0xff004ED5;
      case DSMES_STATUS_REJECT:
        return R.color.color0xffDC0000;
      default:
        return R.color.textDark;
    }
  }
}
