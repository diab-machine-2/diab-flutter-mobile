import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/model/subscription_package_model.dart';
import 'package:medical/src/widget/subscription/services/subscription_service.dart';
import 'package:medical/src/widget/subscription/widgets/feature_item_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class PackageDetailBottomSheet extends StatelessWidget {
  final SubscriptionPackage package;
  final Function() onPurchase;

  const PackageDetailBottomSheet({
    Key? key,
    required this.package,
    required this.onPurchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SingleChildScrollView(
        // padding: EdgeInsets.fromLTRB(
        //     16, 8, 16, 16 + MediaQuery.of(context).padding.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientTop02,
                      ),
                    ),
                    Text(
                      '${package.price}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  SubscriptionService.getBadgeImageFromId(package.id),
                  width: 78,
                  height: 78,
                ),
              ],
            ),
            Divider(color: R.color.color0xffEDEEEE),
            GapH(8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: package.features.length,
              itemBuilder: (context, index) => FeatureItemWidget(
                feature: package.features[index],
              ),
            ),
            GapH(16),
            Container(
              height: 48,
              decoration: BoxDecoration(
                  color: R.color.mainColor,
                  borderRadius: BorderRadius.circular(200),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                      colors: [
                        R.color.greenGradientTop,
                        R.color.greenGradientBottom
                      ])),
              child: Center(
                child: Text(
                  R.string.sign_up.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
