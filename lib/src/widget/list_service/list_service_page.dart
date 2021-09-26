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
import 'package:medical/src/widget/upgrade_account/upgrade_account.dart';
import 'package:medical/src/widgets/background_page.dart';
import 'package:medical/src/widgets/button_widget.dart';

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
            if (state is ListServiceFailure) {
              Utils.showErrorSnackBar(context, state.error);
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
      body: BackgroundPage(
        background: R.drawable.bg_upgrade_account,
        child: Container(
          padding: EdgeInsets.all(16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 50.h),
                child: Image.asset(
                  R.drawable.img_list_service,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
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
                height: 20.h,
              ),
              ListView.separated(
                  shrinkWrap: true,
                  itemCount: _cubit.listFilterData.length,
                  separatorBuilder: (context, index) =>  SizedBox(
                    height: 20.h,
                  ),
                  itemBuilder: (context, index) {
                    DetailPackageData data = _cubit.listFilterData[index];
                    return rowService(data, () {
                      NavigationUtil.navigatePage(context, DetailPackagePage(data: data));
                    });
                  }),
              SizedBox(
                height: 110.h,
              ),
              Container(
                  width: 128.w,
                  child: ButtonWidget(
                      title: R.string.text_continue.tr(), onPressed: () {
                        NavigationUtil.navigatePage(context, UpgradeAccountPage());
                  }))
            ],
          ),
        ),
      ),
    );
  }

  Widget rowService(DetailPackageData data, VoidCallback onChooseService) {
    Color color = Utils.getColorByCode(data.code);
    return GestureDetector(
      onTap: onChooseService,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 50.h,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16.h)),
            ),
            Positioned(
              left: 0,
              child: Container(
                height: 50.h,
                width: 50.h,
                padding: EdgeInsets.all(15.h),
                decoration: BoxDecoration(
                    color: color.withOpacity(1/6),
                    borderRadius: BorderRadius.circular(16.h)),
                child: Image.asset(
                  R.drawable.ic_pro,
                  fit: BoxFit.contain,
                  color: color,
                  height: 20.h,
                  width: 20.h,
                ),
              ),
            ),
            Positioned(
              left: 65.h,
              child: Text(
                data.name ?? "",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: R.color.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
