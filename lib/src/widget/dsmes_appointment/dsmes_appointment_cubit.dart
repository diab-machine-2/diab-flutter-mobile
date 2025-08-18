import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/request/dsmes_cancel_booking_request.dart';
import 'package:medical/src/model/request/dsmes_reschedule_request.dart';
import 'package:medical/src/model/request/get_booking_clinic_list_request.dart';
import 'package:medical/src/model/request/register_docosan_user_request.dart';
import 'package:medical/src/model/request/save_vnpay_transaction_request.dart';
import 'package:medical/src/model/response/clinic_specialty_list_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_dsmes_offline_booking_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_list_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_rating_response.dart';
import 'package:medical/src/model/response/get_diab_clinics_schedule_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_detail_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_response.dart';
import 'package:medical/src/model/response/get_vnpay_transaction_info_response.dart';
import 'package:medical/src/model/response/search_list_clinic_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/booking_clinic/helper/booking_clinic_helper.dart';
import 'package:medical/src/widget/booking_clinic/model/booking_clinic_provider_model.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/helper/http_helper.dart';

class DsmesAppointmentCubit extends Cubit<DsmesAppointmentState> {
  final AppRepository appRepository;

  late List<DsmesAppointment> myAppointments = [];
  late List<DsmesAppointment> listFilteredData = [];
  late List<DsmesClinicModel> listClinic = [];
  late List<ClinicReview> listClinicReview = [];
  late List<ClinicSpecialty> listSpecialty = [];
  late List<BookingClinicProvider> listBookingClinicProvider = [];

  DsmesClinicModel? selectedClinic;
  DsmesAppointment? currentDsmesAppointment;

  CreateDsmesBookingRequest? createDsmesBookingRequest;
  SearchBookingClinicListRequest? searchBookingClinicListRequest;

  int currentPage = 1;
  bool hasMore = true;
  bool isSpecifyClinic = false;

  int clinicProviderCurrentPage = 1;
  bool clinicProviderHasMore = true;

  DsmesAppointmentCubit(this.appRepository)
      : super(InitialDsmesAppointmentState());

  Future<void> initDsmesBooking() async {
    // emit(DsmesAppointmentLoading());
    final isExist = await isExistDocosanUser();
    if (isExist) {
      final phoneNumber = AppSettings.userInfo?.phoneNumber;
      if (phoneNumber == null) {
        return;
      }
      await registerDocosanUser(
          phoneNumber: Utils.formatPhoneNumber(phoneNumber));

      await _initDeviceLocation();

      await getDsmesAppointmentList(showLoading: false);
    }
    emit(DsmesAppointmentLoaded());
  }

  Future<void> _initDeviceLocation() async {
    final position = await AppSettings.getPositionPreferences();
    if (position == null || position.isEmpty) {
      final geolocation = await determinePosition();
      if (geolocation != null) {
        await AppSettings.saveLocationPreferences(geolocation);
      }
    }
  }

  Future<bool> isExistDocosanUser() async {
    final phoneNumber = AppSettings.userInfo?.phoneNumber;
    if (phoneNumber == null) {
      return false;
    }
    final isExist = await appRepository.isExistDocosanUser(
        phoneNumber: Utils.formatPhoneNumber(phoneNumber));
    return isExist;
  }

  Future<void> registerDocosanUser({required String phoneNumber}) async {
    if (phoneNumber.isEmpty || phoneNumber == null) {
      return;
    }
    final displayName = AppSettings.userInfo?.fullName ?? '';
    final gender = AppSettings.userInfo?.gender == 'Nam' ? '1' : '2';
    final email = AppSettings.userInfo?.email ?? '';
    final request = RegisterDocosanUserRequest(
      phoneNumber: Utils.formatPhoneNumber(phoneNumber),
      displayName: displayName.length <= 6 ? "$displayName-$phoneNumber" : displayName,
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
    } else {
      BotToast.closeAllLoading();
    }
    return;
  }

  void clearAppointments() {
    myAppointments.clear();
    listFilteredData.clear();
    currentPage = 1;
    hasMore = true;
  }

  void clearClinicProviders() {
    listBookingClinicProvider.clear();
    clinicProviderCurrentPage = 1;
    clinicProviderHasMore = true;
  }

  Future<void> getDsmesAppointmentList(
      {int page = 1, bool isRefresh = false, bool showLoading = true}) async {
    if (isRefresh) {
      myAppointments.clear();
      currentPage = 1;
      hasMore = true;
    }

    if (!hasMore) return;

    emit(
      showLoading ? DsmesAppointmentLoading() : InitialDsmesAppointmentState(),
    );

    ApiResult<GetDsmesAppointmentResponse> apiResult =
        await appRepository.getDsmesAppointmentList(page: page);
    apiResult.when(success: (GetDsmesAppointmentResponse response) {
      currentPage = page;
      hasMore = response.hasMore;

      if (isRefresh) {
        myAppointments = response.data;
        listFilteredData = _getMostRelevantAppointment();
      } else {
        myAppointments.addAll(response.data);
        listFilteredData = _getMostRelevantAppointment();
      }
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
  }

  Future<List<DsmesClinicModel>> getClinicList({String? type}) async {
    List<DsmesClinicModel> clinics = [];
    emit(DsmesAppointmentLoading());
    ApiResult<DsmesClinicListResponse> apiResult =
        await appRepository.getClinicList(type: type);
    apiResult.when(success: (DsmesClinicListResponse response) {
      listClinic = response.data;
      clinics = listClinic;

      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return clinics;
  }

  Future<bool> getClinicDetail({required int id, bool isLoading = true}) async {
    if (isLoading) {
      emit(DsmesAppointmentLoading());
    }
    ApiResult<DsmesClinicDetailResponse> apiResult =
        await appRepository.getClinicDetail(id: id);
    return apiResult.when(success: (DsmesClinicDetailResponse response) {
      setSelectedClinic(response.data);
      emit(DsmesAppointmentLoaded());
      return true;
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
      return false;
    });
  }

  Future<bool> getClinicRate({required int id}) async {
    ApiResult<DsmesClinicRatingResponse> apiResult =
        await appRepository.getClinicRate(id: id);

    return apiResult.when(success: (DsmesClinicRatingResponse response) {
      listClinicReview = response.data.normalReview;
      return true;
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
      return false;
    });
  }

  Future<List<BookingSchedule>> getDiabClinicsSchedule() async {
    emit(DsmesAppointmentLoading());
    List<BookingSchedule> bookingSchedules = [];
    ApiResult<GetDiabClinicsScheduleResponse> apiResult =
        await appRepository.getDiabClinicsSchedule();
    apiResult.when(success: (GetDiabClinicsScheduleResponse response) {
      bookingSchedules = response.getMergedSchedules();
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return bookingSchedules;
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

  String ensureTimeWithSeconds(String dateTime) {
    // Check if datetime matches yyyy-MM-dd HH:mm format
    final dateTimeFormat = RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$');
    if (dateTimeFormat.hasMatch(dateTime)) {
      return "$dateTime:00";
    }
    return dateTime;
  }

  Future<DsmesAppointment?> createDsmesBookingOnline() async {
    emit(DsmesAppointmentLoading());
    DsmesAppointment? dsmesAppointment;
    String startTimeWithSeconds =
        ensureTimeWithSeconds(createDsmesBookingRequest?.startTime ?? "");
    String endTimeWithSeconds =
        ensureTimeWithSeconds(createDsmesBookingRequest?.endTime ?? "");
    updateCreateDsmesBookingRequestTime(
        startTime: startTimeWithSeconds, endTime: endTimeWithSeconds);
    ApiResult<CreateDsmesOfflineBookingResponse> apiResult = await appRepository
        .createDsmesOnlineBooking(request: createDsmesBookingRequest!);
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

  Future<String?> uploadSymptomImage(
      {required Uint8List bytes, required String fileName}) async {
    try {
      final response = await FetchClient().postHttp3(
        path: 'api/appointment/upload-symptom',
        params: {},
        bytes: bytes,
        fileName: fileName,
      );

      if (response.statusCode == 200) {
        final data = await response.stream.bytesToString();
        final jsonData = jsonDecode(data);
        return jsonData['data'];
      } else {
        throw response.reasonPhrase!;
      }
    } catch (e) {
      throw e is Error ? e : R.string.error_can_not_connect_to_server.tr();
    }
  }

  Future<List<ClinicSpecialty>> getCLinicSpecialtyList({String? top}) async {
    List<ClinicSpecialty> specialties = [];
    emit(DsmesAppointmentLoading());
    ApiResult<ClinicSpecialtyListResponse> apiResult =
        await appRepository.getCLinicSpecialtyList();
    apiResult.when(success: (ClinicSpecialtyListResponse response) {
      listSpecialty = response.data;
      specialties = listSpecialty;

      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return specialties;
  }

  Future<List<BookingClinicProvider>> searchBookingClinicList(
      {required SearchBookingClinicListRequest request,
      bool isRefresh = false,
      bool showLoading = true}) async {
    if (isRefresh) {
      listBookingClinicProvider.clear();
      clinicProviderCurrentPage = 1;
      clinicProviderHasMore = true;
    }

    if (!clinicProviderHasMore) return listBookingClinicProvider;

    emit(showLoading
        ? DsmesAppointmentLoading()
        : InitialDsmesAppointmentState());

    ApiResult<SearchListClinicResponse> apiResult =
        await appRepository.searchListBookingClinic(request: request);

    apiResult.when(success: (SearchListClinicResponse response) {
      final totalPage = response.attr.totalPage ?? 0;
      final currentPage = response.attr.currentPage ?? 0;

      clinicProviderCurrentPage = currentPage;
      clinicProviderHasMore = currentPage < totalPage;

      final providers = response.data.providers;

      if (isRefresh) {
        listBookingClinicProvider = providers;
      } else {
        listBookingClinicProvider.addAll(providers);
      }
      emit(DsmesAppointmentLoaded());
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });

    return listBookingClinicProvider;
  }

  _getFilteredData() {
    List<DsmesAppointment> filteredData = myAppointments.where((data) {
      DateTime startTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(data.startTime);
      DateTime now = DateTime.now();
      DateTime threeDaysAgo = now.subtract(Duration(days: 3));

      return ((data.status == DSMES_STATUS_REQUEST ||
              data.status == DSMES_STATUS_ON_HOLD)) ||
          (startTime.isAfter(threeDaysAgo) &&
              data.status == DSMES_STATUS_APPROVE);
    }).toList();
    return filteredData;
  }

  List<DsmesAppointment> _getMostRelevantAppointment() {
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(Duration(days: 3));
    final windowStart =
        now.subtract(Duration(minutes: Const.DSMES_BOOKING_TIME_WINDOW_RANGE));
    final windowEnd =
        now.add(Duration(minutes: Const.DSMES_BOOKING_TIME_WINDOW_RANGE));

    // First check for approved appointments within time window
    for (var appointment in myAppointments) {
      final startTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(appointment.startTime);
      if (startTime.isAfter(windowStart) &&
          startTime.isBefore(windowEnd) &&
          appointment.status == DSMES_STATUS_APPROVE) {
        return [appointment];
      }
    }

    // Sort remaining appointments by most recent start time
    myAppointments.sort((a, b) {
      final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
      final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
      return bTime.compareTo(aTime);
    });

    // Priority 1: Find approved appointment not after now, closest to current time
    List<DsmesAppointment> approvedNotAfterNow =
        myAppointments.where((appointment) {
      final endTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(appointment.endTime);
      return !now.isAfter(endTime) &&
          appointment.status == DSMES_STATUS_APPROVE;
    }).toList();

    if (approvedNotAfterNow.isNotEmpty) {
      approvedNotAfterNow.sort((a, b) {
        final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
        final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
        return (aTime.difference(now).abs())
            .compareTo(bTime.difference(now).abs());
      });
      return [approvedNotAfterNow.first];
    }

    // Priority 2: Find requested appointment closest to current time
    List<DsmesAppointment> requestedAppointments = myAppointments
        .where((appointment) => appointment.status == DSMES_STATUS_REQUEST)
        .toList();

    if (requestedAppointments.isNotEmpty) {
      requestedAppointments.sort((a, b) {
        final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
        final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
        return (aTime.difference(now).abs())
            .compareTo(bTime.difference(now).abs());
      });
      return [requestedAppointments.first];
    }

    // Priority 3: Just take first approved appointment within last 3 days
    for (var appointment in myAppointments) {
      final startTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(appointment.startTime);
      if (startTime.isBefore(now) &&
          startTime.isAfter(threeDaysAgo) &&
          appointment.status == DSMES_STATUS_APPROVE) {
        return [appointment];
      }
    }

    return myAppointments.isEmpty ? [] : [myAppointments.first];
  }

  List<DsmesAppointment> getSortedAppointments() {
    final now = DateTime.now();
    List<DsmesAppointment> sortedList = [];

    // Priority 1: Approved appointments not after now, closest to current time
    List<DsmesAppointment> approvedNotAfterNow =
        myAppointments.where((appointment) {
      final endTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(appointment.endTime);
      return now.isBefore(endTime) &&
          appointment.status == DSMES_STATUS_APPROVE;
    }).toList();

    approvedNotAfterNow.sort((a, b) {
      final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
      final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
      return (aTime.difference(now).abs())
          .compareTo(bTime.difference(now).abs());
    });
    sortedList.addAll(approvedNotAfterNow);

    // Priority 2: Requested appointments closest to current time
    List<DsmesAppointment> requestedAppointments = myAppointments
        .where((appointment) =>
            appointment.status == DSMES_STATUS_REQUEST ||
            appointment.status == DSMES_STATUS_ON_HOLD)
        .toList();

    requestedAppointments.sort((a, b) {
      final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
      final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
      return (aTime.difference(now).abs())
          .compareTo(bTime.difference(now).abs());
    });
    sortedList.addAll(requestedAppointments);

    // Priority 3: Approved appointments after now
    List<DsmesAppointment> approvedAfterNow =
        myAppointments.where((appointment) {
      final endTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(appointment.endTime);
      return endTime.isBefore(now) &&
          appointment.status == DSMES_STATUS_APPROVE;
    }).toList();

    approvedAfterNow.sort((a, b) {
      final aTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.startTime);
      final bTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.startTime);
      return aTime.compareTo(bTime);
    });
    sortedList.addAll(approvedAfterNow);

    return sortedList;
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
      patientGender: AppSettings.userInfo?.gender == 'Male' ||
              AppSettings.userInfo?.gender == 'Nam'
          ? 1
          : 2,
      patientEmail: AppSettings.userInfo?.email ?? '',
      bookingForClinic: 1, // 1: Booking phòng khám, 2: Booking bác sĩ
      language: locale,
      symptom: '',
      symptomAttachment: [],
      paymentInfo: PaymentInfo(services: []),
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

  updateCreateDsmesBookingRequestSymptomAttachments(
      {required List<String> symptomAttachments}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
      symptomAttachment: symptomAttachments,
    );
  }

  updateCreateDsmesBookingRequestServiceList(
      {String? paymentType, required List<ServiceItem> selectedServices}) {
    createDsmesBookingRequest = createDsmesBookingRequest?.copyWith(
      paymentInfo: PaymentInfo(
        paymentType: paymentType,
        services: selectedServices,
      ),
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
      paymentInfo: request.paymentInfo,
    );
  }

  initSearchBookingClinicListRequest(
      {required String specialtyId,
      int page = 1,
      String lat = '',
      String lng = ''}) {
    searchBookingClinicListRequest = SearchBookingClinicListRequest(
      page: page.toString(),
      urlKeywords: [],
      specialty: specialtyId,
      lat: lat,
      lng: lng,
    );
  }

  updateSearchBookingClinicListRequestSpecialty({required String specialty}) {
    searchBookingClinicListRequest = searchBookingClinicListRequest?.copyWith(
      specialty: specialty,
    );
  }

  updateSearchBookingClinicListRequestPage({required int page}) {
    searchBookingClinicListRequest = searchBookingClinicListRequest?.copyWith(
      page: page,
    );
  }

  updateSearchBookingClinicListRequestUrlKeyword(
      {required List<String> urlKeywords}) {
    searchBookingClinicListRequest = searchBookingClinicListRequest?.copyWith(
      urlKeywords: urlKeywords,
    );
  }

  updateSearchBookingClinicListRequestClinicTypes(
      {required List<String> clinicTypes}) {
    searchBookingClinicListRequest = searchBookingClinicListRequest?.copyWith(
      clinicTypes: clinicTypes,
    );
  }

  updateSearchBookingClinicListRequestTimeframes(
      {required List<String> timeframes}) {
    searchBookingClinicListRequest = searchBookingClinicListRequest?.copyWith(
      timeframes: timeframes,
    );
  }

  updateSearchBookingClinicListRequestServiceTypes(
      {required List<String> serviceTypes}) {
    searchBookingClinicListRequest = searchBookingClinicListRequest?.copyWith(
      svAvailable: serviceTypes,
    );
  }

  String getItemTitle(DsmesAppointmentMode mode) {
    switch (mode) {
      case DsmesAppointmentMode.atClinic:
        return R.string.at_clinic.tr();
      case DsmesAppointmentMode.telemedicine:
        return R.string.kham_tu_xa.tr();
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

  Future<bool> saveVnpayTransactionInfo(VnpayPaymentRequest request) async {
    final result = await appRepository.saveVnpayTransactionInfo(request);

    return result;
  }

  Future<bool> updateVnpayTransactionInfo(
      {required int appointmentId, required String txnRef}) async {
    final result = await appRepository.updateVnpayTransactionInfo(
        appointmentId: appointmentId, txnRef: txnRef);

    return result;
  }

  Future<GetVnpayTransactionInfoResponse?> getPaymentVnpayTransactionInfo(
      {required String txnRef}) async {
    GetVnpayTransactionInfoResponse? result;
    ApiResult<GetVnpayTransactionInfoResponse> apiResult =
        await appRepository.getPaymentVnpayTransactionInfo(txnRef: txnRef);
    apiResult.when(success: (GetVnpayTransactionInfoResponse response) {
      result = response;
    }, failure: (NetworkExceptions error) {
      emit(DsmesAppointmentFailure(NetworkExceptions.getErrorMessage(error)));
    });
    return result;
  }
}
