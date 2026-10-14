import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/home/home_daily_care.dart';
import 'package:medical/src/widget/home/home_remote_config.dart';

/// Home "Quyền lợi" section for bundle users (Figma 22514:9630): brand strip,
/// two booking cards, and shortcuts from Remote Config
/// `HOME_BENEFIT_SHORTCUTS`.
class HomeBenefitSection extends StatelessWidget {
  const HomeBenefitSection(
      {super.key, required this.hasRecord, this.shortcutsConfig});

  /// With an exam result the clinic card reads "Đặt khám / Chọn bác sĩ và giờ
  /// khám"; without one, "Khám tại phòng khám / Chọn giờ khám".
  final bool hasRecord;

  /// `HOME_BENEFIT_SHORTCUTS` value; null reads Remote Config (tests pass it).
  final String? shortcutsConfig;

  void _openBooking(BuildContext context, String bookingType) {
    Navigator.pushNamed(context, NavigatorName.benefit_page,
        arguments: {'bookingType': bookingType});
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = HomeBenefitShortcutsConfig.parse(
      shortcutsConfig ?? FirebaseRemoteSetting.instance.homeBenefitShortcuts,
      isAvailable: (slug) => _shortcut(slug) != null,
    ).map(_shortcut).whereType<_Shortcut>().toList();
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: R.color.homeCardBorder),
      ),
      child: Column(
        children: [
          _buildBrandStrip(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              children: [
                // Same height for both cards (the taller one wins). Safe: the
                // rings SVG is Positioned, so it is not asked for intrinsics.
                IntrinsicHeight(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _BookingCard(
                        icon: R.icons.ic_ql_tu_van_bac_si,
                        title: hasRecord
                            ? R.string.home_benefit_book_clinic.tr()
                            : R.string.kham_tai_phong_kham.tr(),
                        subtitle: hasRecord
                            ? R.string.home_benefit_book_clinic_desc.tr()
                            : R.string.home_benefit_at_clinic_desc.tr(),
                        primary: true,
                        onTap: () => _openBooking(
                            context, Const.BENEFIT_BOOKING_AT_CLINIC),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _BookingCard(
                        icon: R.icons.ic_ti_kham_tu_xa,
                        title: R.string.kham_tu_xa.tr(),
                        subtitle: R.string.home_benefit_telemedicine_desc.tr(),
                        primary: false,
                        onTap: () => _openBooking(
                            context, Const.BENEFIT_BOOKING_TELEMEDICINE),
                      ),
                    ),
                  ],
                )),
                if (shortcuts.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Divider(
                      height: 1, thickness: 1, color: R.color.homeCardBorder),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0;
                          i < HomeBenefitShortcutsConfig.maxCount;
                          i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: i < shortcuts.length
                              ? _buildShortcut(context, shortcuts[i])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Brand strip. BE-1: logo and program description will come from the
  /// backend; until then they are the Figma values (AXON).
  Widget _buildBrandStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: R.color.color0xffF4F7F7,
        border: Border(bottom: BorderSide(color: R.color.homeCardBorder)),
      ),
      child: Row(
        children: [
          Image.asset(R.drawable.logo_axon,
              width: 76, height: 15, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Container(width: 1, height: 32, color: R.color.color0xffDADEDF),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.string.benefit_title.tr(),
                  style: TextStyle(
                    color: R.color.homeTitleText,
                    fontSize: 18,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  R.string.home_benefit_tagline.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: R.color.color0xff5E6566,
                    fontSize: 11,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcut(BuildContext context, _Shortcut shortcut) {
    return InkWell(
      onTap: () => shortcut.onTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: R.color.homeMetricCircleBg,
              shape: BoxShape.circle,
              border: Border.all(color: R.color.homeShortcutCircleBorder),
            ),
            child: SvgPicture.asset(shortcut.icon, width: 24, height: 24),
          ),
          const SizedBox(height: 7),
          Text(
            shortcut.label,
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
    );
  }

  /// Shortcut catalog keyed by [HomeBenefitShortcutSlug].
  static _Shortcut? _shortcut(String slug) {
    switch (slug) {
      case HomeBenefitShortcutSlug.appointments:
        return _Shortcut(
          R.icons.ic_ti_dat_lich_kham,
          R.string.benefit_calendar.tr(),
          (context) => Navigator.pushNamed(
              context, NavigatorName.benefit_appointment_history),
        );
      case HomeBenefitShortcutSlug.buyMedicine:
        return _Shortcut(
          R.icons.ic_ti_mua_thuoc,
          R.string.benefit_medicine.tr(),
          (context) => Navigator.pushNamed(
              context, NavigatorName.benefit_medicine_intro),
        );
      case HomeBenefitShortcutSlug.labTest:
        return _Shortcut(
          R.icons.ic_ti_xet_nghiem,
          R.string.benefit_lab_testing.tr(),
          (context) => Navigator.pushNamed(
              context, NavigatorName.benefit_lab_test_intro),
        );
      case HomeBenefitShortcutSlug.homeVisit:
        final atHome = FirebaseRemoteSetting.instance.benefitAtHomeInfo;
        if (atHome == null || atHome.trim().isEmpty) return null;
        return _Shortcut(
          R.icons.ic_ti_kham_tai_nha,
          R.string.benefit_at_home.tr(),
          HomeDailyCareNavigator.openAtHome,
        );
      case HomeBenefitShortcutSlug.promotion:
        return _Shortcut(
          R.icons.ic_benefit_other,
          R.string.promotion.tr(),
          (context) =>
              Navigator.pushNamed(context, NavigatorName.benefit_my_voucher),
        );
      case HomeBenefitShortcutSlug.viewAll:
        return _Shortcut(
          R.icons.ic_ti_xem_tat_ca,
          R.string.view_all.tr(),
          (context) => Navigator.pushNamed(
              context, NavigatorName.benefit_introduce_bundle),
        );
    }
    return null;
  }
}

class _Shortcut {
  const _Shortcut(this.icon, this.label, this.onTap);

  final String icon;
  final String label;
  final void Function(BuildContext context) onTap;
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? R.color.homeAccentTeal : R.color.homeBenefitSecondaryBg,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        // At least Figma's 132; taller when text wraps (English, large
        // text). The Row above uses IntrinsicHeight so both cards match.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 132),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                // Figma: rings overhang the card's right edge by ~42px.
                right: -42,
                top: -46,
                child: SvgPicture.asset(
                  primary
                      ? R.icons.ic_home_benefit_rings_primary
                      : R.icons.ic_home_benefit_rings_secondary,
                  width: 150,
                  height: 150,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: R.color.white,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(icon, width: 24, height: 24),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primary
                                ? R.color.white
                                : R.color.homeBenefitSecondaryTitle,
                            fontSize: 15,
                            height: 1.46,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primary
                                ? R.color.homeBenefitPrimaryDesc
                                : R.color.homeBenefitSecondaryDesc,
                            fontSize: 12,
                            height: 1.5,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
