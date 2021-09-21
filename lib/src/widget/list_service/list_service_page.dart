import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'list_service.dart';

class ListServicePage extends StatefulWidget {
  const ListServicePage({Key key}) : super(key: key);

  @override
  _ListServicePageState createState() => _ListServicePageState();
}

class _ListServicePageState extends State<ListServicePage> {
  ListServiceCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = ListServiceCubit(repository);
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
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                R.drawable.background_splash
            ),
            fit: BoxFit.fill
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 50.h),
              child: Image.asset(
                R.drawable.img_list_service,
                fit: BoxFit.cover,
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
              height: 35.h,
            ),
            rowService(R.string.service_basic.tr(), R.drawable.bg_basic, () {}),
            SizedBox(
              height: 20.h,
            ),
            rowService(R.string.service_premium.tr(), R.drawable.bg_premium, () {}),
            SizedBox(
              height: 115.h,
            ),
            Container(
                width: 128.w,
                child: ButtonWidget(
                    title: R.string.text_continue.tr(), onPressed: () {}))
          ],
        ),
      ),
    );
  }

  Widget rowService(
      String title, String background, VoidCallback onChooseService) {
    return GestureDetector(
      onTap: onChooseService,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(horizontal: 20.h),
            child: Image.asset(
              background,
              fit: BoxFit.cover,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: R.color.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          )
        ],
      ),
    );
  }
}
