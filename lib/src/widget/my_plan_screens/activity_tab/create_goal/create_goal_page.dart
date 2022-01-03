import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/custom_date_picker.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';

import '../../../../widgets/select_bottom_sheet_widget.dart';
import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';
import 'widgets/custom_top_progress_bar.dart';
import 'widgets/enter_time_widget.dart';
import 'widgets/exercise_time_widget.dart';
import 'widgets/select_type_widget.dart';

class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage();

  @override
  _CreateGoalPageState createState() => _CreateGoalPageState();
}

class _CreateGoalPageState extends State<CreateGoalPage> {
  late final CreateGoalCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = CreateGoalCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BlocConsumer<CreateGoalCubit, CreateGoalState>(
            listener: (context, state) {
              if (state is CreateGoalLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }
              if (state is CreateGoalFailure) {
                Message.showToastMessage(context, state.error);
              }
              if (state is CreateGoalCompleted) {
                NavigationUtil.pop(context);
              }
            },
            builder: (context, state) {
              late final List<Widget> body;
              if (_cubit.status == CreateGoalStatus.select_type) {
                body = _buildSelectGoalType();
              } else if (_cubit.status == CreateGoalStatus.setup) {
                body = _buildSetupGoal();
              } else if (_cubit.status == CreateGoalStatus.complete) {
                body = _buildSetupCompleteGoal();
              } else {
                body = [];
              }
              return CommonPage(
                // TODO(Tuyen): Change background
                background: R.drawable.bg_lesson_detail,
                title: R.string.setup_smart_goal_title.tr(),
                showCloseBackButton: true,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomTopProgressBar(_cubit.status,
                          onSelect: (newStatus) {
                        _cubit.onSelectStatus(newStatus);
                      }),
                    ),
                    Expanded(
                      child: ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                        children: body,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: _cubit.status != CreateGoalStatus.select_type,
                      child: SafeArea(
                        top: false,
                        child: Container(
                          height: 48,
                          width: 195,
                          child: ButtonWidget(
                            title: _cubit.status == CreateGoalStatus.complete
                                ? R.string.completed.tr()
                                : R.string.text_continue.tr(),
                            textSize: 16,
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              _cubit.onTapNext();
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectGoalType() {
    return [
      Text(
        R.string.select_smart_goal_type.tr(),
        style: TextStyle(
          color: R.color.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 24),
      SelectTypeWidget(
          title: R.string.create_new_habit.tr(),
          backgroundColor: R.color.main_6,
          icon: R.drawable.ic_smart_goal_new_goal,
          onTap: () {
            _cubit.setupGoal();
          }),
      SelectTypeWidget(
          title: R.string.do_a_favorite_thing.tr(),
          backgroundColor: R.color.color0xffFFE3E3,
          icon: R.drawable.ic_smart_goal_new_habit,
          onTap: () {
            _cubit.setupGoal();
          }),
      SelectTypeWidget(
        title: R.string.biometric_monitoring_frequency.tr(),
        backgroundColor: R.color.orange_6,
        icon: R.drawable.ic_smart_goal_new_biological,
        onSlectType: (type) async {
          if (type == ScheduleType.blood_sugar) {
            Navigator.pushNamed(context, NavigatorName.schedule_glucose);
          } else {
            if (type == ScheduleType.exercise) {
              await _cubit.getUserTarget();
            }
            _cubit.setupGoal(selectedType: type);
          }
        },
        subList: const [
          ScheduleType.blood_pressure,
          ScheduleType.blood_sugar,
          ScheduleType.exercise,
          ScheduleType.weight,
          ScheduleType.emotion,
          ScheduleType.food,
        ],
      ),
      SelectTypeWidget(
        title: R.string.personal_smart_goal.tr(),
        backgroundColor: R.color.color0xFFFFF7C0,
        icon: R.drawable.ic_smart_goal_new_own_goal,
        onTap: () {
          Navigator.pushNamed(context, NavigatorName.goal_setting);
        },
      ),
    ];
  }

  List<Widget> _buildSetupGoal() {
    if (_cubit.dataModel.type?.setupTypeUIIndex == 1) {
      return _buildSetupGoalType1();
    }
    if (_cubit.dataModel.type?.setupTypeUIIndex == 2) {
      return _buildSetupGoalType2();
    }
    return _buildSetupGoalDefault();
  }

  List<Widget> _buildSetupCompleteGoal() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: Image.asset(R.drawable.img_select_route_successed),
      ),
      Container(
        margin: const EdgeInsets.only(top: 24, bottom: 16),
        alignment: Alignment.center,
        child: Text(
          R.string.smart_setup_completed.tr(),
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            _buildSingleResultDetail(
              title: R.string.smart_goal_name.tr(),
              description: _cubit.dataModel.type == null ||
                      _cubit.dataModel.type == ScheduleType.custom
                  ? _cubit.dataModel.name
                  : (_cubit.dataModel.type?.title ?? ''),
            ),
            if (_cubit.dataModel.goalRecordType == GoalRecordType.time &&
                _cubit.dataModel.type != ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: R.string.goal_record_type_time.tr(),
                  description: '${_cubit.dataModel.goalTimeOrFrequency} phút'),
            if (_cubit.dataModel.goalRecordType == GoalRecordType.frequency &&
                _cubit.dataModel.type != ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: R.string.goal_record_type_frequency.tr(),
                  description: '${_cubit.dataModel.goalTimeOrFrequency} lần'),
            if (_cubit.dataModel.type == ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: R.string.so_phut_van_dong_moi_ngay.tr(),
                  description:
                      '${Utils.parseStringToInt(_cubit.dataModel.dailyTargetDuration)} phút'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSetupGoalDefault() {
    return [
      _buildTextField(),
      EnterTimeWidget(
        title: _cubit.dataModel.goalRecordType.title,
        type: _cubit.dataModel.goalRecordType,
        onChangedTime: (text) {
          _cubit.dataModel.goalTimeOrFrequency = text;
        },
        onChangeUnit: (type) {
          _cubit.dataModel.goalRecordType = type;
        },
        controller:
            TextEditingController(text: _cubit.dataModel.goalTimeOrFrequency),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CustomCheckboxWidget(
            isChecked: _cubit.dataModel.isRepeat,
            title: R.string.repeat.tr(),
            onTap: () {
              FocusScope.of(context).unfocus();
              _cubit.onToggleRepeat();
            }),
      ),
      _buildSetupRepeat(),
    ];
  }

  List<Widget> _buildSetupGoalType1() {
    return [
      _buildTextDescription(),
      EnterTimeWidget(
        title: R.string.frequency_per_day.tr(),
        type: GoalRecordType.frequency,
        selectable: false,
        onChangedTime: (text) {
          _cubit.dataModel.goalTimeOrFrequency = text;
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CustomCheckboxWidget(
            isChecked: _cubit.dataModel.isRepeat,
            title: R.string.repeat.tr(),
            onTap: () {
              FocusScope.of(context).unfocus();
              _cubit.onToggleRepeat();
            }),
      ),
      _buildSetupRepeat(),
    ];
  }

  List<Widget> _buildSetupGoalType2() {
    return [
      _buildTextDescription(),
      ExerciseTimeWidget(
          totalMinutes:
              _cubit.dataModel.userInfo?.dailyTargetDuration?.toInt() ?? 0,
          onChangedTime: (totalMinutes) {
            _cubit.dataModel.dailyTargetDuration = totalMinutes.toString();
          }),
    ];
  }

  Widget _buildTextField() {
    return _buildItemLayout(
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                R.drawable.ic_enter_target_name,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                R.string.smart_goal_name.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Container(
            color: R.color.transparent,
            child: Column(
              children: [
                TextField(
                  controller:
                      TextEditingController(text: _cubit.dataModel.name),
                  autofocus: false,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                          left: 0, bottom: 0, top: 8, right: 0),
                      hintText: R.string.enter_smart_goal_name.tr()),
                  onChanged: (text) {
                    _cubit.dataModel.name = text;
                  },
                ),
                Container(height: 1, color: R.color.color0xffE5E5E5),
                const SizedBox(height: 8),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSetupRepeat() {
    return Visibility(
      visible: _cubit.dataModel.isRepeat,
      child: Column(
        children: [
          _buildItemLayout(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Image.asset(
                        R.drawable.ic_clock,
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        R.string.select_frequency.tr(),
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    showActionFilter(
                        context: context,
                        builder: (context) {
                          return SelectBottomSheetWidget(
                            title: R.string.select_frequency.tr(),
                            selectedList: [_cubit.dataModel.repeatType.title],
                            elementList: [
                              RepeatType.day.title,
                              RepeatType.week.title
                            ],
                            onSelected: (typeList) {
                              if (typeList.isNotEmpty) {
                                _cubit.onChangeRepeatType(typeList.first);
                              }
                            },
                          );
                        });
                  },
                  child: Container(
                    color: R.color.transparent,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _cubit.dataModel.repeatType.title,
                                style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 24,
                              color: R.color.primaryGreyColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(height: 1, color: R.color.color0xffE5E5E5),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Visibility(
            visible: _cubit.dataModel.repeatType == RepeatType.week,
            child: _buildItemLayout(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      showActionFilter(
                          context: context,
                          builder: (context) {
                            return SelectBottomSheetWidget(
                              title: R.string.select_frequency.tr(),
                              selectedList: _cubit.dataModel.repeatDayList
                                  .map((e) => e.title)
                                  .toList(),
                              elementList: DayInWeekExtend.dayInWeekList
                                  .map((e) => e.title)
                                  .toList(),
                              onSelected: (dayList) {
                                if (dayList != null) {
                                  _cubit.onChangeRepeatDay(dayList);
                                }
                              },
                              isMultipleChoice: true,
                            );
                          });
                    },
                    child: Container(
                      color: R.color.transparent,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(R.drawable.ic_calendar,
                                  width: 24, height: 24),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: _cubit.dataModel.repeatDayList
                                      .map(
                                        (day) => Container(
                                          height: 24,
                                          alignment: Alignment.center,
                                          margin:
                                              const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: R.color.grayBorder),
                                          ),
                                          child: Text(day.shortTitle,
                                              style: R.style.normalTextStyle),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(height: 1, color: R.color.color0xffE5E5E5),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          _buildTimePicker(
              initDate: _cubit.dataModel.endDate,
              title: R.string.select_end_date.tr(),
              onPickDate: (dateTime) {
                _cubit.dataModel.endDate = dateTime;
              },
              minDate: DateTime.now()),
          const SizedBox(height: 24)
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String title,
    required DateTime initDate,
    required Function(DateTime dateTime) onPickDate,
    required DateTime? minDate,
    DateTime? maxDate,
  }) {
    return _buildItemLayout(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Image.asset(
                  R.drawable.ic_calendar,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              showDialog(
                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                context: context,
                builder: (_) => CustomDatePicker(
                  initDate: initDate,
                  callback: (DateTime date) {
                    onPickDate(date);
                    _cubit.emit(CreateGoalPickedDate(date));
                  },
                  minDate: minDate,
                  maxDate: maxDate,
                ),
              );
            },
            child: Container(
              color: R.color.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(initDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(height: 1, color: R.color.color0xffE5E5E5),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSingleResultDetail({
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: Text(
              description,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DiaB khuyến nghị:',
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text('''
      - Nếu huyết áp của bạn ổn định, hãy đo 1- 3 ngày/tuần
      - Nếu huyết áp của bạn chưa ổn định, hãy đo 3 - 7 ngày/tuần''',
            style: R.style.normalTextStyle),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                showDescriptionPopup('''
- Nếu huyết áp của bạn ổn định, hãy đo 1- 3 ngày/tuần
- Nếu huyết áp của bạn chưa ổn định, hãy đo 3 - 7 ngày/tuần
Dù chưa biết lý do vì sao có sự tương quan đáng kể giữa đái tháo đường và tăng huyết áp nhưng người ta giả định rằng béo phì, chế độ ăn uống nhiều natri và lười vận động dẫn đến sự gia tăng đồng thời cả hai bệnh trên.
Tăng huyết áp được biết đến như một “kẻ giết người thầm lặng” vì nó không có triệu chứng rõ ràng. Một cuộc khảo sát năm 2002 của Hiệp hội Đái tháo đường Hoa Kỳ (ADA) cho thấy, khoảng 68% những người bị bệnh đái tháo đường không biết họ cũng có nguy cơ gia tăng bệnh tim và đột quỵ vì liên quan đến tăng huyết áp mạn tính.''');
              },
              child: Text(
                'Tôi cần thêm thông tin',
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemLayout(
      {required Widget child,
      EdgeInsetsGeometry? margin,
      bool isValid = true}) {
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        border: isValid ? null : Border.all(color: Colors.red),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: child,
    );
  }

  showActionFilter(
      {required BuildContext context,
      required Widget Function(BuildContext) builder}) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: builder,
    );
  }

  void showDescriptionPopup(String? message) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.9),
      useSafeArea: true,
      barrierDismissible: true,
      context: context,
      builder: (_) => PopupWindowWidget(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Image.asset(
                  R.drawable.img_des,
                  height: 80,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Center(
                    child: Text(R.string.dia_recommand.tr(),
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              ]),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    message ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                      letterSpacing: 0.4,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
