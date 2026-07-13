import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitServiceRequestSuccessPage extends StatefulWidget {
  final BenefitServiceType type;

  const BenefitServiceRequestSuccessPage({Key? key, required this.type})
      : super(key: key);

  @override
  State<BenefitServiceRequestSuccessPage> createState() =>
      _BenefitServiceRequestSuccessPageState();
}

class _BenefitServiceRequestSuccessPageState
    extends State<BenefitServiceRequestSuccessPage> {
  bool get _isMedicine => widget.type == BenefitServiceType.medicine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  _buildSuccessIcon(),
                  const SizedBox(height: 20),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildStepsCard(),
                  const SizedBox(height: 20),
                  _buildContactCard(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
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
              ? R.string.benefit_medicine.tr()
              : R.string.benefit_lab_service_title.tr()),
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

  Widget _buildSuccessIcon() {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        color: Color(0xFFE5F7F5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          R.icons.ic_benefit_request_success,
          width: 56,
          height: 56,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      R.string.benefit_request_success_title.tr(),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: R.color.textDark,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: -0.26,
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: _isMedicine
                  ? R.string.benefit_request_desc_prefix_medicine.tr()
                  : R.string.benefit_request_desc_prefix_lab.tr(),
              style: TextStyle(
                color: R.color.primaryGreyColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
            TextSpan(
              text: R.string.benefit_request_desc_hour.tr(),
              style: TextStyle(
                color: R.color.primaryGreyColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
            TextSpan(
              text: R.string.benefit_request_desc_suffix.tr(),
              style: TextStyle(
                color: R.color.primaryGreyColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: -0.15,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStepsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepRow(
            isActive: true,
            stepNumber: 1,
            label: _isMedicine
                ? R.string.benefit_request_received_medicine.tr()
                : R.string.benefit_request_received_lab.tr(),
          ),
          const SizedBox(height: 12),
          _buildStepRow(
            isActive: false,
            stepNumber: 2,
            label: _isMedicine
                ? R.string.benefit_request_confirm_medicine.tr()
                : R.string.benefit_request_confirm_sample.tr(),
          ),
          const SizedBox(height: 12),
          _buildStepRow(
            isActive: false,
            stepNumber: 3,
            label: _isMedicine
                ? R.string.benefit_request_deliver.tr()
                : R.string.benefit_request_deliver_lab.tr(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required bool isActive,
    required int stepNumber,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: ShapeDecoration(
            color: isActive ? R.color.mainColor : R.color.color0xFFF2F4F5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(33554400),
            ),
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: R.color.color0xFF999999,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isActive ? R.color.textDark : R.color.color0xFF999999,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: -0.08,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return InkWell(
      onTap: () async {
        await HomeSupportFunctions.showModalAddData(
          context,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                color: R.color.color0xFFE5F7F5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(33554400)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.headset_mic_outlined,
                  size: 18,
                  color: R.color.mainColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                R.string.benefit_request_contact_support.tr(),
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: R.color.color0xFF999999,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: R.color.color0x14016961,
            blurRadius: 8,
            offset: const Offset(2, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true)
                  .pushNamedAndRemoveUntil(
                      NavigatorName.tabbar, (route) => false),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    colors: [
                      R.color.greenGradientTop02,
                      R.color.greenGradientBottom
                    ],
                    stops: const [0.01, 0.99],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.benefit_back_to_home.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            GapH(8),
          ],
        ),
      ),
    );
  }
}
