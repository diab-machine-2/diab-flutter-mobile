import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';

class HomeBenefitSection extends StatelessWidget {
  const HomeBenefitSection({Key? key}) : super(key: key);

  void _onTapBenefitBooking(BuildContext context, String bookingType) {
    Navigator.pushNamed(
      context,
      NavigatorName.benefit_page,
      arguments: {
        'bookingType': bookingType,
      },
    );
  }

  void _onTapViewAll(BuildContext context) {
    // Handle later
  }

  void _onTapBenefitCalendar(BuildContext context) {
    Navigator.pushNamed(
      context,
      NavigatorName.benefit_appointment_history,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 18,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(1.01, 1.13),
          end: const Alignment(0.10, 0.00),
          colors: [
            R.color.benefitBgGradientStart,
            R.color.benefitBgGradientEnd,
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 16,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with arrow button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                R.string.benefit_title.tr(),
                style: const TextStyle(
                  color: AppColors.benefitTitleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              GestureDetector(
                onTap: () => _onTapViewAll(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.benefitArrowButtonBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: AppColors.benefitDividerColor,
              height: 1.0,
              thickness: 1.0,
            ),
          ),

          // Benefit grid - Row 1: 4 items
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BenefitItem(
                icon: R.icons.ic_benefit_at_clinic,
                label: R.string.benefit_at_clinic.tr(),
                onTap: () =>
                    _onTapBenefitBooking(context, Const.BENEFIT_BOOKING_AT_CLINIC),
              ),
              _BenefitItem(
                icon: R.icons.ic_benefit_telemedicine,
                label: R.string.benefit_telemedicine.tr(),
                onTap: () =>
                    _onTapBenefitBooking(context, Const.BENEFIT_BOOKING_TELEMEDICINE),
              ),
              _BenefitItem(
                icon: R.icons.ic_benefit_at_home,
                label: R.string.benefit_at_home.tr(),
                onTap: null,
              ),
              _BenefitItem(
                icon: R.icons.ic_benefit_calendar,
                label: R.string.benefit_calendar.tr(),
                onTap: () => _onTapBenefitCalendar(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Benefit grid - Row 2: 3 items
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BenefitItem(
                icon: R.icons.ic_benefit_medicine,
                label: R.string.benefit_medicine.tr(),
                onTap: null,
              ),
              _BenefitItem(
                icon: R.icons.ic_benefit_lab_testing,
                label: R.string.benefit_lab_testing.tr(),
                onTap: null,
              ),
              _BenefitItem(
                icon: R.icons.ic_benefit_other,
                label: R.string.benefit_other.tr(),
                onTap: null,
              ),
              // Invisible spacer to match the 4-column grid
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const _BenefitItem({
    Key? key,
    required this.icon,
    required this.label,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container
            Container(
              width: 44,
              height: 44,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                gradient: const LinearGradient(
                  begin: Alignment(1.00, 0.00),
                  end: Alignment(0.00, 1.00),
                  colors: [
                    AppColors.benefitIconGradientStart,
                    AppColors.benefitIconGradientEnd,
                  ],
                ),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: AppColors.benefitIconBorder,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 5,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  icon,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Label — no fixed height; scales with system font size
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context)
                      .textScaler
                      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.benefitTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
