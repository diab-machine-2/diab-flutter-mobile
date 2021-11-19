import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Bmi/widget/add_bmi.dart';
import 'package:medical/src/widget/Food/widget/intensity_food.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'body_parameter.dart';

typedef NumCallback = Function(num?);

class BodyParameterPage extends StatefulWidget {
  final NumCallback? callback;

  const BodyParameterPage({Key? key, this.callback}) : super(key: key);

  @override
  _BodyParameterPageState createState() => _BodyParameterPageState();
}

class _BodyParameterPageState extends State<BodyParameterPage> {
  TextEditingController controller = TextEditingController();
  late BodyParameterCubit _cubit;

  @override
  void initState() {
    final AppRepository repository = AppRepository();
    _cubit = BodyParameterCubit(repository);
    _cubit.getListActivity();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
          child: SingleChildScrollView(
              child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: R.color.white,
                  ),
                  child: BlocProvider(
                    create: (context) => _cubit,
                    child: BlocConsumer<BodyParameterCubit, BodyParameterState>(
                      listener: (context, state) {
                        if (state is BodyParameterFailure) {
                          Message.showToastMessage(context, state.error);
                        }
                        if (state is GetTDEESuccess) {
                          widget.callback!(_cubit.number);
                          UserClient().fetchUser();
                          Navigator.pop(context);
                        }
                      },
                      builder: (
                        BuildContext context,
                        BodyParameterState state,
                      ) {
                        if (state is BodyParameterLoading) {
                          BotToast.showLoading();
                        } else {
                          BotToast.closeAllLoading();
                        }
                        return buildPage(context, state);
                      },
                    ),
                  )))),
    );
  }

  Widget buildPage(BuildContext context, BodyParameterState state) {
    return Column(
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(height: 14),
          parameterWidget(
              title: R.string.can_nang.tr(),
              unit: R.string.kg.tr(),
              dialogTitle: R.string.enter_weight.tr(),
              defaultValue: _cubit.selectedWeight,
              defaultNumber: 50,
              maxNumber: 200,
              valueChange: _cubit.selectWeight),
          SizedBox(height: 16),
          parameterWidget(
              title: R.string.chieu_cao.tr(),
              unit: R.string.cm.tr(),
              dialogTitle: R.string.enter_height.tr(),
              defaultValue: _cubit.selectedHeight,
              defaultNumber: 160,
              maxNumber: 300,
              valueChange: _cubit.selectHeight),
          SizedBox(height: 16),
          parameterWidget(
              title: R.string.nam_sinh.tr(),
              unit: "",
              dialogTitle: R.string.nhap_nam_sinh.tr(),
              defaultValue: _cubit.selectedYear,
              defaultNumber: 1970,
              maxNumber: DateTime.now().year,
              valueChange: _cubit.selectYear),
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(R.string.cuong_do_tap_luyen.tr(),
                  style: TextStyle(
                      fontSize: 14,
                      color: R.color.textDark,
                      letterSpacing: 0.4,
                      height: 1.43,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                      context: context,
                      builder: (_) => ActionListIntensityFood(
                          listIntensity: _cubit.listData,
                          selected: _cubit.intensity,
                          callback: (data) {
                            _cubit.selectIntensity(data);
                          }));
                },
                child: Container(
                  color: R.color.transparent,
                  child: Column(children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _cubit.intensity == null
                                ? R.string.chon_cuong_do_tap_luyen.tr()
                                : _cubit.intensity?.note ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              color: R.color.textDark,
                              letterSpacing: 0.4,
                              height: 1.43,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          size: 17,
                          color: R.color.textDark,
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(height: 1, color: R.color.color0xffE5E5E5)
                  ]),
                ),
              )
            ],
          ),
          SizedBox(height: 30),
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
                  )),
              SizedBox(width: 15),
              Expanded(
                  flex: 1,
                  child: ButtonWidget(
                    title: R.string.text_continue.tr(),
                    height: 43,
                    onPressed: () {
                      _cubit.getTDEE();
                    },
                  )),
            ],
          ),
        ]);
  }

  Widget parameterWidget({
    required String title,
    required String unit,
    required String dialogTitle,
    required int? defaultValue,
    required int defaultNumber,
    required int maxNumber,
    required ValueChanged<int?> valueChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                color: R.color.textDark,
                letterSpacing: 0.4,
                height: 1.43,
                fontWeight: FontWeight.bold)),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(width: 100),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            barrierColor:
                                R.color.color0xff003F38.withOpacity(0.5),
                            context: context,
                            builder: (_) => CustomNumPicker(
                                callback: valueChange,
                                title: dialogTitle,
                                max: maxNumber,
                                numberDefault: defaultValue ?? defaultNumber,
                                unit: unit),
                          );
                        },
                        child: Center(
                          child: Text((defaultValue ?? "--").toString(),
                              style: TextStyle(
                                  color:
                                      defaultValue == null || defaultValue == 0
                                          ? R.color.captionColorGray
                                          : R.color.textDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ),
                      Container(
                          height: 1, width: 100, color: R.color.color0xffE5E5E5)
                    ],
                  ),
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(left: 10),
                    child: Text(unit,
                        style: TextStyle(
                            fontSize: 16,
                            color: R.color.primaryGreyColor,
                            letterSpacing: 0.4,
                            height: 1.37)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
