import 'dart:async';
import 'package:medical/src/widget/survey_screens/survey_question/survey_question.dart';

import 'rocheConnection_state.dart';
import 'package:medical/src/utils/const.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/widget/nipro/roche_connection/data/models/GlucoseMeasurementRecord.dart';

enum AppStatus { isScanning, isConnected, isConnecting, isSyncing }

class RocheConnectionCubit extends Cubit<RocheConnectionState> {
  RocheConnectionCubit() : super(RocheConnectionInitial());

  AppStatus appStatus = AppStatus.isScanning;
  final glucoseClient = GlucoseClient();

  Future<void> submitSyncData(
      List<GlucoseMeasurementRecord> dataSelected) async {
    emit(RocheConnectionLoading());
    if (dataSelected.isEmpty) {
      return emit(RocheConnectionFailure('Hãy chọn chỉ số muốn cập nhật!'));
    }
    // Bắt đầu sync
    bool isMilligramPerDeciliter = AppSettings.userInfo!.glucoseUnit == 1;

    int countResponse = 0;
    int countRequest = dataSelected.length;
    while (countRequest != dataSelected.length) {}
    for (GlucoseMeasurementRecord element in dataSelected) {
      countResponse++;
      List<TimeFrameModel> timeFrames =
          await glucoseClient.fetchFlucoseTimeFrame(
              time: DateUtil.getDayInMillis(element.calendar!));

      final glucose = roundAsFixed(isMilligramPerDeciliter
          ? roundDouble(element
              .convertGlucoseConcentrationValueToMilligramsPerDeciliter())
          : roundDouble(element
                  .convertGlucoseConcentrationValueToMilligramsPerDeciliter()) /
              Const.mmollToMgdlFactor);

      // await GlucoseClient().postIndexGlucose(
      //     timeFrames.isNotEmpty ? timeFrames.first.id : null,
      //     DateUtil.getDayInMillis(element.calendar!),
      //     glucose.toString(),
      //     null,
      //     '',
      //     false, []);
      if (countResponse == countRequest) {
        emit(SyncDataSuccesed());
      }
    }
  }

  onSyncDataSuccess() {
    emit(RocheConnectionLoading());
    emit(SyncDataSuccesed());
  }
}
