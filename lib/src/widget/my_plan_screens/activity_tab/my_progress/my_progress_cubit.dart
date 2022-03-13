import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_progress_response.dart';
import 'package:medical/src/model/response/report_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../model/response/report_model.dart';
import 'models/filter_type.dart';
import 'my_progress.dart';

class MyProgressCubit extends Cubit<MyProgressState> {
  MyProgressCubit(this.repository, this.reports, this.hasNewReports) : super(const MyProgressInitial());

  final AppRepository repository;

  FilterType? filterType = FilterType.all;

  MyProgressResponse? myProgressData;
  List<ReportModel>? reports = [];
  bool? hasNewReports = false;

  void onChangeFilter(String filterText) {
    filterType = FilterTypeExtends.getTypeFromString(filterText);
    getMyProgress();
  }

  bool get isFiltering => filterType != null;

  void initData() async {
    await Future.delayed(Duration.zero);
    emit(const MyProgressLoading());

    if(reports == null){
       await getReports();
      List<ReportModel> reportsFromPreferences = await getReportsFromPreferences();
      hasNewReports = reportsFromPreferences.length < (reports?.length ?? 0);
      await saveHasNewReportsFromPreferences(hasNewReports ?? false);
    }

    await getMyProgress();
  }

  void refresh(){
    emit(const MyProgressInitial());
    emit(MyProgressSuccess());
  }

  Future<void> getMyProgress({bool isRefresh = false}) async {
    await Future.delayed(Duration.zero);
    if (!isRefresh) emit(const MyProgressLoading());
    final ApiResult<MyProgressResponse> apiResult =
        await repository.getMyProgress(type: filterType?.typeIndex ?? 0);
    apiResult.when(success: (MyProgressResponse response) {
       myProgressData = response;

      emit(const MyProgressSuccess());
    }, failure: (NetworkExceptions error) {
      emit(MyProgressFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const MyProgressInitial());
  }

   Future<void> getReports({bool isRefresh = false}) async {
    await Future.delayed(Duration.zero);
 //   if (!isRefresh) emit(const MyProgressLoading());
    final ApiResult<ReportListResponse> apiResult =
        await repository.getReports();
    apiResult.when(success: (ReportListResponse response) {
      reports = response.data ?? [];
  //    emit(const MyProgressSuccess());
    }, failure: (NetworkExceptions error) {
 //     emit(MyProgressFailure(NetworkExceptions.getErrorMessage(error)));
    });
 //   emit(const MyProgressInitial());
  }

   Future<void> saveHasNewReportsFromPreferences(bool hasNewReports) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.setBool('hasNewReports', hasNewReports);
  }

   Future<bool> getHasNewReportsFromPreferences() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final hasNewReports = prefs.getBool('hasNewReports') ?? false;
    return hasNewReports;
  }

  Future<void> saveReportsFromPreferences(List<ReportModel> reports) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var json = jsonEncode(reports.map((e) => e.toJson()).toList());
    prefs.setString('reports', json);
  }

  Future<List<ReportModel>> getReportsFromPreferences() async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    final reportsString = prefs.getString('reports');
    List<ReportModel> reports = [];

    if(reportsString != null){
      Iterable l = json.decode(reportsString);
      reports = List<ReportModel>.from(l.map((model)=> ReportModel.fromJson(model)));
    }
    return reports;
  }

}
