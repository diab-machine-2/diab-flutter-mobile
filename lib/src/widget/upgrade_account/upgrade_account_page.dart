import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description_detail.dart';
import 'package:medical/src/widget/detail_package/detail_package_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/card_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/popup_window_widget.dart';

import 'upgrade_account.dart';

class UpgradeAccountPage extends StatefulWidget {
  const UpgradeAccountPage({Key? key}) : super(key: key);

  @override
  _UpgradeAccountPageState createState() => _UpgradeAccountPageState();
}

class _UpgradeAccountPageState extends State<UpgradeAccountPage> {
  late UpgradeAccountCubit _cubit;

  var data = [
    {
      'name': "Mở khoá gói Coaching",
      'text': "Kết nối 1 - 1 với huấn luyện viên",
    },
    {
      'name': "Gợi ý lịch đo đường huyết",
      'text': "Lịch đo mẫu dựa trên cơ sở y học",
    },
    {
      'name': "Đánh giá lối sống toàn diện",
      'text': "Chuyên gia sẽ góp ý cho bạn lịch sinh hoạt phù hợp",
    }
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = UpgradeAccountCubit(repository);
    _cubit.getUpgradeAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<UpgradeAccountCubit, UpgradeAccountState>(
          listener: (context, state) {
            if (state is UpgradeAccountFailure) {
              Utils.showErrorSnackBar(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            UpgradeAccountState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, UpgradeAccountState state) {
    return Scaffold(
      body: CommonPage(
        title: R.string.upgrade_account.tr(),
        background: R.drawable.bg_home,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(16.h),
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.h),
                  color: R.color.white),
              child: Column(children: [
                Image.asset(
                  R.drawable.img_list_service,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  margin: EdgeInsets.all(16.h),
                  child: Text(
                    "TRẢI NGHIỆM NHIỀU TÍNH NĂNG HỮU ÍCH VỚI GÓI DIAB PRO",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                Column(
                  children: data
                      .map((e) =>
                          rowInfoDescription(e["name"] ?? "", e["text"] ?? ""))
                      .toList(),
                ),
                Container(
                  margin:
                      EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          title: R.string.see_detail.tr(),
                          onPressed: () {
                            NavigationUtil.navigatePage(context, DetailPackagePage(data: null,));
                          },
                          backgroundColor: R.color.white,
                          borderColor: R.color.accentColor,
                          textColor: R.color.accentColor,
                        ),
                      ),
                      SizedBox(
                        width: 15.w,
                      ),
                      Expanded(
                        child: ButtonWidget(
                            title: R.string.sign_up.tr(), onPressed: () {}),
                      )
                    ],
                  ),
                )
              ]),
            ),
            SizedBox(
              height: 24.h,
            ),
            tableComparison(),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
                child: ButtonWidget(
                  title: R.string.continue_basic_package.tr(),
                  onPressed: () {},
                  backgroundColor: R.color.white,
                  borderColor: R.color.accentColor,
                  textColor: R.color.accentColor,
                ))
          ],
        ),
      ),
    );
  }

  Widget tableComparison() {
    List<TableRow> listRow = [];
    listRow.add(TableRow(children: [
      tableCell(
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10.h)),
              color: R.color.color0xffB1DDDB),
          padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 10.h),
          child: Text(R.string.feature.tr(),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: R.color.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              )),
        ),
      ),
      tableCell(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: R.color.color0xffB1DDDB),
          child: Text(R.string.basic.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.color.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              )),
        ),
      ),
      tableCell(
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topRight: Radius.circular(10.h)),
              color: R.color.color0xffB1DDDB),
          child: Text(R.string.pro.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: R.color.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              )),
        ),
      ),
    ]));
    listRow.addAll((_cubit.listData ?? []).map((e) {
      int index = _cubit.listData?.indexOf(e) ?? 0;
      bool isLast = index + 1 == _cubit.listData?.length;
      return TableRow(children: [
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: !isLast ? Radius.zero : Radius.circular(10.h)),
                color:
                    index % 2 == 0 ? R.color.white : R.color.color0xffB1DDDB),
            padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      showDialog(
                        barrierColor: R.color.color0xff003F38.withOpacity(0.9),
                        useSafeArea: true,
                        barrierDismissible: true,
                        context: context,
                        builder: (_) => PopupWindowWidget(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.name ?? "",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: R.color.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                letterSpacing: 0.08,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                             e.description ?? "",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16.sp,
                                letterSpacing: 0.4,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        )),
                      );
                    },
                    child: Image.asset(
                      R.drawable.ic_question_circle,
                      color: R.color.accentColor,
                      fit: BoxFit.fill,
                      height: 24.h,
                    )),
                SizedBox(
                  width: 16.w,
                ),
                Expanded(
                  child: Text(
                    e.name ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color:
                    index % 2 == 0 ? R.color.white : R.color.color0xffB1DDDB),
            child: Image.asset(
              e.toggleStatus?.isEnableBasic == true
                  ? R.drawable.ic_mark
                  : R.drawable.ic_x,
              height: 26.h,
            ),
          ),
        ),
        tableCell(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: !isLast ? Radius.zero : Radius.circular(10.h)),
                color:
                    index % 2 == 0 ? R.color.white : R.color.color0xffB1DDDB),
            child: Image.asset(
              e.toggleStatus?.isEnablePro == true
                  ? R.drawable.ic_mark
                  : R.drawable.ic_x,
              height: 26.h,
            ),
          ),
        ),
      ]);
    }));
    return Table(
      border: TableBorder(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: FlexColumnWidth(), // fixed to 100 width
        1: FixedColumnWidth(80.h),
        2: FixedColumnWidth(50.h), //fixed to 100 width
      },
      children: listRow,
    );
  }

  TableCell tableCell({required Widget child, double? height}) {
    return TableCell(
      child: SizedBox(height: height ?? 74.h, child: child),
    );
  }

  Widget rowInfoDescription(String title, String description) {
    return Container(
      margin: EdgeInsets.only(top: 16.h, left: 16.h, right: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            R.drawable.ic_pro,
            height: 20.h,
            fit: BoxFit.fill,
          ),
          SizedBox(
            width: 12.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 3),
                Text(
                  description,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
