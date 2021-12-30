import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/upgrade_account/upgrade_account.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'register_package.dart';

class RegisterPackagePage extends StatefulWidget {
  final String code;
  final Price priceData;

  const RegisterPackagePage(
      {Key? key, required this.code, required this.priceData})
      : super(key: key);

  @override
  _RegisterPackagePageState createState() => _RegisterPackagePageState();
}

class _RegisterPackagePageState extends State<RegisterPackagePage> {
  late RegisterPackageCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = RegisterPackageCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<RegisterPackageCubit, RegisterPackageState>(
          listener: (context, state) {
            if (state is RegisterPackageFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            RegisterPackageState state,
          ) {
            if (state is RegisterPackageLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, RegisterPackageState state) {
    return Scaffold(
      body: CommonPage(
          title: R.string.sign_up.tr(),
          background: R.drawable.bg_detail_pro,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 35,
                          ),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: "Bạn cần hoàn thành lần lượt theo ",
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                height: 1.375,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: "2 bước",
                                    style: TextStyle(
                                      color: R.color.textDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      height: 1.375,
                                    )),
                                TextSpan(
                                    text: " sau:",
                                    style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 16,
                                      height: 1.375,
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: double.infinity,
                            child: CardWidget(
                              padding: EdgeInsets.all(16),
                              borderWidth: 0,
                              borderColor: Colors.transparent,
                              backgroundImage: R.drawable.bg_register_package_pro,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    R.string.step_1.tr().replaceAll(":", ""),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: R.color.accentColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                      letterSpacing: 0.4
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: "Nâng cấp tài khoản\nlên gói ",
                                      style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        height: 1.375,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: R.string.diab_pro.tr(),
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              height: 1.375,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: double.infinity,
                            child: CardWidget(
                              padding: EdgeInsets.all(16),
                              borderWidth: 0,
                              borderColor: Colors.transparent,
                              backgroundImage: R.drawable.bg_register_package_premium,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    R.string.step_2.tr().replaceAll(":", ""),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        color: R.color.accentColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                        letterSpacing: 0.4
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  RichText(
                                    textAlign: TextAlign.start,
                                    text: TextSpan(
                                      text: "Thanh toán gói\ndịch vụ ",
                                      style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        height: 1.375,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: R.string.diab_premium.tr(),
                                            style: TextStyle(
                                              color: R.color.textDark,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              height: 1.375,
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(R.string.time.tr() + ":",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 16,
                                            letterSpacing: 0.4,
                                            height: 1.375,
                                          )),
                                      SizedBox(width: 10),
                                      Text(
                                          R.string.number_month.tr(args: [
                                            (widget.priceData.monthUsed ?? 0).toString()
                                          ]),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: R.color.accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            letterSpacing: 0.08,
                                            height: 1.4,
                                          )),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(R.string.service_price.tr() + ":",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 16,
                                            letterSpacing: 0.4,
                                            height: 1.375,
                                          )),
                                      SizedBox(width: 10),
                                      Text(
                                          Utils.formatMoney(widget.priceData.totalPrice) ??
                                              "",
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            color: R.color.accentColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            letterSpacing: 0.08,
                                            height: 1.4,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Text(
                            R.string.text_notice_upgrade_premium.tr(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              height: 1.37,
                              letterSpacing: 0.4
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                        ]),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: ButtonWidget(
                  title: R.string.upgrade_package_pro.tr(),
                  onPressed: () {
                    NavigationUtil.navigatePage(context, UpgradeAccountPage(code: 'Const.PRO', isBuyDirect: false,));
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          )),
    );
  }
}
