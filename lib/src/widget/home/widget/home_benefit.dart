import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';

class HomeBenefitSection extends StatelessWidget {
  const HomeBenefitSection({Key? key}) : super(key: key);

  void _onTapBenefit(BuildContext context, String bookingType) {
    Navigator.pushNamed(
      context,
      NavigatorName.benefit_page,
      arguments: {
        'bookingType': bookingType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0DB5A6),
            Color(0xFF007A72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            R.string.benefit_title.tr(),
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          // Divider padding top/bottom 16px
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: Colors.white.withOpacity(0.2),
              height: 1.0,
              thickness: 1.0,
            ),
          ),

          // Benefit Options Row
          Row(
            children: [
              // At Clinic Booking
              Expanded(
                child: _buildBenefitItem(
                  context: context,
                  icon: R.icons.ic_benefit_at_clinic,
                  label: R.string.benefit_at_clinic.tr(),
                  onTap: () => _onTapBenefit(context, Const.BENEFIT_BOOKING_AT_CLINIC),
                ),
              ),

              // Telemedicine
              Expanded(
                child: _buildBenefitItem(
                  context: context,
                  icon: R.icons.ic_benefit_telemedicine,
                  label: R.string.benefit_telemedicine.tr(),
                  onTap: () => _onTapBenefit(context, Const.BENEFIT_BOOKING_TELEMEDICINE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Semi-transparent white background container, size 44px
          Container(
            width: 44.0,
            height: 44.0,
            decoration: const BoxDecoration(
              color: Color(0x38FFFFFF), // #FFFFFF38
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: 24.0,
                height: 24.0,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
