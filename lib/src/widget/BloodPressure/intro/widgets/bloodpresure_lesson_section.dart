import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/intro_lesson/bloodpressure_intro_lesson_bloc.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class BloodPressureLessonSection extends StatelessWidget {
  BloodPressureLessonSection({super.key, required this.onLessonTap});

  final Function(LessonModel) onLessonTap;

  double get _height => 220.0;
  final double _lessonItemWidth = 240.0;

  final _bloc = BloodPressureIntroLessonBloc();

  // Calculate the maximum height needed for lesson items
  // Image: 170px + Padding: 32px + Text (2 lines): ~48px + Spacing: 4px + Category: 16px + Divider: 1px + Actions: 40px = ~311px
  // Adding some buffer for safety
  double _calculateMaxItemHeight(List<LessonModel> lessons) {
    // Base height calculation
    const imageHeight = 170.0;
    const paddingVertical = 16.0; // 8px top + 8px bottom
    const textHeight = 48.0; // 2 lines * 24px line height
    const spacing = 4.0;
    const categoryHeight = 16.0;
    const dividerHeight = 1.0;
    const actionsHeight = 40.0;
    const borderWidth = 2.0; // 1px border on each side
    const buffer = 10.0; // Safety buffer for text rendering variations

    return imageHeight +
        paddingVertical +
        textHeight +
        spacing +
        categoryHeight +
        dividerHeight +
        actionsHeight +
        borderWidth +
        buffer;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<BloodPressureIntroLessonBloc,
          BloodPressureIntroLessonState>(builder: (context, state) {
        if (state is BloodPressureIntroLessonLoaded) {
          final lessons = state.lessons;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Gợi ý khoá học',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: R.color.dark,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // List of items
              SizedBox(
                height: _calculateMaxItemHeight(lessons),
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return SizedBox(
                        child: _buildLessonItem(lessons[index]),
                        width: _lessonItemWidth);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 12);
                  },
                  itemCount: lessons.length,
                ),
              ),

              const SizedBox(height: 16),
            ],
          );
        }
        // Hide when loading or error
        return SizedBox();
      }),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return SizedBox(
      width: _lessonItemWidth,
      child: InkWell(
        onTap: () => onLessonTap(lesson),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: lesson.image?.url,
                  fit: BoxFit.cover,
                  height: 170.0,
                  width: double.infinity,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 15.0,
                        height: 24.0 / 15.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    // Category
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          R.drawable.ic_lesson_category,
                          width: 16.0,
                          height: 16.0,
                        ),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            lesson.module,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: R.color.color0xff666666,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: R.color.color0xffE5E5E5,
              ),

              // Actions
              SizedBox(
                height: 40,
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_lesson_share,
                            width: 20.0, height: 20.0),
                        const SizedBox(width: 8.0),
                        Text(
                          R.string.share.tr(),
                          style: TextStyle(
                              color: R.color.textDark, fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
