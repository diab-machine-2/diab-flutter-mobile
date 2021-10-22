import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/utils/navigation_util.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    required this.sectionList,
    required this.currentSection,
    required this.onChangeSection,
  });

  final List<LessonSectionListResponseData?> sectionList;
  final int currentSection;
  final Function(int newIndex) onChangeSection;

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  late int currentSection;

  @override
  void initState() {
    currentSection = widget.currentSection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.white,
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
                      itemCount: widget.sectionList.length,
                      itemBuilder: (context, index) {
                        return _buildSingleLessonCategory(
                            sectionDetail: widget.sectionList[index],
                            isSelected: index == currentSection,
                            onTap: () {
                              currentSection = index;
                              widget.onChangeSection(index);
                              setState(() {});
                            });
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
  }

  Widget _buildSingleLessonCategory({
    required LessonSectionListResponseData? sectionDetail,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
            color: isSelected ? R.color.greenbg : R.color.white,
            border:
                isSelected ? Border.all(color: R.color.notActiveGreen) : null,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Image.asset(
              sectionDetail?.icon ?? '',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Text(
                sectionDetail?.name ?? '',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Visibility(
              visible: sectionDetail?.isComplete ?? false,
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
      ),
    );
  }
}
