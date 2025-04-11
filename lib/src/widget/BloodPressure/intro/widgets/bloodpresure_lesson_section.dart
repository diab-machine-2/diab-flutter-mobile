import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/glucose/intro_lesson/glucose_intro_lesson_bloc.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class BloodPressureLessonSection extends StatelessWidget {
  BloodPressureLessonSection({super.key, required this.onLessonTap});

  final Function(LessonModel) onLessonTap;

  double get _height => 220.0;
  final double _lessonItemWidth = 240.0;

  final _bloc = GlucoseIntroLessonBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child:
          BlocBuilder<GlucoseIntroLessonBloc, GlucoseIntroLessonState>(builder: (context, state) {
        if (state is GlucoseIntroLessonLoaded) {
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
                        child: _buildLessonItem(lessons[index]), width: _lessonItemWidth);
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
      height: _height,
      width: _lessonItemWidth,
      child: InkWell(
        onTap: () => onLessonTap(lesson),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetWorkImageWidget(
                imageUrl: lesson.image?.url,
                fit: BoxFit.cover,
                height: 150.0,
                width: double.infinity,
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  lesson.name,
                  maxLines: 2,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 16,
                    height: 24 / 16,
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
