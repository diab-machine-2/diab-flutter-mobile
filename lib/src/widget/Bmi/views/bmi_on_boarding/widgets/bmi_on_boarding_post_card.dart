import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';

class BmiOnBoardingPostCard extends StatelessWidget {
  const BmiOnBoardingPostCard({
    super.key,
    this.margin,
  });

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6)
          .add(margin ?? EdgeInsets.zero),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: R.color.color0xffDFE4E4),
          borderRadius: BorderRadius.circular(AppDimens.mediumRadius)),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.mediumRadius),
                  topRight: Radius.circular(AppDimens.mediumRadius)),
              child: CachedNetworkImage(
                imageUrl:
                    "https://images.squarespace-cdn.com/content/v1/607f89e638219e13eee71b1e/1684821560422-SD5V37BAG28BURTLIXUQ/michael-sum-LEpfefQf4rU-unsplash.jpg",
                fit: BoxFit.cover,
                width: double.maxFinite,
              ),
            ),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text("uuiuiuiouiopa sss sss"),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: const _Category(),
          ),
          const SizedBox(
            height: 8.0,
          ),
          Divider(),
          _ShareButton()
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({
    super.key,
  });

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
            "category",
            style: R.style.smallTextStyle.copyWith(color: AppColors.neutral3),
          ),
        ),
      ],
    );
  }
}
