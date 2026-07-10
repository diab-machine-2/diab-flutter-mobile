import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitServiceRequestSuccessPage extends StatelessWidget {
  final BenefitServiceType type;

  const BenefitServiceRequestSuccessPage({Key? key, required this.type})
      : super(key: key);

  bool get _isMedicine => type == BenefitServiceType.medicine;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE5F7F5),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.check_circle_outline,
                              size: 56, color: Color(0xFF008479)),
                        ),
                      ),
                      GapH(20),
                      Text(
                        R.string.benefit_request_success_title.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: R.color.color0xff111515,
                        ),
                      ),
                      GapH(12),
                      Text(
                        (_isMedicine
                                ? R.string.benefit_request_success_medicine_desc
                                : R.string.benefit_request_success_lab_desc)
                            .tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF636A6B),
                        ),
                      ),
                      GapH(32),
                      _buildStep(
                        context,
                        '1',
                        (_isMedicine
                                ? R.string.benefit_request_received_medicine
                                : R.string.benefit_request_received_lab)
                            .tr(),
                      ),
                      if (!_isMedicine) ...[
                        GapH(12),
                        _buildStep(
                          context,
                          '2',
                          R.string.benefit_request_confirm_sample.tr(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                        NavigatorName.tabbar, (r) => false),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientMid,
                      R.color.greenGradientBottom,
                    ]),
                  ),
                  child: Center(
                    child: Text(
                      R.string.benefit_back_to_home.tr(),
                      style: TextStyle(
                        color: R.color.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String number, String label) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: R.color.greenGradientBottom,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        GapW(12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: R.color.color0xff111515,
            ),
          ),
        ),
      ],
    );
  }
}
