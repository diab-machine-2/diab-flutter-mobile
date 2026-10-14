import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/home_remote_config.dart';

import '../schema/home_schema.dart';

/// Home "Chăm sóc hằng ngày" grid (Figma 22514:9678): rows of 3 tiles, the
/// last one being "Xem tất cả".
class HomeUtilities extends StatelessWidget {
  const HomeUtilities({
    super.key,
    required this.utilities,
    required this.onTap,
    this.showHealthProfileDot = false,
  });

  static const int columns = 3;

  final List<HomeUtilityData> utilities;
  final ValueChanged<HomeUtilityData> onTap;

  /// Red dot on the "Hồ sơ sức khoẻ" tile (unviewed exam result).
  final bool showHealthProfileDot;

  @override
  Widget build(BuildContext context) {
    final rows = <List<HomeUtilityData>>[
      for (var i = 0; i < utilities.length; i += columns)
        utilities.sublist(i, (i + columns).clamp(0, utilities.length)),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: R.color.homeCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.home_daily_care_title.tr(),
            style: TextStyle(
              color: R.color.homeTitleText,
              fontSize: 18,
              height: 1.32,
              fontWeight: FontWeight.w700,
            ),
          ),
          for (final row in rows) ...[
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < columns; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: i < row.length
                          ? _buildTile(row[i])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTile(HomeUtilityData utility) {
    final showDot =
        showHealthProfileDot && utility.slug == HomeDailyCareSlug.healthProfile;
    return Material(
      color: R.color.homeDailyCareTileBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => onTap(utility),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SvgPicture.asset(utility.icon, width: 24, height: 24),
                  if (showDot)
                    Positioned(
                      top: 0,
                      right: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: R.color.homeAlertRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                utility.gridTitle ?? utility.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: R.color.homeTitleText,
                  fontSize: 12,
                  height: 1.5,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
