import 'package:dio/dio.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/model/request/get_dsmes_appointment_request.dart';
import 'package:medical/src/model/request/register_docosan_user_request.dart';
import 'package:medical/src/model/response/create_dsmes_offline_booking_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/dsmes_clinic_list_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_detail_response.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_response.dart';
import 'package:medical/src/model/response/is_exist_docosan_user_response.dart';
import 'package:medical/src/model/response/register_docosan_user_response.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'docosan_api.g.dart';

@RestApi()
abstract class DocosanApi {
  factory DocosanApi(Dio dio, {String baseUrl}) = _DocosanApi;

  // DSMES Booking Center

  @POST("api/patients/my-appointment")
  Future<GetDsmesAppointmentResponse> getListDsmesAppointment(
      @Body() GetDsmesAppointmentRequest page);

  @GET("api/clinics/profile")
  Future<DsmesClinicDetailResponse> getClinicDetail(
    @Query('id') int? id,
  );

  @GET("api/clinics/profile-clinic-diab")
  Future<DsmesClinicListResponse> getClinicList();

  @POST("api/doctors/patient-appointments")
  Future<CreateDsmesOfflineBookingResponse> createDsmesOfflineBooking(
      @Body() CreateDsmesBookingRequest request);

  @GET("api/patients/my-appointment-detail")
  Future<GetDsmesAppointmentDetailResponse> getDsmesAppointmentDetail(
    @Query('appointment_id') int? appointmentId,
  );
}
