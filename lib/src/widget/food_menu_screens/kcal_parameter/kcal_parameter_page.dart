import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/create_menu_request.dart';
import 'package:medical/src/model/response/smart_goal_list_reponse.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/body_parameter/body_parameter.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'kcal_parameter.dart';

class KcalParameterPage extends StatefulWidget {
  final Function(CreateMenuRequest request)? callback;
  final SmartGoalList? smartGoal;

  const KcalParameterPage({Key? key, this.callback, this.smartGoal})
      : super(key: key);

  @override
  _KcalParameterPageState createState() => _KcalParameterPageState();
}

class _KcalParameterPageState extends State<KcalParameterPage> {
  final TextEditingController _controller = TextEditingController();
  late KcalParameterCubit _cubit;
  bool showExpandedText = false;

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = KcalParameterCubit(repository);
    _cubit.getUserTarget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: BlocProvider(
              create: (context) => _cubit,
              child: BlocConsumer<KcalParameterCubit, KcalParameterState>(
                listener: (context, state) {
                  if (state is KcalParameterFailure) {
                    Message.showToastMessage(context, state.error);
                  }
                  if (state is KcalParameterLoading) {
                    BotToast.showLoading();
                  } else {
                    BotToast.closeAllLoading();
                  }
                  if (state is KcalParameterKcalChanged) {
                    if (state.kcal != null) {
                      _controller.text = '${state.kcal}';
                    }
                  }
                },
                builder: (
                  BuildContext context,
                  KcalParameterState state,
                ) {
                  return buildPage(context, state);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, KcalParameterState state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              R.string.diab_parameter.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: R.color.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            R.string.energy_use_per_day.tr(),
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(
                  width: 150,
                  child: CupertinoTextField(
                    controller: _controller,
                    decoration: BoxDecoration(color: R.color.white),
                    textAlign: TextAlign.center,
                    enableInteractiveSelection: false,
                    maxLength: 5,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ),
                    ],
                    style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                    placeholder: '--',
                    placeholderStyle: TextStyle(
                        color: R.color.textDark,
                        fontSize: 50,
                        fontWeight: FontWeight.bold),
                    onChanged: (value) {},
                  ),
                ),
                Container(height: 1, width: 130, color: R.color.gray)
              ]),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  R.string.kcal.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: R.color.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              await showDialog(
                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                context: context,
                builder: (_) => BodyParameterPage(callback: (number) {
                  _controller.text = (number?.round() ?? "--").toString();
                }),
              );
              showExpandedText = true;
              _cubit.refresh();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  R.string.recipe.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: R.color.accentColor,
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: R.color.accentColor,
                )
              ],
            ),
          ),
          Visibility(
            visible: showExpandedText,
            child: Padding(
              padding: const EdgeInsets.only(top: 17),
              child: Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(68, 8, 12, 8),
                    decoration: BoxDecoration(
                      color: R.color.main_6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(
                          text: R.string.text_if.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: R.color.black,
                          ),
                          children: [
                            TextSpan(
                              text: ' ${R.string.increase.tr()} ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: R.color.black,
                              ),
                            ),
                            TextSpan(
                              text: R.string.text_or.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: R.color.black,
                              ),
                            ),
                            TextSpan(
                              text: ' ${R.string.decrease.tr()} ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: R.color.black,
                              ),
                            ),
                            TextSpan(
                              text: R.string.text_warning_change_param.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: R.color.black,
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Image.asset(
                    R.drawable.img_gym_trainer,
                    width: 64,
                    height: 82,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            R.string.have_3_meal.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: R.color.textDark,
            ),
          ),
          const SizedBox(height: 17),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: buildCheckMeal(),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: ButtonWidget(
                  title: R.string.cancel.tr(),
                  backgroundColor: R.color.grayBorder,
                  textColor: R.color.textDark,
                  height: 43,
                  onPressed: () => NavigationUtil.pop(context),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                flex: 1,
                child: ButtonWidget(
                  title: R.string.agree.tr(),
                  height: 43,
                  onPressed: () async {
                    if (widget.smartGoal?.id != null) {
                      await HomeClient().completeSmartGoal(
                        DateTime.now(),
                        widget.smartGoal!.id,
                        1,
                        ScheduleType.food_menu.typeIndex,
                      );
                    }
                    FocusScope.of(context).unfocus();
                    final String text = _controller.text.trim();
                    int? number;

                    if (!Utils.isEmpty(text)) {
                      number = int.parse(text);
                      showDialog(
                        barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                        context: context,
                        builder: (_) => NoticeChangePage(
                            description: R.string.consumption.tr(),
                            onClick: () {
                              Future.delayed(const Duration(milliseconds: 200),
                                  () {
                                if (widget.callback != null && number != null) {
                                  _cubit.createMenuRequest.kcal = number;
                                  widget.callback!(_cubit.createMenuRequest);
                                }
                              });
                              NavigationUtil.pop(context);
                            }),
                      );
                    } else {
                      Message.showToastMessage(
                          context, R.string.ban_chua_nhap_thong_tin.tr());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCheckMeal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildRowCheck(
            title: R.string.no_sub_meal.tr(),
            isChecked: _cubit.isNoSubMeal,
            onChecked: (isChecked) {
              if (isChecked == true) {
                _cubit.onCheckedNoSubMeal();
              }
            }),
        const SizedBox(height: 10),
        Container(
          height: 1,
          margin: const EdgeInsets.only(left: 10),
          width: 170,
          color: R.color.gray,
        ),
        const SizedBox(height: 10),
        buildRowCheck(
            title: R.string.breakfast_meal.tr(),
            isChecked: _cubit.createMenuRequest.includeBreakfast,
            onChecked: (isChecked) {
              _cubit.createMenuRequest.includeBreakfast = isChecked;
              _cubit.refresh();
            }),
        buildRowCheck(
            title: R.string.lunch_meal.tr(),
            isChecked: _cubit.createMenuRequest.includeLunch,
            onChecked: (isChecked) {
              _cubit.createMenuRequest.includeLunch = isChecked;
              _cubit.refresh();
            }),
        buildRowCheck(
            title: R.string.dinner_meal.tr(),
            isChecked: _cubit.createMenuRequest.includeDinner,
            onChecked: (isChecked) {
              _cubit.createMenuRequest.includeDinner = isChecked;
              _cubit.refresh();
            }),
      ],
    );
  }

  Widget buildRowCheck({
    required String title,
    required bool? isChecked,
    required Function(bool isSelected) onChecked,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: isChecked ?? false,
            checkColor: R.color.white,
            activeColor: R.color.accentColor,
            onChanged: (isChecked) {
              FocusScope.of(context).unfocus();
              onChecked(isChecked ?? false);
            },
          ),
        ),
        const SizedBox(width: 22),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: R.color.textDark,
          ),
        ),
      ],
    );
  }
}
