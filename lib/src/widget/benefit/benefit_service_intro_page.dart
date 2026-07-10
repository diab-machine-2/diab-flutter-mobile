import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/benefit/benefit_capture_image_page.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitServiceIntroPage extends StatelessWidget {
  final BenefitServiceType serviceType;

  const BenefitServiceIntroPage({Key? key, required this.serviceType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BenefitServiceRequestCubit(AppRepository()),
      child: _BenefitServiceIntroView(serviceType: serviceType),
    );
  }
}

class _BenefitServiceIntroView extends StatelessWidget {
  final BenefitServiceType serviceType;

  const _BenefitServiceIntroView({required this.serviceType});

  bool get _isMedicine => serviceType == BenefitServiceType.medicine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: R.color.backgroundColorNew,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildHeader(),
                    GapH(12),
                    _buildChoiceCard(context),
                    GapH(12),
                    _buildFeatureGrid(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
          stops: const [0.01, 0.99],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          (_isMedicine
                  ? R.string.benefit_medicine_service_title
                  : R.string.benefit_lab_service_title)
              .tr(),
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: R.color.white),
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F7F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                _isMedicine
                    ? R.icons.ic_benefit_medicine
                    : R.icons.ic_benefit_lab_testing,
                width: 44,
                height: 44,
              ),
            ),
          ),
          GapH(12),
          Text(
            (_isMedicine
                    ? R.string.benefit_medicine_service_title
                    : R.string.benefit_lab_service_title)
                .tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
          GapH(8),
          Text(
            (_isMedicine
                    ? R.string.benefit_medicine_service_desc
                    : R.string.benefit_lab_service_desc)
                .tr(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            (_isMedicine
                    ? R.string.benefit_have_prescription
                    : R.string.benefit_have_lab_order)
                .tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
          GapH(16),
          _buildOptionTile(
            context,
            isSelected: true,
            icon: _isMedicine
                ? R.icons.ic_benefit_medicine
                : R.icons.ic_benefit_lab_testing,
            title: (_isMedicine
                    ? R.string.benefit_yes_have_prescription
                    : R.string.benefit_yes_have_lab_order)
                .tr(),
            subtitle: (_isMedicine
                    ? R.string.benefit_yes_take_photo
                    : R.string.benefit_yes_lab_take_photo)
                .tr(),
            onTap: () => _navigateToCapture(context),
          ),
          GapH(12),
          _buildOptionTile(
            context,
            isSelected: false,
            icon: R.icons.ic_benefit_other,
            title: R.string.benefit_no_need_consult.tr(),
            subtitle: (_isMedicine
                    ? R.string.benefit_no_contact_diab
                    : R.string.benefit_no_contact_lab)
                .tr(),
            onTap: () => HomeSupportFunctions.showModalAddData(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required bool isSelected,
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? const Color(0xFFF0FBFA) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF008479)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC4FFF8)
                    : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(icon, width: 22, height: 22),
              ),
            ),
            GapW(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF008479)
                          : R.color.color0xff111515,
                    ),
                  ),
                  GapH(2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isSelected
                  ? const Color(0xFF008479)
                  : const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = _isMedicine
        ? [
            ('⚡', R.string.benefit_fast_delivery, R.string.benefit_fast_delivery_desc),
            ('✅', R.string.benefit_genuine_medicine, R.string.benefit_genuine_medicine_desc),
            ('💰', R.string.benefit_affordable_price, R.string.benefit_affordable_price_desc),
            ('🔒', R.string.benefit_info_security, R.string.benefit_info_security_desc),
          ]
        : [
            ('🔬', R.string.benefit_genuine_medicine, R.string.benefit_genuine_medicine_desc),
            ('⚡', R.string.benefit_fast_delivery, R.string.benefit_fast_delivery_desc),
            ('💰', R.string.benefit_affordable_price, R.string.benefit_affordable_price_desc),
            ('🔒', R.string.benefit_info_security, R.string.benefit_info_security_desc),
          ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 166 / 96,
      children: features
          .map((f) => _buildFeatureItem(f.$1, f.$2.tr(), f.$3.tr()))
          .toList(),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          GapH(4),
          Text(title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515)),
          GapH(2),
          Text(desc,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF666666))),
        ],
      ),
    );
  }

  void _navigateToCapture(BuildContext context) {
    final cubit = context.read<BenefitServiceRequestCubit>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: BenefitCaptureImagePage(serviceType: serviceType),
        ),
      ),
    );
  }
}
