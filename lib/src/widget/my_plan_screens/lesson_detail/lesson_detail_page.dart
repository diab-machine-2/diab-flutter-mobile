import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/background_page.dart';

class LessonDetailPage extends StatefulWidget {
  const LessonDetailPage();

  @override
  _LessonDetailPageState createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundPage(
        background: R.drawable.bg_lesson_detail,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.h),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Phần 1/9',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        NavigationUtil.pop(context);
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        size: 24,
                        color: R.color.grey_2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Bệnh đái tháo đường là gì, chẩn đoán như thế nào?',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: Container(color: Colors.blue),
            ),
            Container(
              color: R.color.white,
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: R.color.main_6,
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chevron_left_rounded,
                          size: 20.w,
                          color: R.color.greenGradientBottom,
                        ),
                        Text(
                          'Quay lại',
                          style: TextStyle(
                            color: R.color.accentColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showLessonCategoryList();
                    },
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: R.color.accentColor),
                      ),
                      child: Text(
                        '1/9',
                        style: TextStyle(
                          color: R.color.accentColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: R.color.main_6,
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Tiếp theo',
                          style: TextStyle(
                            color: R.color.accentColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20.w,
                          color: R.color.greenGradientBottom,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).padding.bottom,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void showLessonCategoryList() {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
      ),
      builder: (BuildContext context) {
        return Scaffold(
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60.w,
                    height: 6.h,
                    margin: EdgeInsets.only(top: 12.h, bottom: 18.h),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Text(
                      'Danh mục bài học',
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      child: ListView.separated(
                          padding: EdgeInsets.only(bottom: 32.h),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return _buildSingleLessonCategory();
                          },
                          separatorBuilder: (context, index) {
                            return Container(
                              color: R.color.color0xffE5E5E5,
                              height: 1,
                              width: double.infinity,
                            );
                          }),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        NavigationUtil.pop(context);
                      },
                      child: Container(
                        height: 36.w,
                        width: 36.w,
                        child: Image.asset(
                          R.drawable.ic_close_border,
                          color: R.color.accentColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSingleLessonCategory({bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
          color: isSelected ? R.color.greenbg : R.color.white,
          border: isSelected ? Border.all(color: R.color.notActiveGreen) : null,
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Image.asset(
            R.drawable.ic_play,
            width: 24,
            height: 24,
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Text(
              'Bệnh đái tháo đường là gì, chẩn đoán như thế nào?',
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Visibility(
            visible: false,
            child: Padding(
              padding: EdgeInsets.only(left: 14.w),
              child: Image.asset(
                R.drawable.ic_check_mark,
                width: 24,
                height: 24,
              ),
            ),
          )
        ],
      ),
    );
  }
}
