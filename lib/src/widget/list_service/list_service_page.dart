import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:medical/src/widget/detail_package/detail_package.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/upgrade_account/upgrade_account.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'list_service.dart';

class ListServicePage extends StatefulWidget {
  const ListServicePage({Key? key}) : super(key: key);

  @override
  _ListServicePageState createState() => _ListServicePageState();
}

class _ListServicePageState extends State<ListServicePage> {
  late ListServiceCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = ListServiceCubit(repository);
    _cubit.getListPackage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<ListServiceCubit, ListServiceState>(
          listener: (context, state) {
            if (state is ListServiceLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            if (state is ListServiceFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (
            BuildContext context,
            ListServiceState state,
          ) {
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, ListServiceState state) {
    return Scaffold(
      body: CommonPage(
        title: R.string.list_service.tr(),
        background: R.drawable.bg_welcome,
        child: Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                R.drawable.img_list_service,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
              Container(
                  margin: EdgeInsets.only(top: 32.h, left: 8.h, right: 8.h),
                  child: Text(
                    R.string.list_service.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  )),
              Container(
                  margin: EdgeInsets.only(top: 16.h, left: 8.h, right: 8.h),
                  child: Text(
                    R.string.text_list_service.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16.sp,
                    ),
                  )),
              SizedBox(
                height: 32.h,
              ),
              ListView.separated(
                padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _cubit.listFilterData.length,
                  separatorBuilder: (context, index) => SizedBox(
                        height: 16.h,
                      ),
                  itemBuilder: (context, index) {
                    DetailPackageData data = _cubit.listFilterData[index];
                    return rowService(data, () {
                      NavigationUtil.navigatePage(
                          context, UpgradeAccountPage(code: data.code ?? Const.PRO));
                    });
                  }),
              SizedBox(
                height: 27.h,
              ),
              // Container(
              //     width: 128.w,
              //     child: ButtonWidget(
              //         title: R.string.text_continue.tr(),
              //         onPressed: () {
              //           NavigationUtil.navigatePage(
              //               context, UpgradeAccountPage());
              //         }))
            ],
          ),
        ),
      ),
    );
  }

  Widget rowService(DetailPackageData data, VoidCallback onChooseService) {
    Color color = Utils.getColorByCode(data.code);
    String background;
    String icon;
    if (data.code == Const.PRO) {
      background = R.drawable.bg_pro;
      icon = R.drawable.ic_package_pro;
    } else {
      background = R.drawable.bg_premium;
      icon = R.drawable.ic_package_premium;
    }
    return GestureDetector(
      onTap: onChooseService,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 96.h,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16.h)),
            ),
            Positioned(
              left: 0,
              child: Container(
                height: 96.h,
                width: 54.h,
                padding: EdgeInsets.all(5.h),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(background), fit: BoxFit.fill),
                    borderRadius: BorderRadius.circular(5.h)),
                child: Image.asset(
                  icon,
                  fit: BoxFit.contain,
                  // color: color,
                  height: 43.h,
                  width: 43.h,
                ),
              ),
            ),
            Positioned(
              left: 70.h,
              right: 32.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name ?? "",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    data.description ?? "",
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                right: 10.h,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  color: R.color.accentColor,
                ))
          ],
        ),
      ),
    );
  }
}
