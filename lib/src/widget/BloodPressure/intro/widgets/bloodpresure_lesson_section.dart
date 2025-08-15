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
                height: _height,
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
      height: 252.0,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: lesson.image?.url,
                  fit: BoxFit.cover,
                  height: 174.0,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 12.0),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.name,
                        maxLines: 2,
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
                          // const SizedBox(width: 16.0),
                          Image.asset(
                            R.drawable.ic_lesson_category,
                            width: 16.0,
                            height: 16.0,
                          ),
                          const SizedBox(width: 6.0),
                          Text(
                            lesson.module,
                            style: TextStyle(
                              color: R.color.color0xff666666,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12.0),
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
