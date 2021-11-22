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
import 'create_goal.dart';

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
            return CommonPage(
              //TODO: Change background
              background: R.drawable.bg_lesson_detail,
              title: R.string.select_road_map.tr(),
              showCloseBackButton: true,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    // color: Colors.red,
                    child: const Text('App Bar'),
                  ),
                  Expanded(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildTextField(),
                        const SizedBox(height: 16),
                        _buildTimePicker(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                print('LOG onTap');
                              },
                              child: Text(
                                'Lặp lại',
                                style: TextStyle(
                                  color: R.color.green,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      height: 48,
                      width: 195,
                      child: ButtonWidget(
                        title: R.string.save.tr(),
                        textSize: 16,
                        onPressed: () {},
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

  Widget _buildTextField() {
    return _buildItemLayout(
      child: Column(
        children: [
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
                      hintText: "Hint here"),
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

  Widget _buildTimePicker() {
    return _buildItemLayout(
      child: Column(
        children: [
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
