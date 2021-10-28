import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/notice_change/notice_change_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'select_route.dart';

class SelectRoutePage extends StatefulWidget {
  const SelectRoutePage();

  @override
  _SelectRoutePageState createState() => _SelectRoutePageState();
}

class _SelectRoutePageState extends State<SelectRoutePage> {
  late final SelectRouteCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository appRepository = AppRepository();
    _cubit = SelectRouteCubit(appRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: Scaffold(
        body: CommonPage(
          //TODO: Change background
          background: R.drawable.bg_lesson_detail,
          title: 'Chọn lộ trình',
          bottomSafeArea: true,
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _buildRoute();
            },
            separatorBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 20.h),
                height: 1,
                color: R.color.grayBorder,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoute() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          height: 171.5.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            color: Colors.red,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Lộ trình cho người thể trạng yếu',
          style: TextStyle(
            color: R.color.textDark,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Lộ trình này giúp người có thể trạng yếu giữ được sức khỏe mỗi ngày, nâng cao sức đề kháng',
          style: TextStyle(
            color: R.color.grey_1,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cường độ yếu',
              style: TextStyle(
                color: R.color.orange_1,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              width: 120.w,
              child: ButtonWidget(
                title: 'Tham gia',
                height: 32.h,
                textSize: 14.sp,
                onPressed: () {
                  showDialog(
                        barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                        context: context,
                        builder: (_) => NoticeChangePage(
                          description: 'Bạn đang học lộ trình cho người có thể trạng yếu, bạn có chắc muốn đổi lộ trình khác không?',
                          positiveButtonTitle: 'Xác nhận',
                          onClick: () {
                        }),
                      );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
