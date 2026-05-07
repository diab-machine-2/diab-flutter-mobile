import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_tab/lesson_tab_cubit.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import 'lesson_search_page.dart';
import '../lesson_detail/lesson_detail.dart';

/// Detail screen for a module: app bar with back + module name, list of lessons.
class ModuleLessonsPage extends StatelessWidget {
  final String moduleName;
  final List<MyLessonResponseData?> lessons;
  final LessonTabCubit cubit;

  const ModuleLessonsPage({
    Key? key,
    required this.moduleName,
    required this.lessons,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(
              Icons.arrow_back_outlined,
              color: R.color.white,
              size: 24,
            ),
            onPressed: () {
              NavigationUtil.pop(context);
            },
          ),
          leadingWidth: 36,
          titleSpacing: 0,
          title: Text(
            moduleName,
            style: TextStyle(
              color: R.color.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: false,
          backgroundColor: R.color.greenGradientBottom,
          iconTheme: IconThemeData(
            color: R.color.white,
            size: 20,
          ),
          actions: [
            IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(
                Icons.search,
                color: R.color.white,
                size: 24,
              ),
              onPressed: () {
                NavigationUtil.navigatePage(
                  context,
                  const LessonSearchPage(),
                );
              },
            ),
          ],
        ),
        backgroundColor: R.color.backgroundColorNew,
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return Column(
              children: [
                _ModuleLessonRow(
                  lesson: lesson,
                  cubit: cubit,
                ),
                if (index != lessons.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 2,
                    color: Color(0xFFEAEDEE),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ModuleLessonRow extends StatelessWidget {
  final MyLessonResponseData? lesson;
  final LessonTabCubit cubit;

  const _ModuleLessonRow({
    Key? key,
    required this.lesson,
    required this.cubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        PhoneValidationManager.setShouldShowPhoneValidation();
        if (lesson?.learningStatus == Const.LESSON_CAN_NOT_LEARN) {
          // simple toast; upgrade popup is shown in main page
          return;
        }
        if (lesson?.learningStatus == Const.LESSON_LOCKED) {
          return;
        }
        if (lesson?.id?.isNotEmpty == true) {
          final nonNullLesson = lesson!;
          ActivityListTracking.clickLessonItem(
            objectId: nonNullLesson.id!,
            objectIndex: 0,
            objectTitle: nonNullLesson.name,
          );
          await NavigationUtil.navigatePage(
            context,
            LessonDetailPage(
              lessonType: nonNullLesson.type,
              lessonId: nonNullLesson.id!,
              onComplete: (lessonId, percentComplete) {
                cubit.updateStatusLesson(
                  lessonId: lessonId,
                  percentComplete: percentComplete,
                );
              },
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        constraints: const BoxConstraints(minHeight: 87),
        alignment: Alignment.center,
        color: R.color.transparent,
        child: Row(
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              height: 87,
              width: 87,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: NetWorkImageWidget(imageUrl: lesson?.image?.url),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lesson?.module?.isNotEmpty == true)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson?.module ?? '',
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 24,
                          color: R.color.greenGradientBottom,
                        ),
                      ],
                    ),
                  GapH(4),
                  Text(
                    lesson?.name ?? '',
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  GapH(4),
                  LessonStatusWidget(
                    learningStatus: lesson?.learningStatus,
                    progress: lesson?.percentComplete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
