import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/list_transaction_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/date_utils.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'my_package.dart';

class MyPackagePage extends StatefulWidget {
  @override
  _MyPackagePageState createState() => _MyPackagePageState();
}

class _MyPackagePageState extends State<MyPackagePage> {
  late MyPackageCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = MyPackageCubit(repository);
    _cubit.getListTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<MyPackageCubit, MyPackageState>(
          listener: (context, state) {
            if (state is MyPackageFailure) {
              Utils.showErrorSnackBar(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            MyPackageState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, MyPackageState state) {
    return CommonPage(
      title: R.string.my_package.tr(),
      background: R.drawable.bg_welcome,
      child: ListView(
        shrinkWrap: true,
        children: [
          Visibility(
            visible: _cubit.isBasic,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  R.drawable.img_my_package,
                  width: double.infinity,
                  height: 240.h,
                ),
                SizedBox(
                  height: 32.h,
                ),
                Text(
                  R.string.text_my_package.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16.sp,
                    letterSpacing: 0.4,
                    height: 1.375,
                  ),
                ),
              ],
            ),
          ),
          Visibility(
              visible: !_cubit.isBasic,
              child: listTransactionWidget(_cubit.listActiveTransaction)),
          SizedBox(
            height: 5.h,
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 40.h),
            child: ButtonWidget(
              title: _cubit.isBasic
                  ? R.string.upgrade_package_pro.tr()
                  : R.string.renewal_package_pro.tr(),
              onPressed: () {},
            ),
          ),
          SizedBox(
            height: 50.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h),
            child: Text(
              R.string.history_transaction.tr(),
              textAlign: TextAlign.left,
              style: TextStyle(
                color: R.color.accentColor,
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                letterSpacing: 0.08,
                height: 1.4,
              ),
            ),
          ),
          listTransactionWidget(_cubit.listExpiredTransaction)
        ],
      ),
    );
  }

  Widget listTransactionWidget(List<TransactionData> list) {
    return ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 20.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => Container(
              margin: EdgeInsets.symmetric(vertical: 24.h, horizontal: 10.h),
              alignment: Alignment.center,
              color: R.color.grayBorder,
            ),
        itemBuilder: (context, index) => transactionWidget(list[index]));
  }

  Widget transactionWidget(TransactionData data) {
    bool isExpired = data.isExpired == true;
    bool isPackageSuspended = data.isPackageSuspended == true;
    bool isEmptyCurrent = Utils.isEmpty(_cubit.listActiveTransaction);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                data.packageName ?? "",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: R.color.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  letterSpacing: 0.08,
                  height: 1.4,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.h),
                  color: isExpired ? R.color.grayBorder : R.color.color0xFFC3E8D3,
                ),
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.h),
                child: Text(
                  isExpired
                      ? R.string.status_expired.tr()
                      : R.string.status_actived.tr(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isExpired ? R.color.color0xff787A7D : R.color.green,
                    fontWeight: FontWeight.w400,
                    fontSize: 12.sp,
                    letterSpacing: 0.2,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 12.h,
        ),
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                R.string.number_month
                    .tr(args: [data.monthUsed?.toString() ?? ""]),
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16.sp,
                  letterSpacing: 0.4,
                  height: 1.375,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                R.string.time_period.tr(args: [
                  DateUtil.parseStringDateToString(data.startDate,
                          Const.DATE_TIME_SV_FORMAT, Const.DATE_FORMAT) ??
                      "",
                  DateUtil.parseStringDateToString(data.endDate,
                          Const.DATE_TIME_SV_FORMAT, Const.DATE_FORMAT) ??
                      ""
                ]),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16.sp,
                  letterSpacing: 0.4,
                  height: 1.375,
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: !isExpired,
          child: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    R.string.next_renewal.tr(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                      letterSpacing: 0.4,
                      height: 1.375,
                    ),
                  ),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateUtil.parseStringDateToString(data.endDate,
                        Const.DATE_TIME_SV_FORMAT, Const.DATE_FORMAT) ??
                        "",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                      letterSpacing: 0.4,
                      height: 1.375,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 12.h,
        ),
        Row(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                R.string.service_price.tr(),
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16.sp,
                  letterSpacing: 0.4,
                  height: 1.375,
                ),
              ),
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                Utils.formatMoney(data.totalPrice) ?? "",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16.sp,
                  letterSpacing: 0.4,
                  height: 1.375,
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: isExpired,
          child: Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: isPackageSuspended
                ? Text(R.string.package_deactivate.tr(),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: R.color.red,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      fontSize: 14.sp,
                      letterSpacing: 0.2,
                      height: 1.42857,
                    ))
                : Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            R.string.see_detail.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              letterSpacing: 0.4,
                              height: 1.42857,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Visibility(
                        visible: isEmptyCurrent,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 96.w,
                            child: ButtonWidget(
                              title: R.string.repurchase.tr(),
                              textSize: 14.sp,
                              height: 32.h,
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
