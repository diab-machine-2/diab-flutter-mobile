import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/weight/weight_client.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/widgets/section_input_note.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/widgets/section_select_image.dart';
import 'package:medical/src/widget/base/cubit_base_state.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:easy_localization/easy_localization.dart';
import 'add_bmi_cubit.dart';
import 'widgets/add_bmi_mixin.dart';
import 'widgets/section_app_bar.dart';
import 'widgets/section_datetime.dart';
import 'widgets/section_footer.dart';
import 'widgets/section_input_kpi.dart';
import 'widgets/section_weight_ranges.dart';

class AddBmiView extends StatefulWidget with AddBmiMixin {
  final String? type;
  final String? id;
  final String? goalId;

  AddBmiView({
    this.type,
    this.id,
    this.goalId,
  });

  @override
  State<AddBmiView> createState() => _AddBmiViewState();
}

class _AddBmiViewState extends State<AddBmiView> {
  late AddBmiCubit _cubit;

  @override
  void initState() {
    _cubit = AddBmiCubit(
      type: widget.type,
      id: widget.id,
      goalId: widget.goalId,
    );
    firebaseSetup();
    super.initState();
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "kpi_body_weight_add",
      screenClass: "AddBmiController",
    );
    await TrackingManager.analytics.logEvent(
      name: 'kpi_add_begin',
      parameters: {
        "screen_name": 'kpi_body_weight_add',
        'object_type': 'kpi_body_weight',
        'object_title': 'Chỉ số cân nặng'
      },
    );
    AppSettings.currentScreenName = 'kpi_body_weight_add';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: () async {
            widget.showDialogSave(context, cubit: _cubit);
            return false;
          },
          child: Scaffold(
            backgroundColor: R.color.backgroundColor,
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash), fit: BoxFit.cover),
              ),
              child: BlocConsumer<AddBmiCubit, CubitBaseState>(
                  listener: (context, state) async {
                if (state is ErrorState) {
                  Message.showToastMessage(context, state.failure.message);
                }
                if (state is DataLoadedState) {
                  // if (_cubit.isPregnancy) {
                  //   await UserClient().fetchUser();
                  // }
                  if (_cubit.isDelete) {
                    Message.showToastMessage(
                        context, R.string.xoa_thanh_cong.tr());
                  } else {
                    Message.showToastMessage(
                        context, R.string.luu_thanh_cong.tr());
                  }
                }
              }, builder: (context, state) {
                if (state is LoadingState) {
                  BotToast.showLoading();
                } else {
                  BotToast.closeAllLoading();
                }
                return Column(
                  children: [
                    SectionAppBar(cubit: _cubit),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(15),
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: SpacingColumn(
                              spacing: 40,
                              children: [
                                SectionInputKpi(cubit: _cubit),
                                SectionWeightRanges(cubit: _cubit),
                                SectionDateTime(cubit: _cubit),
                              ],
                            ),
                          ),
                          SizedBox(height: 15),
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: SpacingColumn(
                              separator: Divider(
                                color: R.color.color0xffE5E5E5,
                              ),
                              children: [
                                SectionInputNote(cubit: _cubit),
                                SectionSelectImage(cubit: _cubit),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SectionFooter(cubit: _cubit),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: R.color.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => ActionListTrend(
            selected: _cubit.selectedTimeFrame,
            callback: (value) {
              setState(() {
                _cubit.selectedTimeFrame = value;
              });
            }));
  }

  handleBMI() async {
    BotToast.showLoading();
    if (_cubit.selectedWeight != 0 && _cubit.selectedHeight != 0) {
      final result = await WeightClient()
          .fetchCaculateBMI(_cubit.selectedWeight, _cubit.selectedHeight);
      _cubit.bmiNumber = result.bmi;
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
    }
    BotToast.closeAllLoading();

    setState(() {});
  }
}
