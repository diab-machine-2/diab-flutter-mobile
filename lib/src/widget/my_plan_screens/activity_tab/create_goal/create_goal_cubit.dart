import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/goal_info.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_smart_goal_request.dart';
import 'package:medical/src/model/response/create_smart_goal_response.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/model/response/smart_goal_statistic_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/repo/user/user_client.dart';

import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/create_smart_goal_data.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';

class CreateGoalCubit extends Cubit<CreateGoalState> {
  CreateGoalCubit(this.repository, {required this.smartGoalDayList}) : super(const CreateGoalInitial()) {
    if (smartGoalDayList.isEmpty) {
      getSmartGoal();
    }
  }

  final AppRepository repository;
  List<SmartGoalList?> smartGoalDayList = [];

  GoalInfoModel? goalInfoModel;
  ScheduleType? currentSelectedType;

  CreateSmartGoalData dataModel = CreateSmartGoalData();

  CreateGoalStatus currentStatus = CreateGoalStatus.select_type;

  int currentWeekIndex = 0;
  int currentDayIndex = 0;
  SmartGoalStatisticResponseData? statistic;

  List<DayStatesResponseData?> get dayStatesList => statistic?.daysInCurrentWeek ?? [];

  int? get currentWeek => currentWeekIndex == null ? null : currentWeekIndex + 1;

  int? get currentDay => dayStatesList.isEmpty ? 0 : dayStatesList[currentDayIndex]?.day;

  bool get isValid {
    final String errorMessage = dataModel.checkValid;
    if (errorMessage.isEmpty) return true;
    showError(errorMessage);
    return false;
  }

  void showError(String message) {
    emit(CreateGoalFailure(message));
    emit(const CreateGoalInitial());
  }

  bool get showDetail => !(currentStatus != CreateGoalStatus.setup || dataModel.type == ScheduleType.custom);

  SmartGoalList? getSmartGoalDataByType(ScheduleType type) {
    final int index = smartGoalDayList.indexWhere((element) => element?.type == type.typeIndex);
    if (index == -1) return null;
    return smartGoalDayList[index];
  }

  void fillInitialData(ScheduleType selectedType) {
    final SmartGoalList? smartGoalData = getSmartGoalDataByType(selectedType);
    dataModel.fillData(selectedType, smartGoalData);
  }

  Future<void> setupGoal({required ScheduleType selectedType, int? subType}) async {
    //When chose a smart goal type for the first time
    currentSelectedType = selectedType;
    if (dataModel.cachedType == null ||
        selectedType != dataModel.cachedType ||
        selectedType == dataModel.cachedType && subType != dataModel.cachedSubType) {
      dataModel.resetData();
      fillInitialData(selectedType);
    }
    dataModel.cachedType = null;
    dataModel.cachedSubType = null;
    dataModel.type = selectedType;
    dataModel.subType = subType;
    if (selectedType != ScheduleType.custom) {
      dataModel.goalRecordType = GoalRecordType.frequency;
    }
    currentStatus = CreateGoalStatus.setup;

    if (selectedType == ScheduleType.exercise) {
      emit(const CreateGoalLoading());
      await fetchGoalInfo();
    }
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onToggleRepeat() {
    dataModel.isRepeat = !dataModel.isRepeat;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatType(String selectedRepeatType) {
    dataModel.repeatType = RepeatTypeExtend.getTypeFromString(selectedRepeatType);
    if (dataModel.repeatType == RepeatType.day) {
      dataModel.repeatDayList.clear();
    }
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onChangeRepeatDay(List<String> selectedDayList) {
    dataModel.repeatDayList = selectedDayList.map((e) => DayInWeekExtend.getDayInWeekFromString(e)).toList();
    dataModel.repeatDayList.sort((a, b) => a.index - b.index);
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  void onSelectStatus(CreateGoalStatus newStatus) {
    if (newStatus == currentStatus) return;

    if (currentStatus == CreateGoalStatus.select_type && dataModel.type == null) return;

    if (newStatus == CreateGoalStatus.complete) {
      if (!isValid) {
        currentStatus = CreateGoalStatus.setup;
        emit(const CreateGoalSuccess());
        emit(const CreateGoalInitial());
        return;
      }
    }

    if (newStatus == CreateGoalStatus.select_type) {
      dataModel.cachedType = dataModel.type;
      dataModel.cachedSubType = dataModel.subType;
    }

    currentStatus = newStatus;
    emit(const CreateGoalSuccess());
    emit(const CreateGoalInitial());
  }

  Future<void> onTapNext() async {
    if (currentStatus == null) return;
    if (currentStatus == CreateGoalStatus.setup) {
      if (!isValid) return;
      currentStatus = CreateGoalStatus.complete;
      emit(const CreateGoalSuccess());
    } else if (currentStatus == CreateGoalStatus.complete) {
      emit(const CreateGoalLoading());
      if (goalInfoModel != null) {
        await updateGoalSetting(goalInfoModel!);
      }
      await createSmartGoal();
      emit(const CreateGoalCompleted());
    }
    emit(const CreateGoalInitial());
  }

  Future<void> updateGoalSetting(GoalInfoModel goalInfoModel) async {
    await UserClient().updateGoalInfo(
      GoalInfoModel(
        dailyWalkTargetDuration: goalInfoModel.dailyWalkTargetDuration ?? 0,
        dailyTargetDuration: dataModel.dailyTargetDurationNumber.toDouble(),
        weeklyTargetDuration: goalInfoModel.weeklyTargetDuration ?? 0,
        dailyTargetBurnedCalorie: goalInfoModel.dailyTargetBurnedCalorie ?? 0,
        dailyEnergyGoal: goalInfoModel.dailyEnergyGoal ?? 0,
        goalWaist: goalInfoModel.goalWaist ?? 0,
        goalWeight: goalInfoModel.goalWeight ?? 0,
      ),
    );
  }

  Future<GoalInfoModel?> fetchGoalInfo() async {
    goalInfoModel = await UserClient().fetchGoalInfo();
    return goalInfoModel;
  }

  Future<void> createSmartGoal() async {
    late final ApiResult<CreateSmartGoalResponse> apiResult;

    int appointmentDate = dataModel.request?.appointmentDate ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(appointmentDate * 1000);
    DateTime dateTime0 = DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
    int newAppointmentDate = (dateTime0.millisecondsSinceEpoch ~/ 1000).toInt();

    var creatGoalRequest = CreateSmartGoalRequest(
      id: dataModel.request?.id,
      targetScheduler: dataModel.request?.targetScheduler,
      targetSchedulerId: dataModel.request?.targetSchedulerId,
      name: dataModel.request?.name,
      type: dataModel.request?.type,
      executeType: dataModel.request?.executeType,
      executeDayTimes: dataModel.request?.executeDayTimes
    );
    creatGoalRequest.appointmentDate = newAppointmentDate;

    apiResult = await repository.createSmartGoal(creatGoalRequest);
    apiResult.when(success: (CreateSmartGoalResponse response) {
      if (response.meta?.success ?? false) {
        Observable.instance
            .notifyObservers([], notifyName: "food_change_data");
        emit(const CreateGoalSuccess());
      } else {
        emit(CreateGoalFailure(response.error?.message ?? R.string.error));
      }
    }, failure: (NetworkExceptions error) {
      emit(CreateGoalFailure(NetworkExceptions.getErrorMessage(error)));
    });
    emit(const CreateGoalInitial());
  }

  Future<void> getSmartGoal({bool isRefresh = false, bool keepCurrentDay = true}) async {
    await Future.delayed(Duration(microseconds: 50));
    emit(const CreateGoalLoading());
    await getSmartGoalStatistics(isRefresh: isRefresh, hideLoadingAfterDone: true, keepCurrentDay: keepCurrentDay);
    await getListSmartGoal(isRefresh: isRefresh);
    emit(const CreateGoalInitial());
  }

  Future<void> getListSmartGoal({bool isRefresh = false, bool isShowLoading = false}) async {
    final ApiResult<SmartGoalListReponse> apiResult =
        await repository.getListSmartGoal(day: currentDay, week: currentWeek);
    apiResult.when(
        success: (SmartGoalListReponse response) {
          smartGoalDayList = response.data?.daily ?? [];

          AppSettings.smartGoalDayList = response.data?.daily ?? [];
        },
        failure: (NetworkExceptions error) {});
  }

  Future<void> getSmartGoalStatistics({
    bool isRefresh = false,
    bool hideLoadingAfterDone = true,
    bool keepCurrentDay = false,
  }) async {
    await Future.delayed(Duration.zero);
    final ApiResult<SmartGoalStatisticResponse> apiResult = await repository.getSmartGoalStatistics(week: currentWeek);
    apiResult.when(
        success: (SmartGoalStatisticResponse response) {
          statistic = response.data;
          if (!keepCurrentDay) currentDayIndex = response.initDayIndex;
        },
        failure: (NetworkExceptions error) {});
  }

  String getSubTitle(){
    if(currentSelectedType == ScheduleType.blood_pressure) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;"><strong>Diab khuyến nghị:</strong></span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">&bull; Nếu huyết &aacute;p của bạn ổn định, h&atilde;y đo 1- 3 ng&agrave;y/tuần</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">&bull; Nếu huyết &aacute;p của bạn chưa ổn định, h&atilde;y đo 3 - 7 ng&agrave;y/tuần</span></p>''';
    } else if(currentSelectedType == ScheduleType.exercise) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">DiaB khuyến nghị ghi theo tần suất hoạt động của bạn.</span></p>''';
    } else if(currentSelectedType == ScheduleType.weight) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">DiaB khuyến nghị bạn theo d&otilde;i c&acirc;n nặng của m&igrave;nh 2 tuần/lần.</span></p>''';
    } else if(currentSelectedType == ScheduleType.emotion) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">DiaB khuyến nghị bạn n&ecirc;n ghi nhận lại cảm x&uacute;c mỗi khi c&oacute; cảm x&uacute;c đặc biệt.&nbsp;</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Một ng&agrave;y bạn c&oacute; thể ghi nhiều lần.</span></p>''';
    } else if(currentSelectedType == ScheduleType.food) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;"><strong>DiaB khuyến nghị: 2 lần/tuần</strong></span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Bạn n&ecirc;n chọn 1 ng&agrave;y trong tuần v&agrave; 1 ng&agrave;y cuối tuần.</span></p>''';
    } else {
      return '';
    } 
  }

  String getFullSubTitle(){
    if(currentSelectedType == ScheduleType.blood_pressure) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">&bull; Nếu huyết &aacute;p của bạn ổn định, h&atilde;y đo 1- 3 ng&agrave;y/tuần</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">&bull; Nếu huyết &aacute;p của bạn chưa ổn định, h&atilde;y đo 3 - 7 ng&agrave;y/tuần</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">D&ugrave; chưa biết l&yacute; do v&igrave; sao c&oacute; sự tương quan đ&aacute;ng kể giữa đ&aacute;i th&aacute;o đường v&agrave; tăng huyết &aacute;p nhưng người ta giả định rằng b&eacute;o ph&igrave;, chế độ ăn uống nhiều natri v&agrave; lười vận động dẫn đến sự gia tăng đồng thời cả hai bệnh tr&ecirc;n.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Tăng huyết &aacute;p được biết đến như một &ldquo;kẻ giết người thầm lặng&rdquo; v&igrave; n&oacute; kh&ocirc;ng c&oacute; triệu chứng r&otilde; r&agrave;ng. Một cuộc khảo s&aacute;t năm 2002 của Hiệp hội Đ&aacute;i th&aacute;o đường Hoa Kỳ (ADA) cho thấy, khoảng 68% những người bị bệnh đ&aacute;i th&aacute;o đường kh&ocirc;ng biết họ cũng c&oacute; nguy cơ gia tăng bệnh tim v&agrave; đột quỵ v&igrave; li&ecirc;n quan đến tăng huyết &aacute;p mạn t&iacute;nh.</span></p>
<p><br></p>''';
    } else if(currentSelectedType == ScheduleType.exercise) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Theo khuyến nghị của chuy&ecirc;n gia y tế, thời gian vận động tối thiểu l&agrave; 20 - 30 ph&uacute;t/ ng&agrave;y, &iacute;t nhất 5 ng&agrave;y trong tuần, 2 lần tập c&aacute;ch nhau kh&ocirc;ng qu&aacute; 48 giờ</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Đối với m&ocirc;n đi bộ, tốc độ được xem ph&ugrave; hợp l&agrave; bạn vừa đi vừa c&oacute; thể n&oacute;i chuyện được nhưng kh&ocirc;ng đủ hơi để h&aacute;t, v&agrave; nhịp tim tăng &gt;130 bpm sau khi tập. Mức năng lượng ti&ecirc;u hao cho việc đi bộ được khuyến kh&iacute;ch l&agrave; đạt &iacute;t nhất 700kcal/tuần.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Đối với bệnh nh&acirc;n đ&aacute;i th&aacute;o đường, bạn cần được b&aacute;c sĩ kiểm tra v&agrave; cho lời khuy&ecirc;n trước khi bắt đầu tập bất cứ m&ocirc;n thể thao n&agrave;o, h&atilde;y n&oacute;i r&otilde; với b&aacute;c sĩ về bộ m&ocirc;n bạn dự định tham gia, thời gian, v&agrave; cường độ của b&agrave;i tập. V&agrave; quan trọng nhất, h&atilde;y lưu &yacute; tham gia luyện tập an to&agrave;n, tr&aacute;nh chấn thương, t&eacute; ng&atilde; bạn nh&eacute;.</span></p>
<p><br></p>''';
    } else if(currentSelectedType == ScheduleType.weight) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">C&oacute; tới 80-90% người bệnh đ&aacute;i th&aacute;o đường c&oacute; rối loạn mỡ m&aacute;u. Hai căn bệnh n&agrave;y gần như lu&ocirc;n đi đ&ocirc;i với nhau v&agrave; đều li&ecirc;n quan mật thiết đến t&igrave;nh trạng <strong>thừa c&acirc;n - b&eacute;o ph&igrave;</strong>.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">H&atilde;y theo d&otilde;i c&acirc;n năng, chỉ số khối cơ thể (BMI) của m&igrave;nh thường xuy&ecirc;n đặc biệt khi bạn đang trong giai đoạn điều chỉnh tăng cần, giảm c&acirc;n.</span></p>''';
    } else if(currentSelectedType == ScheduleType.emotion) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Căng thẳng c&oacute; thể g&acirc;y ra những ảnh hưởng kh&aacute;c nhau đối với mỗi người.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Những người mắc bệnh Đ&aacute;i th&aacute;o đường t&iacute;p 2 khi trải qua căng thẳng tinh thần, mức đường huyết thường gia tăng cao hơn. Tuy nhi&ecirc;n, người bệnh tiểu đường t&iacute;p 1 lại c&oacute; phản ứng với căng thẳng đa dạng hơn. Tức l&agrave;, mức đường huyết của họ c&oacute; thể tăng cao hoặc giảm thấp.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Khi cơ thể gặp vấn đề g&acirc;y ra những căng thẳng về thể chất, chẳng hạn như bị ốm hoặc chấn thương, lượng đường trong m&aacute;u c&oacute; thể tăng l&ecirc;n. Điều n&agrave;y xảy ra ở cả người bệnh tiểu đường t&iacute;p 1 v&agrave; t&iacute;p 2.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Ngo&agrave;i ra, căng thẳng k&eacute;o d&agrave;i cũng tạo n&ecirc;n t&aacute;c động ti&ecirc;u cực l&ecirc;n c&aacute;c hệ thống kh&aacute;c trong cơ thể:</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">&nbsp; &bull; Hệ miễn dịch</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">&nbsp; &bull; Hệ ti&ecirc;u h&oacute;a</span></p>
<p style="line-height: 1;"><span style="color: rgb(0, 0, 0); font-family: Arial, Helvetica, sans-serif; font-size: 15px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; float: none; display: inline !important;">&nbsp; &bull;&nbsp;</span><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Hệ b&agrave;i tiết (thận)</span></p>
<p style="line-height: 1;"><span style="color: rgb(0, 0, 0); font-family: Arial, Helvetica, sans-serif; font-size: 15px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; float: none; display: inline !important;">&nbsp; &bull;&nbsp;</span><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Hệ sinh sản</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Hơn nữa, khả năng suy nghĩ thấu đ&aacute;o v&agrave; đưa ra quyết định đ&uacute;ng đắn cũng giảm xuống khi bạn lu&ocirc;n lo lắng, sầu muộn v&agrave; sợ h&atilde;i. T&igrave;nh trạng căng thẳng về tinh thần k&eacute;o d&agrave;i c&oacute; thể l&agrave;m tăng nguy cơ mắc bệnh trầm cảm.</span></p>
<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Nguồn: hellobacsi</span></p>''';
    } else if(currentSelectedType == ScheduleType.food) {
      return '''<p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Bạn n&ecirc;n chọn 1 ng&agrave;y trong tuần v&agrave; 1 ng&agrave;y cuối tuần.</span></p>
        <p style="line-height: 1;"><span style="font-family: Arial, Helvetica, sans-serif; font-size: 15px;">Trong trường hợp bạn tham gia c&aacute;c chương tr&igrave;nh chuy&ecirc;n s&acirc;u của DiaB, h&atilde;y trao đổi với huấn luyện vi&ecirc;n của bạn để theo d&otilde;i s&aacute;t bữa ăn của m&igrave;nh hơn.</span></p>
        <p><br></p>''';
    } else {
      return '';
    } 
  }
}
