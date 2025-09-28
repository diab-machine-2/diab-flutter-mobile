import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';

class BmiInstructionSession extends StatelessWidget {
  const BmiInstructionSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read<BmiBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            R.string.glucose_intro_help_title.tr(),
            style: R.style.alertTitle,
          ),
        ),
        BlocBuilder<BmiBloc, BmiState>(
            buildWhen: (_, state) => state is BmiGetInstructionState,
            builder: (context, state) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1 / 1),
                itemBuilder: (context, index) => _BmiInstructionCard(
                  lesson: _bmiBloc.lessons[index],
                  onTap: (lesson) => _onTap(context, lesson),
                ),
                itemCount: _bmiBloc.lessons.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              );
            }),
      ],
    );
  }

  void _onTap(BuildContext context, BmiWeightLesson lesson) async {
    ActivityListTracking.clickLessonItem(
      objectId: lesson.id,
      objectIndex: null,
      objectTitle: null,
    );

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: lesson.type,
        lessonId: "${lesson.id}",
        onComplete: (_, __) {},
      ),
    );
  }
}

class _BmiInstructionCard extends StatelessWidget {
  const _BmiInstructionCard({super.key, required this.lesson, this.onTap});

  final BmiWeightLesson lesson;
  final Function(BmiWeightLesson lesson)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap?.call(lesson),
      child: Container(
        decoration: R.decorationStyle.mediumRadiusCardStyles,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.mediumRadius),
                  topRight: Radius.circular(AppDimens.mediumRadius),
                ),
                child: CachedNetworkImage(
                  imageUrl: lesson.image?.url ?? "",
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.neutral5,
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 56,
                      color: AppColors.neutral3,
                    ),
                  ),
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                lesson.name ?? "--",
                style: R.style.normalTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
          ],
        ),
      ),
    );
  }
}
