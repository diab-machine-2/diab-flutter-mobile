import 'package:dio/dio.dart';
import 'package:medical/src/model/request/get_dsmes_appointment_request.dart';
import 'package:medical/src/model/response/get_dsmes_appointment_response.dart';
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
}
