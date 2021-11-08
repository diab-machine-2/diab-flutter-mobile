import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';
import 'package:medical/src/utils/navigation_util.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    required this.sectionList,
    required this.currentSection,
    required this.onChangeSection,
  });

  final List<LessonSectionListResponseDataLessonSections?> sectionList;
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 6,
                margin: const EdgeInsets.only(top: 12, bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Danh mục bài học',
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Scrollbar(
                  child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 32),
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
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: () {
                    NavigationUtil.pop(context);
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    child: Image.asset(
                      R.drawable.ic_close_border,
                      color: R.color.accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleLessonCategory({
    required LessonSectionListResponseDataLessonSections? sectionDetail,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
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
              color: R.color.grey_1,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                sectionDetail?.name ?? '',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Visibility(
              visible: sectionDetail?.isComplete ?? false,
              child: Padding(
                padding: const EdgeInsets.only(left: 14),
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
