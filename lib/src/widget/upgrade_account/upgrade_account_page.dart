import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

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
      'name': "Mở khoá gói Coaching",
      'text': "Kết nối 1 - 1 với huấn luyện viên",
    },
    {
      'name': "Mở khoá gói Coaching",
      'text': "Kết nối 1 - 1 với huấn luyện viên",
    }
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = UpgradeAccountCubit(repository);
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
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10.h), color: R.color.white),
              child: Column(
                children: [
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
                  Column(children: data
                      .map((e) =>
                      rowInfoDescription(e["name"] ?? "", e["text"] ?? ""))
                      .toList(),),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.h, vertical: 24.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ButtonWidget(
                            title: R.string.see_detail.tr(),
                            onPressed: () {},
                            backgroundColor: R.color.white,
                            borderColor: R.color.accentColor,
                            textColor: R.color.accentColor,
                          ),
                        ),
                        SizedBox(width: 15.w,),
                        Expanded(
                          child: ButtonWidget(
                              title: R.string.sign_up.tr(), onPressed: () {}),
                        )
                      ],
                    ),
                  )
                ]
              ),
            ),

            Container(
                margin: EdgeInsets.all(16.h),
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
