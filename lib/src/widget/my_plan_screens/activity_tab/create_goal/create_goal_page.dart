import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/custom_date_picker.dart';
import 'package:medical/src/widgets/widget_custom_multi_select_toggle.dart';

import 'create_goal.dart';
import 'models/create_goal_status.dart';
import 'widgets/custom_top_progress_bar.dart';
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
          },
          builder: (context, state) {
            late final List<Widget> body;
            if (_cubit.status == CreateGoalStatus.select_type) {
              body = _buildSelectGoalType();
            } else if (_cubit.status == CreateGoalStatus.setup) {
              body = _buildSetupGoal();
            } else if (_cubit.status == CreateGoalStatus.complete) {
              body = [];
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
                  Visibility(
                    visible: _cubit.status != CreateGoalStatus.select_type,
                    child: SafeArea(
                      top: false,
                      child: Container(
                        height: 48,
                        width: 195,
                        child: ButtonWidget(
                          title: R.string.text_continue.tr(),
                          textSize: 16,
                          onPressed: () {},
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
            _cubit.goToSetup();
          }),
      SelectTypeWidget(
          title: 'Làm một việc yêu thích',
          onTap: () {
            _cubit.goToSetup();
          }),
      SelectTypeWidget(
          title: 'Tần suất theo dõi chỉ số sinh học', onTap: () {}),
      SelectTypeWidget(title: 'Mục tiêu cá nhân', onTap: () {}),
    ];
  }

  List<Widget> _buildSetupGoal() {
    return [
      _buildTextField(),
      _buildTimePicker(title: 'Chọn ngày bắt đầu hoạt động'),
      Row(
        children: [
          Theme(
            data: ThemeData(
              unselectedWidgetColor: R.color.grayBorder,
            ),
            child: Transform.scale(
              scale: 1.3,
              child: Checkbox(
                  value: _cubit.isRepeat,
                  activeColor: R.color.accentColor,
                  splashRadius: 20,
                  onChanged: (value) {
                    if (value != null) {
                      _cubit.onToggleRepeat(value);
                    }
                  }),
            ),
          ),
          Text(
            'Lặp lại',
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
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
        selectedIndex: _cubit.calulateTypeIndex,
        onChange: (newIndex) {
          _cubit.onChangeCalculateType(newIndex);
        },
      ),
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
                const TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.only(left: 0, bottom: 0, top: 8, right: 0),
                      hintText: 'Nhập tên hoạt động'),
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

  Widget _buildTimePicker({String? title}) {
    return _buildItemLayout(
      child: Column(
        children: [
          if (title != null)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title == null)
                        Image.asset(R.drawable.ic_calendar,
                            width: 24, height: 24),
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

  Widget _buildItemLayout({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      child: child,
    );
  }
}
