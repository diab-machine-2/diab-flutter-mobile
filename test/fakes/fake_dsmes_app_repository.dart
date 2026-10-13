import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/get_booking_clinic_list_request.dart';
import 'package:medical/src/model/response/dsmes_clinic_detail_response.dart';
import 'package:medical/src/model/response/search_list_clinic_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';

/// Hand-written fake for the clinic-resolution endpoints used by
/// DsmesAppointmentCubit.getClinicDetail / searchBookingClinicList.
///
/// Every other AppRepository method resolves to an ApiResult failure via
/// [noSuchMethod] (`Future<ApiResult<Never>>` is a subtype of every
/// `Future<ApiResult<T>>`), so unrelated calls never hit the network.
class FakeDsmesAppRepository implements AppRepository {
  /// Clinic id -> clinic JSON (`api/clinics/profile` `data`). Ids not in the
  /// map fail with [detailError].
  final Map<int, Map<String, dynamic>> clinicsById = {};
  NetworkExceptions detailError =
      const NetworkExceptions.notFound('clinic not found');

  /// Providers returned by the clinic search (`seo-static-link-multi-diab`).
  List<Map<String, dynamic>> searchProviders = [];

  final List<int> detailCalls = [];
  final List<SearchBookingClinicListRequest> searchCalls = [];
  final List<String> callLog = [];

  @override
  Future<ApiResult<DsmesClinicDetailResponse>> getClinicDetail(
      {required int id}) async {
    detailCalls.add(id);
    callLog.add('detail:$id');
    final clinic = clinicsById[id];
    if (clinic == null) return ApiResult.failure(error: detailError);
    return ApiResult.success(
      data: DsmesClinicDetailResponse.fromJson({'code': 200, 'data': clinic}),
    );
  }

  Future<ApiResult<SearchListClinicResponse>> _search(
      SearchBookingClinicListRequest request) async {
    searchCalls.add(request);
    callLog.add('search');
    return ApiResult.success(
      data: SearchListClinicResponse.fromJson({
        'code': 200,
        'data': {'providers': searchProviders, 'clusters': []},
        'attr': {'total': searchProviders.length, 'current_page': 1, 'total_page': 1},
      }),
    );
  }

  @override
  Future<ApiResult<SearchListClinicResponse>> searchListBookingClinic(
          {required SearchBookingClinicListRequest request}) =>
      _search(request);

  @override
  Future<ApiResult<SearchListClinicResponse>> searchListBookingClinicDiab(
          {required SearchBookingClinicListRequest request}) =>
      _search(request);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    callLog.add('unexpected:${invocation.memberName}');
    return Future<ApiResult<Never>>.value(
      const ApiResult<Never>.failure(
          error: NetworkExceptions.notFound('not faked')),
    );
  }
}
