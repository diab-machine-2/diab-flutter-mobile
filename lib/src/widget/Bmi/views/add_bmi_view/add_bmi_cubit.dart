import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/bmi/weight_input.dart';
import 'package:medical/src/modal/error/failures.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/user_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/models/weight_ranger_model.dart';
import 'package:medical/src/widget/base/cubit_base_state.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

class AddBmiCubit extends Cubit<CubitBaseState> {
  final String? type;
  final String? id;
  final String? goalId;
  final bool? isCurrentBmi;
  bool? isCloseShortGuide;

  void setIsCloseShortGuide(bool isClose) {
    this.isCloseShortGuide = isClose;
  }

  bool getIsCloseShortGuidle() {
    return this.isCloseShortGuide ?? false;
  }

  AddBmiCubit({this.type, this.id, this.goalId, this.isCurrentBmi})
      : super(InitialState()) {
    if (AppSettings.userInfo!.height != 0 &&
        AppSettings.userInfo!.height != null) {
      selectedHeight = AppSettings.userInfo!.height!.toInt();
    }
    selectedWeightDefault = AppSettings.userInfo!.weight ?? 50;

    isPregnancy = Utils.isGestationalDiabetes();
    if (type == 'update' && id != null) {
      loadDataDetail();
    } else {
      loadTimeFrame();
    }
    loadDescription();
  }

  TextEditingController controllerWeight = TextEditingController();
  TextEditingController controllerHeight = TextEditingController();
  TextEditingController controllerNote = TextEditingController();
  TextEditingController controllerHip = TextEditingController();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime time = DateTime.now();
  InputWeightModel? model;
  TimeFrameModel? selectedTimeFrame;
  List<String?> removeIDs = [];
  String textValidate = '';
  double selectedWeight = 0;
  double selectedWeightDefault = 0;
  int selectedHeight = 0;
  int selectedHip = 0;
  bool isDelete = false;
  double? bmiNumber = 0;
  bool isPregnancy = false;
  List<WeightRangeModel>? weightRanges;
  List<double> rangeValue = [];

  int clickedTime = 0;

  ShortGuiModel? des;
  final AppRepository repository = AppRepository();
  FocusNode _focusNode = FocusNode();

  loadDataDetail() async {
    // BotToast.showLoading();
    emit(LoadingState());
    model = await WeightClient().fetchDetail(id);
    if (model == null) return;
    // BotToast.closeAllLoading();
    bmiNumber = model!.bmi;
    selectedWeight = model!.weight == null ? 0 : model!.weight!;
    selectedHeight = model!.height == null ? 0 : model!.height!.toInt();
    controllerNote.text = model!.note ?? '';
    selectedHip = model!.waist == null ? 0 : model!.waist!.toInt();
    files.addAll(model!.images);
    selectedDate = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
    selectedTimeFrame = TimeFrameModel(
        id: model!.timeFrameId, code: '', name: model!.timeFrameText);
    getWeightThreshold();
  }

  loadTimeFrame() async {
    final timeFrames = await GlucoseClient().fetchFlucoseTimeFrame(
        time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
    getWeightThreshold();
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(7);
  }

  submitData() async {
    try {
      final note = controllerNote.text;
      emit(LoadingState());

      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await WeightClient().postWeightInput(
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          paths,
          selectedWeight.toString(),
          selectedHip == 0 ? null : selectedHip.toString(),
          selectedHeight.toString(),
          note,
          selectedTimeFrame!.id);
      if (result == true) {
        // await TrackingManager.analytics.logEvent(
        //   name: 'kpi_add_success',
        //   parameters: {
        //     "screen_name": 'kpi_body_weight_add',
        //     'object_type': 'kpi_body_weight',
        //     'object_title': 'Chỉ số cân nặng'
        //   },
        // );
        await HomeClient().completeSmartGoal(
            selectedDate, goalId ?? '', 1, ScheduleType.weight.typeIndex);
        if (AppSettings.userInfo!.weight != selectedWeight) {
          await updateHeightProfile();
          Observable.instance
              .notifyObservers([], notifyName: "Weight_change_data");
        }
        emit(DataLoadedState());
      }
    } catch (e) {
      BotToast.closeAllLoading();
    } finally {
      BotToast.closeAllLoading();
    }
  }

  getWeightThreshold() async {
    emit(LoadingState());
    final result = await WeightClient().getWeightThreshold(
      date: selectedDate.millisecondsSinceEpoch ~/ 1000,
      waist: selectedHip,
      height: selectedHeight,
      weight: selectedWeight,
    );
    weightRanges = result;
    rangeValue = [0];
    result.forEach((element) {
      rangeValue.add(element.weight!);
    });
    rangeValue.removeLast();

    emit(LoadingCompleteStateWithoutProps());
  }

  updateHeightProfile() async {
    UserModel userInfo = AppSettings.userInfo!;
    userInfo = UserModel(
      id: userInfo.id,
      accountId: userInfo.accountId,
      userName: userInfo.userName,
      fullName: userInfo.fullName,
      packageAccount: userInfo.packageAccount,
      packageName: userInfo.packageName,
      age: userInfo.age,
      phoneNumber: userInfo.phoneNumber,
      secondPhoneNumber: userInfo.secondPhoneNumber,
      gender: userInfo.gender,
      genderType: userInfo.genderType,
      createDatetime: userInfo.createDatetime,
      isActive: userInfo.isActive,
      province: userInfo.province,
      district: userInfo.district,
      height: selectedHeight * 1.0,
      weight: selectedWeight * 1.0,
      ward: userInfo.ward,
      dateOfBirth: userInfo.dateOfBirth,
      diabetesStatus: userInfo.diabetesStatus,
      diabetesName: userInfo.diabetesName,
      diabetesDate: userInfo.diabetesDate,
      imageUrl: userInfo.imageUrl,
      code: userInfo.code,
      email: userInfo.email,
      address: userInfo.address,
      goalWaist: userInfo.goalWaist,
      goalWeight: userInfo.goalWeight,
      isLinkedFacebook: userInfo.isLinkedFacebook,
      isLinkedGoogle: userInfo.isLinkedGoogle,
      isMobileAccount: userInfo.isMobileAccount,
      googleEmail: userInfo.googleEmail,
      glucoseUnit: userInfo.glucoseUnit,
      firstLinkedAccount: userInfo.firstLinkedAccount,
      activityLevelRate: userInfo.activityLevelRate,
      roadMapId: userInfo.roadMapId,
      diabetes: userInfo.diabetes,
      hasBreakfastSnack: userInfo.hasBreakfastSnack,
      hasLunchSnack: userInfo.hasLunchSnack,
      hasDinnerSnack: userInfo.hasDinnerSnack,
      profession: userInfo.profession,
      educationLevel: userInfo.educationLevel,
      personality: userInfo.personality,
      consciousnessPractice: userInfo.consciousnessPractice,
      religion: userInfo.religion,
      vegetarian: userInfo.vegetarian,
      caredTopic: userInfo.caredTopic,
      personalInterests: userInfo.personalInterests,
      favouriteSports: userInfo.favouriteSports,
      workingHourss: userInfo.workingHourss,
      trainingGroups: userInfo.trainingGroups,
      jobList: userInfo.jobList,
      educationLevelList: userInfo.educationLevelList,
      lessonTagList: userInfo.lessonTagList,
      personalityRuleList: userInfo.personalityRuleList,
      interestRuleList: userInfo.interestRuleList,
      consciousnessPracticeRuleList: userInfo.consciousnessPracticeRuleList,
      vegetarianRuleList: userInfo.vegetarianRuleList,
      workingHourRuleList: userInfo.workingHourRuleList,
      levelOfDiabetesRuleList: userInfo.levelOfDiabetesRuleList,
      favouriteSportRuleList: userInfo.favouriteSportRuleList,
      religionRuleList: userInfo.religionRuleList,
      accountRule: userInfo.accountRule,
      creatorId: userInfo.creatorId,
      energyGoal: userInfo.energyGoal,
      nation: userInfo.nation,
      nameOfAgency: userInfo.nameOfAgency,
      nameOfDoctor: userInfo.nameOfDoctor,
      ownPackage: userInfo.ownPackage,
      isShare: userInfo.isShare,
      shareRefCode: userInfo.shareRefCode,
      statistict: userInfo.statistict,
      sharedProfile: userInfo.sharedProfile,
      checked: false,
      curentWeekPregnancy: userInfo.curentWeekPregnancy,
      weightPregnancy: userInfo.weightPregnancy,
    );
    await UserClient().updateUserInfo(AppSettings.userInfo!.id, userInfo);
    await UserClient().fetchUser();
  }

  editData() async {
    final note = controllerNote.text;

    List<String> paths = [];
    for (var file in files) {
      if (file is PickedFile) {
        paths.add(file.path);
      }
    }
    final result = await WeightClient().putIndexBmi(
        id,
        (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
        selectedWeight.toString(),
        selectedHip.toString(),
        selectedHeight.toString(),
        note,
        selectedTimeFrame?.id,
        removeIDs,
        paths);
    if (result == true) {
      if (AppSettings.userInfo!.weight != selectedWeight &&
          isCurrentBmi == true) {
        await updateHeightProfile();
        Observable.instance
            .notifyObservers([], notifyName: "Weight_change_data");
      }
      emit(DataLoadedState());
    }
  }

  deleteData() async {
    isDelete = true;
    try {
      emit(LoadingState());
      final result = await WeightClient().deleteIndexBmi(id);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "Weight_change_data");
        emit(DataLoadedState());
      }
      // emit(LoadingState());
    } catch (e, _) {
      emit(LoadingCompleteStateWithoutProps());
      if (e is Error) {
        emit(ErrorState(Failure()));
      }
    }
  }

  infoChanged({
    bool? isClicked,
    double? selectedWeight,
    int? selectedHeight,
    int? selectedHip,
    DateTime? selectedDate,
    List<dynamic>? files,
    List<String?>? removeIDs,
    bool? isPregnancy,
  }) {
    emit(LoadingState());
    bool doAction = false;
    this.files = files ?? this.files;
    if (isPregnancy != null) {
      this.isPregnancy = Utils.isGestationalDiabetes();
      getWeightThreshold();
      doAction = true;
    }

    this.removeIDs = removeIDs ?? this.removeIDs;
    this.selectedDate = selectedDate ?? this.selectedDate;
    this.isClicked = isClicked ?? this.isClicked;
    this.selectedHip = selectedHip ?? this.selectedHip;
    this.selectedHeight = selectedHeight ?? this.selectedHeight;
    this.selectedWeight = selectedWeight ?? this.selectedWeight;
    if (this.isPregnancy) {
      if ((selectedHeight != null || selectedWeight != null) &&
          this.selectedHeight != 0 &&
          this.selectedWeight != 0) {
        doAction = true;
        getWeightThreshold();
      }
    } else {
      if ((selectedWeight != null ||
              selectedHeight != null ||
              selectedHip != null) &&
          this.selectedWeight != 0 &&
          this.selectedHeight != 0 &&
          this.selectedHip != 0) {
        doAction = true;
        getWeightThreshold();
      }
    }

    if (selectedDate != null) {
      doAction = true;
      loadTimeFrame();
    }
    if (doAction == false) {
      emit(LoadingCompleteStateWithoutProps());
    }
  }
}
