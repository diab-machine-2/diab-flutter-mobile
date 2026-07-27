import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
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

  void _onTapBenefitAtHome(BuildContext context) {
    final item = MyBenefitItem.fromJson({
      'itemId': 'partner-003',
      'itemType': BenefitBundleItemType.partnerIntro.value,
      'name': 'WeCare247',
      'isUnlimited': 0,
      'quantity': 1,
      'quantityUsed': 0,
      'discountValue': 5,
      'discountType': 0,
      'benefitType': {
        'id': 'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
        'title': 'WeCare247',
        'contentType': 2,
        'contentValue': '',
        'description':
            'WeCare247 là đơn vị cung cấp dịch vụ chăm sóc sức khỏe cá nhân tại nhà và tại bệnh viện, thành lập năm 2017 với sứ mệnh nâng cao chất lượng sống cho các gia đình Việt Nam.\n Đội ngũ chăm sóc viên và điều dưỡng được đào tạo bài bản, làm việc 24/7, hỗ trợ người cao tuổi và người bệnh trong sinh hoạt, theo dõi sức khỏe và phối hợp cùng bác sĩ điều trị.',
        'location':
            'Dịch vụ tại nhà & bệnh viện tại TP.HCM, mạng lưới hợp tác nhiều bệnh viện tuyến đầu',
        'openTime':
            'Hoạt động linh hoạt 24/7, kể cả Lễ Tết (đặt lịch trước để sắp xếp chăm sóc viên)',
        'status': 1,
        'tag': null,
        'hasVoucher': 1,
        'voucherName': 'GIẢM 10%',
        'voucherSubName': 'Gói dịch vụ tại WeCare247',
        'voucherCode': 'CFY-CORP-2024',
        'voucherValue': 'Giảm 10% trên tổng hoá đơn',
        'applicableTo': 'Nhân viên Axon',
        'validUntil': 1784937600,
        'applicableLocation': 'Tất cả cơ sở',
        'order': 1,
        'bundleTagId': '76771441-2222-44e7-1909-08dedbdbb239',
        'media': [
          {
            'id': '21e703a4-60d8-452f-c851-08dee7df0a19',
            'bundleBenefitTypeId': 'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
            'imageId': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
            'url': null,
            'type': 3,
            'sortOrder': 0,
            'imageUrl': {
              'id': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
              'url': 'lib/res/drawables/wecare_image_title.jpg',
            },
          },
          {
            'id': '4025aa68-d124-4ba7-c84f-08dee7df0a19',
            'bundleBenefitTypeId': 'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
            'imageId': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
            'url': null,
            'type': 1,
            'sortOrder': 1,
            'imageUrl': {
              'id': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
              'url': 'lib/res/drawables/wecare_sub_image_1.jpg',
            },
          },
          {
            'id': '809c4faf-aff7-44f4-c850-08dee7df0a19',
            'bundleBenefitTypeId': 'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
            'imageId': '958c06ee-afad-4d91-f214-08dee7defb35',
            'url': null,
            'type': 1,
            'sortOrder': 2,
            'imageUrl': {
              'id': '958c06ee-afad-4d91-f214-08dee7defb35',
              'url': 'lib/res/drawables/wecare_sub_image_2.jpg',
            },
          },
        ],
      },
    });

    Navigator.pushNamed(
      context,
      NavigatorName.benefit_partner_intro,
      arguments: {'item': item},
    );
  }

  void _onTapViewAll(BuildContext context) {
    Navigator.pushNamed(
      context,
      NavigatorName.benefit_introduce_bundle,
    );
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
                onTap: () => _onTapBenefitAtHome(context),
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
                onTap: () => Navigator.pushNamed(
                  context,
                  NavigatorName.benefit_medicine_intro,
                ),
              ),
              _BenefitItem(
                icon: R.icons.ic_benefit_lab_testing,
                label: R.string.benefit_lab_testing.tr(),
                onTap: () => Navigator.pushNamed(
                  context,
                  NavigatorName.benefit_lab_test_intro,
                ),
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
