import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/custom_date_picker.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';

import '../../../../widgets/select_bottom_sheet_widget.dart';
import '../activity_tab/models/schedule_type.dart';
import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'models/day_in_week.dart';
import 'models/goal_record_type.dart';
import 'models/repeat_type.dart';
import 'widgets/custom_top_progress_bar.dart';
import 'widgets/select_type_widget.dart';

class CreateGoalPage extends StatefulWidget {
  const CreateGoalPage({this.type});
  final ScheduleType? type;

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
    if (widget.type != null) {
      _cubit.setupGoal(selectedType: widget.type);
    }
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
                title: R.string.select_road_map.tr(),
                showCloseBackButton: true,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomTopProgressBar(_cubit.status),
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
        'Chọn loại mục tiêu',
        style: TextStyle(
          color: R.color.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 24),
      SelectTypeWidget(
          title: 'Tạo thói quen mới',
          onTap: () {
            _cubit.setupGoal();
          }),
      SelectTypeWidget(
          title: 'Làm một việc yêu thích',
          onTap: () {
            _cubit.setupGoal();
          }),
      SelectTypeWidget(
        title: 'Tần suất theo dõi chỉ số sinh học',
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
          ScheduleType.hba1c,
          ScheduleType.food,
        ],
      ),
      SelectTypeWidget(
        title: 'Mục tiêu cá nhân',
        onTap: () {
          Navigator.pushNamed(context, NavigatorName.goal_setting);
        },
      ),
    ];
  }

  List<Widget> _buildSetupGoal() {
    if (_cubit.type?.setupTypeUIIndex == 1) {
      return _buildSetupGoalType1();
    }
    if (_cubit.type?.setupTypeUIIndex == 2) {
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
          'Bạn đã cài đặt mục tiêu thành công!',
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
            if (_cubit.type == null || _cubit.type == ScheduleType.custom)
              _buildSingleResultDetail(
                  title: 'Tên hoạt động', description: _cubit.name),
            if (_cubit.goalRecordType == GoalRecordType.time &&
                _cubit.type != ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: 'Thời gian thực hiện',
                  description: '${_cubit.goalTimeOrFrequency} phút'),
            if (_cubit.goalRecordType == GoalRecordType.frequency &&
                _cubit.type != ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: 'Số lần thực hiện',
                  description: '${_cubit.goalTimeOrFrequency} lần'),
            if (_cubit.type == ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: 'Số phút vận động mỗi ngày',
                  description:
                      '${_cubit.parseString(_cubit.dailyTargetDuration)} phút'),
            if (_cubit.type == ScheduleType.exercise)
              _buildSingleResultDetail(
                  title: 'Số phút vận động mỗi tuần',
                  description:
                      '${_cubit.parseString(_cubit.weeklyTargetDuration)} phút'),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSetupGoalDefault() {
    return [
      _buildTextField(),
      _buildTimePicker(title: 'Chọn ngày bắt đầu hoạt động'),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CustomCheckboxWidget(
            isChecked: _cubit.isRepeat,
            title: 'Lặp lại',
            onTap: () {
              FocusScope.of(context).unfocus();
              _cubit.onToggleRepeat();
            }),
      ),
      _buildSetupRepeat(),
      RichText(
        text: TextSpan(
          text: 'Tính mục tiêu đề ra',
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          children: [
            const TextSpan(text: ' '),
            TextSpan(
              text: '(Vui lòng chọn 1 trong 2 cách)',
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      CustomMultiSelectToggle(
        toggleList: const ['Thời gian thực hiện', 'Số lần thực hiện'],
        selectedIndex: _cubit.goalRecordType.index,
        onChange: (newIndex) {
          FocusScope.of(context).unfocus();
          _cubit.onChangeCalculateType(newIndex);
        },
      ),
      _buildTimeOrFrequency(
        title: _cubit.goalRecordType.title,
        unit: _cubit.goalRecordType.unit,
        onChanged: (text) {
          _cubit.goalTimeOrFrequency = text;
        },
      ),
    ];
  }

  List<Widget> _buildSetupGoalType1() {
    return [
      _buildTextDescription(),
      _buildTimePicker(title: 'Chọn ngày bắt đầu hoạt động'),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CustomCheckboxWidget(
            isChecked: _cubit.isRepeat,
            title: 'Lặp lại',
            onTap: () {
              FocusScope.of(context).unfocus();
              _cubit.onToggleRepeat();
            }),
      ),
      _buildSetupRepeat(),
      _buildTimeOrFrequency(
        title: 'Số lần thực hiện trong ngày',
        unit: 'lần',
        onChanged: (text) {
          _cubit.goalTimeOrFrequency = text;
        },
      ),
    ];
  }

  List<Widget> _buildSetupGoalType2() {
    return [
      _buildTextDescription(),
      _buildTimeOrFrequency(
          title: 'Số phút vận động mỗi ngày',
          unit: 'phút',
          onChanged: (text) {
            _cubit.dailyTargetDuration = text;
          },
          controller: TextEditingController()
            ..text = '${_cubit.userInfo?.dailyTargetDuration?.toInt() ?? 0}'),
      _buildTimeOrFrequency(
          title: 'Số phút vận động mỗi tuần',
          unit: 'phút',
          onChanged: (text) {
            _cubit.weeklyTargetDuration = text;
          },
          controller: TextEditingController()
            ..text = '${_cubit.userInfo?.weeklyTargetDuration?.toInt() ?? 0}'),
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
                'Tên hoạt động',
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
                  autofocus: false,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.only(left: 0, bottom: 0, top: 8, right: 0),
                      hintText: 'Nhập tên hoạt động'),
                  onChanged: (text) {
                    _cubit.name = text;
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
      visible: _cubit.isRepeat,
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
                        'Chọn mức độ thường xuyên',
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
                            title: 'Chọn mức độ thường xuyên',
                            selectedList: [_cubit.repeatType.title],
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
                                _cubit.repeatType.title,
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
            visible: _cubit.repeatType == RepeatType.week,
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
                              title: 'Chọn mức độ thường xuyên',
                              selectedList: _cubit.repeatDayList
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
                                  children: _cubit.repeatDayList
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
          _buildTimePicker(title: 'Chọn ngày kết thúc'),
          const SizedBox(height: 24)
        ],
      ),
    );
  }

  Widget _buildTimePicker({required String title}) {
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
                  initDate: _cubit.startDate,
                  callback: (DateTime date) {
                    _cubit.startDate = date;
                  },
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
                        DateFormat('dd/MM/yyyy').format(_cubit.startDate),
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

  Widget _buildTimeOrFrequency(
      {required String title,
      required String unit,
      required Function(String text) onChanged,
      TextEditingController? controller}) {
    return _buildItemLayout(
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                R.drawable.ic_clock,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                color: R.color.transparent,
                width: 70,
                child: TextField(
                    controller: controller,
                    autofocus: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textFieldGrey,
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: '-',
                      contentPadding: EdgeInsets.only(
                        left: 0,
                        bottom: 0,
                        top: 8,
                        right: 0,
                      ),
                    ),
                    onChanged: onChanged),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Container(height: 1, width: 70, color: R.color.color0xffE5E5E5),
          const SizedBox(height: 8),
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
            Text(
              'Tôi cần thêm thông tin',
              style: TextStyle(
                color: R.color.greenGradientBottom,
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
}
