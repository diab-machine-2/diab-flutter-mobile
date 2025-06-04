import 'package:dio/dio.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/request/dsmes_cancel_booking_request.dart';
import 'package:medical/src/model/request/dsmes_reschedule_request.dart';
import 'package:medical/src/model/request/get_booking_clinic_list_request.dart';
import 'package:medical/src/model/request/get_dsmes_appointment_request.dart';
import 'package:medical/src/model/response/clinic_specialty_list_response.dart';
import 'package:medical/src/model/response/common_response.dart';
import 'package:medical/src/model/response/create_dsmes_offline_booking_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_list_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_rating_response.dart';
import 'package:medical/src/model/response/get_diab_clinics_schedule_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_detail_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_response.dart';
import 'package:medical/src/model/response/search_list_clinic_response.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'docosan_api.g.dart';

@RestApi()
abstract class DocosanApi {
  factory DocosanApi(Dio dio, {String baseUrl}) = _DocosanApi;

  // DSMES Booking Center

  @GET("api/patients/my-appointment-partner")
  Future<GetDsmesAppointmentResponse> getListDsmesAppointment(
      @Query('page') int? page);

  @GET("api/clinics/profile")
  Future<DsmesClinicDetailResponse> getClinicDetail(
    @Query('id') int? id,
  );

  @GET("api/clinics/profile-clinic-diab")
  Future<DsmesClinicListResponse> getClinicList(
    @Query('type') String? type,
  );

  @POST("api/doctors/patient-appointments-partner")
  Future<CreateDsmesOfflineBookingResponse> createDsmesOfflineBooking(
      @Body() CreateDsmesBookingRequest request);

  @GET("api/patients/my-appointment-detail")
  Future<GetDsmesAppointmentDetailResponse> getDsmesAppointmentDetail(
    @Query('appointment_id') int? appointmentId,
  );

  @POST("api/patients/cancel-appointment")
  Future<CommonResponse> cancelDsmesAppointment(
      @Body() DsmesCancelBookingRequest request);

  @POST("api/patients/reschedule-apt")
  Future<CreateDsmesOfflineBookingResponse> rescheduleDsmesAppointment(
      @Body() RescheduleDsmesBookingRequest request);

  @POST("api/clinics/rate")
  Future<DsmesClinicRatingResponse> getClinicRate(
    @Query('clinic_id') int? clinicId,
  );

  @GET("api/clinics/profile-clinic-diab-schedule")
  Future<GetDiabClinicsScheduleResponse> getDiabClinicsSchedule();

  @POST("api/payment/create-order-partner")
  Future<CreateDsmesOfflineBookingResponse> createDsmesOnlineBooking(
      @Body() CreateDsmesBookingRequest request);

  @GET("api/diseases-configuration")
  Future<ClinicSpecialtyListResponse> getCLinicSpecialtyList({
    @Query('language') String? language,
    @Query('top') String? top,
    @Query('version') String? version,
  });

  @POST("api/seo-static-link-multi")
  Future<SearchListClinicResponse> searchBookingClinicList(
      @Body() SearchBookingClinicListRequest request);
}
