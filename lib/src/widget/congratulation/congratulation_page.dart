import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'congratulation.dart';

class CongratulationPage extends StatefulWidget {
  final String code;
  final Price priceData;

  const CongratulationPage(
      {Key? key, required this.code, required this.priceData})
      : super(key: key);

  @override
  _CongratulationPageState createState() => _CongratulationPageState();
}

class _CongratulationPageState extends State<CongratulationPage> {
  late CongratulationCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = CongratulationCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<CongratulationCubit, CongratulationState>(
          listener: (context, state) {
            if (state is CongratulationFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            CongratulationState state,
          ) {
            if (state is CongratulationLoading) {
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

  Widget buildPage(BuildContext context, CongratulationState state) {
    return CommonPage(
          title: R.string.sign_up.tr(),
          background: R.drawable.bg_detail_pro,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                          height: 240,
                          child: Image.asset(widget.code == Const.PRO
                              ? R.drawable.ic_congratulation
                              : R.drawable.img_workaround)),
                      Visibility(
                        visible: widget.code == Const.PRO,
                        child: Container(
                          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: Text(
                            R.string.text_congratulation.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                                letterSpacing: 0.4),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 44,
                      ),
                      Text(
                        R.string.text_please_bank.tr(),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          height: 1.87,
                          // letterSpacing: 0.4
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      bankWidget(widget.priceData)
                    ]),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: ButtonWidget(
                  title: R.string.back_home.tr(),
                  onPressed: () {
                    NavigationUtil.popToFirst(context);
                  },
                  backgroundColor: R.color.white,
                  borderColor: R.color.accentColor,
                  textColor: R.color.accentColor,
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          )
    );
  }

  Widget bankWidget(Price price) {
    PackageBankPayment? bank;
    if (!Utils.isEmpty(price.packageBankPayments)) {
      bank = price.packageBankPayments![0];
    }
    return CardWidget(
      padding: EdgeInsets.all(16),
      borderWidth: 0,
      borderColor: Colors.transparent,
      child: Column(
        children: [
          rowInfoDescription(
              R.string.amount.tr(), Utils.formatMoney(price.totalPrice) ?? ""),
          SizedBox(
            height: 10,
          ),
          rowInfoDescription(
              R.string.account_number.tr(), bank?.bankAccountId ?? "",
              isCopy: true),
          SizedBox(
            height: 10,
          ),
          rowInfoDescription(R.string.bank.tr(), bank?.bankName ?? ""),
          SizedBox(
            height: 10,
          ),
          rowInfoDescription(
              R.string.receiver.tr(), bank?.bankAccountName ?? ""),
          SizedBox(
            height: 10,
          ),
          rowInfoDescription(R.string.content.tr(), bank?.content ?? "",
              isCopy: true),
        ],
      ),
    );
  }

  Widget rowInfoDescription(String label, String text, {bool isCopy = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              textAlign: TextAlign.left,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.37,
                  letterSpacing: 0.4),
            ),
          ),
        ),
        Container(
          width: 25,
          alignment: Alignment.center,
          child: Visibility(
            visible: isCopy,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text)).then((_) {
                  Message.showToastMessage(context, "Copied to clipboard");
                });
              },
              child: Image.asset(
                R.drawable.ic_copy,
                height: 20,
              ),
            ),
          ),
        )
      ],
    );
  }
}
