import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/src/app_setting/app_sharing.dart';
import 'package:medical/src/model/response/bmi_get_weight_lessons_response.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';

class BmiOnBoardingPostCard extends StatelessWidget {
  const BmiOnBoardingPostCard({
    super.key,
    this.margin,
    required this.lesson,
    this.onTap,
  });

  final EdgeInsetsGeometry? margin;
  final BmiWeightLesson lesson;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6)
            .add(margin ?? EdgeInsets.zero),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: R.color.color0xffDFE4E4),
            borderRadius: BorderRadius.circular(AppDimens.mediumRadius)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.mediumRadius),
                    topRight: Radius.circular(AppDimens.mediumRadius)),
                child: CachedNetworkImage(
                  imageUrl: (lesson.image?.url ?? "").isNotEmpty
                      ? lesson.image?.url ?? ""
                      : _bmiBloc.getImageUrl(lesson.image?.id) ?? "",
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.neutral5,
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 56,
                      color: AppColors.neutral4,
                    ),
                  ),
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                ),
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                lesson.name ?? lesson.description ?? "--",
                style: R.style.normalTextStyle,
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _Category(
                category: lesson.lessonModule?.name ?? "--",
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Divider(),
            _ShareButton(
              onTap: () => _onShareTapped(
                context,
                sharedUrl: lesson.linkShare,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onShareTapped(
    BuildContext context, {
    String? sharedUrl,
  }) {
    if (sharedUrl != null) {
      AppShare.instance.userReferralCode(context, sharedUrl);
    }
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 12,
          top: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              R.drawable.ic_lesson_share,
              width: 20.0,
              height: 20.0,
              color: AppColors.neutral4,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              R.string.share.tr(),
              style: R.style.normalTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    super.key,
    required this.category,
  });

  final String category;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Expanded(
          child: Text(
            category,
            style: R.style.smallTextStyle.copyWith(color: AppColors.neutral3),
          ),
        ),
      ],
    );
  }
}
