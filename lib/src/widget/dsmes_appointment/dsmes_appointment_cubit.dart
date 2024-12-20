import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/request/dsmes_cancel_booking_request.dart';
import 'package:medical/src/model/request/dsmes_reschedule_request.dart';
import 'package:medical/src/model/request/register_docosan_user_request.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_dsmes_offline_booking_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_list_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_rating_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_detail_response.dart';
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
  late List<ClinicReview> listClinicReview = [];

  DsmesClinicModel? selectedClinic;
  DsmesAppointment? currentDsmesAppointment;

  CreateDsmesBookingRequest? createDsmesBookingRequest;

  int currentPage = 1;
  bool hasMore = true;

  DsmesAppointmentCubit(this.appRepository)
      : super(InitialDsmesAppointmentState());

  Future<void> initDsmesBooking() async {
    final isExist = await isExistDocosanUser();
    if (isExist) {
      await registerDocosanUser();
      await getDsmesAppointmentList();
    }
  }

  Future<bool> isExistDocosanUser() async {
    final phoneNumber = AppSettings.userInfo?.phoneNumber;
    if (phoneNumber == null) {
      return false;
    }
    final isExist =
        await appRepository.isExistDocosanUser(phoneNumber: phoneNumber);
    return isExist;
  }

  Future<void> registerDocosanUser() async {
    final phoneNumber = AppSettings.userInfo?.phoneNumber;
    if (phoneNumber == null) {
      return;
    }
    final displayName = AppSettings.userInfo?.fullName ?? '';
    final gender = AppSettings.userInfo?.gender == 'Nam' ? '1' : '0';
    final email = AppSettings.userInfo?.email ?? '';
    final request = RegisterDocosanUserRequest(
      phoneNumber: phoneNumber,
      displayName: displayName,
      gender: gender,
      isGetCaresOrderInfo: '0',
      email: email,
      type: 'patient',
      language: 'vi',
    );
    final resp = await appRepository.registerDocosanUser(request: request);
    if (resp != null) {
      updateCreateDsmesBookingRequestLanguage(language: resp.data.language);
      return;
    }
    return;
  }

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

  Future<List<DsmesClinicModel>> getClinicList() async {
    List<DsmesClinicModel> clinics = [];
    emit(DsmesAppointmentLoading());
    ApiResult<DsmesClinicListResponse> apiResult =
        await appRepository.getClinicList();
    apiResult.when(success: (DsmesClinicListResponse response) {
      listClinic = response.data;
      clinics = listClinic;

      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return clinics;
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

  Future<void> getClinicRate({required int id}) async {
    // emit(DsmesAppointmentLoading());
    ApiResult<DsmesClinicRatingResponse> apiResult =
        await appRepository.getClinicRate(id: id);
    apiResult.when(success: (DsmesClinicRatingResponse response) {
      listClinicReview = response.data.normalReview;
      // emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<DsmesAppointment?> createDsmesBooking() async {
    emit(DsmesAppointmentLoading());
    DsmesAppointment? dsmesAppointment;
    ApiResult<CreateDsmesOfflineBookingResponse> apiResult = await appRepository
        .createDsmesOfflineBooking(request: createDsmesBookingRequest!);
    apiResult.when(success: (CreateDsmesOfflineBookingResponse response) {
      print('CreateDsmesOfflineBookingResponse: ${response.data.toString()}');
      dsmesAppointment = response.data;
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      dsmesAppointment = null;
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return dsmesAppointment;
  }

  Future<DsmesAppointment?> getDsmesAppointmentDetail(
      {required int appointmentId}) async {
    emit(DsmesAppointmentLoading());
    DsmesAppointment? dsmesAppointment;
    ApiResult<GetDsmesAppointmentDetailResponse> apiResult = await appRepository
        .getDsmesAppointmentDetail(appointmentId: appointmentId);
    apiResult.when(success: (GetDsmesAppointmentDetailResponse response) {
      print('GetDsmesAppointmentDetailResponse: ${response.data}');
      dsmesAppointment = response.data;
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      dsmesAppointment = null;
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return dsmesAppointment;
  }

  Future<void> cancelDsmesAppointment(
      {required DsmesCancelBookingRequest request}) async {
    emit(DsmesAppointmentLoading());
    ApiResult<CommonResponse> apiResult =
        await appRepository.cancelDsmesBooking(request: request);
    apiResult.when(success: (CommonResponse response) {
      print('cancelDsmesAppointment: ${response.statusCode}');
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<DsmesAppointment?> rescheduleDsmesBooking(
      {required RescheduleDsmesBookingRequest request}) async {
    emit(DsmesAppointmentLoading());
    DsmesAppointment? dsmesAppointment;
    ApiResult<CreateDsmesOfflineBookingResponse> apiResult =
        await appRepository.rescheduleDsmesBooking(request: request);
    apiResult.when(success: (CreateDsmesOfflineBookingResponse response) {
      print('rescheduleDsmesBooking: ${response.data.toString()}');
      dsmesAppointment = response.data;
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      dsmesAppointment = null;
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return dsmesAppointment;
  }

  _getFilteredData() {
    List<DsmesAppointment> filteredData = myAppointments.where((data) {
      DateTime startTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.startTime);
      DateTime now = DateTime.now();
      DateTime threeDaysAgo = now.subtract(Duration(days: 3));

      return ((data.status == DSMES_STATUS_REQUEST ||
              data.status == DSMES_STATUS_ON_HOLD)) ||
          (
              // startTime.isAfter(threeDaysAgo) &&
              data.status == DSMES_STATUS_APPROVE);
    }).toList();
    return filteredData;
  }

  initCreateDsmesBookingRequest({String locale = 'vi'}) {
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
      patientGender: AppSettings.userInfo?.gender == 'Male' ? 1 : 0,
      patientEmail: AppSettings.userInfo?.email ?? '',
      bookingForClinic: 1, // 1: Booking phòng khám, 2: Booking bác sĩ
      language: locale,
      symptom: '',
      symptomAttachment: [],
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

  updateCreateDsmesBookingRequestRequesterInfo(
      {required String name, required String phone}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
        patientName: name, patientPhoneNumber: phone);
  }

  updateCreateDsmesBookingRequestLanguage({required String language}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
      language: language,
    );
  }

  updateCreateDsmesBookingRequestSymptom({required String symptom}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
      symptom: symptom,
    );
  }

  updateCreateDsmesBookingRequest(
      {required CreateDsmesBookingRequest request}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
      startTime: request.startTime,
      endTime: request.endTime,
      clinicId: request.clinicId,
      doctorId: request.doctorId,
      patientPhoneNumber: request.patientPhoneNumber,
      patientName: request.patientName,
      birthday: request.birthday,
      patientGender: request.patientGender,
      patientEmail: request.patientEmail,
      bookingForClinic: request.bookingForClinic,
      language: request.language,
      symptom: request.symptom,
      symptomAttachment: request.symptomAttachment,
    );
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

  Color getItemStatusContainerColor(String status, bool isPast) {
    switch (status) {
      case DSMES_STATUS_REQUEST:
      case DSMES_STATUS_ON_HOLD:
        return R.color.color0xffFAF0D2;
      case DSMES_STATUS_APPROVE:
        return isPast ? R.color.color0xffEAFFEC : R.color.color0xffD1E2FF;
      case DSMES_STATUS_REJECT:
        return R.color.color0xffFFE9E9;
      default:
        return R.color.white;
    }
  }
}
