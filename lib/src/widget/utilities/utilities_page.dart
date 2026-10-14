import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/home_daily_care.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

/// "Chăm sóc hàng ngày – Xem tất cả" (Figma 22514:8801 / 22514:8917).
class UtilitiesPage extends StatelessWidget {
  UtilitiesPage({super.key, required this.utilities});

  final List<HomeUtilityData> utilities;
  // Ignores a repeat tap within 500ms (acts on the first tap immediately).
  final _tapGuard = _TapGuard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.homeHeaderGradientTop,
                  R.color.homeHeaderGradientBottom,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: R.color.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        R.string.home_daily_care_title.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: R.color.white,
                          fontSize: 18,
                          height: 1.32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < utilities.length; i++) ...[
                      if (i > 0)
                        Divider(
                            height: 1,
                            thickness: 1,
                            color: R.color.homeCardBorder),
                      _buildItem(context, utilities[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, HomeUtilityData utility) {
    return InkWell(
      onTap: () =>
          _tapGuard.run(() => HomeDailyCareNavigator.open(context, utility)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: R.color.color0xffF4F7F7,
                borderRadius: BorderRadius.circular(14),
              ),
              child: SvgPicture.asset(utility.icon, width: 24, height: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    utility.title,
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 15,
                      height: 1.46,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (utility.subtitle?.isNotEmpty == true)
                    Text(
                      utility.subtitle!,
                      style: TextStyle(
                        color: R.color.color0xff5E6566,
                        fontSize: 13,
                        height: 1.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, size: 20, color: R.color.color0xffDADEDF),
          ],
        ),
      ),
    );
  }
}

class _TapGuard {
  DateTime? _lastTapAt;

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastTapAt = now;
    action();
  }
}
