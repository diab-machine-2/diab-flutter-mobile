import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/app_setting/branchio_link_config.dart';
import 'package:medical/src/app_setting/dynamic_link_config.dart';

import '../../../../../model/response/lesson_section_list_response.dart';

class ShareLessonButton extends StatelessWidget {
  final LessonSectionItem lesson;
  final String? featureImage;
  final String? lessonDescription;
  const ShareLessonButton({
    Key? key,
    required this.lesson,
    required this.featureImage,
    required this.lessonDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _onShareLesson(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 3,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: R.color.mainColor,
            )),
        child: Row(
          children: [
            SvgPicture.asset(
              R.icons.ic_share,
              color: R.color.mainColor,
              width: 18,
            ),
            SizedBox(width: 5),
            Text(
              R.string.share,
              style: TextStyle(
                fontSize: 14,
                color: R.color.mainColor,
                fontWeight: FontWeight.w500,
              ),
            ).tr(),
          ],
        ),
      ),
    );
  }

  _onShareLesson(BuildContext context) async {
    String shareLink = await BranchioLinkConfig.instance
        .createShareLessonLink(lesson: lesson, featureImage: featureImage, lessonDescription: lessonDescription);
    AppShare.instance.lessonDetail(context, shareLink, lesson.name ?? "");
  }
}
