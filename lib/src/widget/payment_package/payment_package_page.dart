import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/detail_package_data.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/text_field_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'payment_package.dart';

class PaymentPackagePage extends StatefulWidget {

  final String packageName;
  final String packageCode;
  final Price price;

  const PaymentPackagePage({Key? key, required this.packageName, required this.packageCode, required this.price}) : super(key: key);

  @override
  _PaymentPackagePageState createState() => _PaymentPackagePageState();
}

class _PaymentPackagePageState extends State<PaymentPackagePage> {
  late PaymentPackageCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = PaymentPackageCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<PaymentPackageCubit, PaymentPackageState>(
          listener: (context, state) {
            if (state is PaymentPackageFailure) {
              Utils.showErrorSnackBar(context, state.error);
            }
            if (state is PaymentPackageLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
          },
          builder: (
            BuildContext context,
            PaymentPackageState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, PaymentPackageState state) {
    return Scaffold(
      body: CommonPage(
        background: R.drawable.bg_welcome,
        title: R.string.payment.tr(),
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(16.h),
                children: [
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.h,vertical: 12.h),
                      decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(10.sp)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(widget.packageName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: R.color.textDark,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(width: 10),
                              Image.asset(
                                R.drawable.ic_pro,
                                height: 18.h,
                                color: Utils.getColorByCode(widget.packageCode),
                              )
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(R.string.period.tr(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.4,
                                    height: 1.375,)),
                              SizedBox(width: 10),
                              Text(R.string.number_month.tr(args: [(widget.price.monthUsed ?? 0).toString()]),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: R.color.accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                    letterSpacing: 0.08,
                                    height: 1.4,)),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(R.string.amount.tr(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16.sp,
                                    letterSpacing: 0.4,
                                    height: 1.375,)),
                              SizedBox(width: 10),
                              Text(Utils.formatMoney(widget.price.totalPrice) ?? "",
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: R.color.accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp,
                                    letterSpacing: 0.08,
                                    height: 1.4,)),
                            ],
                          ),
                        ],
                      )),
                  SizedBox(height: 14.h),
                  Text(R.string.notice_payment.tr(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: R.color.red,
                        fontStyle: FontStyle.italic,
                        fontSize: 14.sp,
                        letterSpacing: 0.2,
                        height: 1.42857,)),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.h),
              child: ButtonWidget(
                title: R.string.payment.tr(),
                onPressed: () {
                  NavigationUtil.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
