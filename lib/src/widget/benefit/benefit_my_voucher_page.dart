import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'benefit_introduce_bundle_cubit.dart';

/// Lists every [BenefitBundleItemType.partnerIntro] item across all
/// [MyBenefitData.sections] as a voucher card (title, value + expiry date).
class BenefitMyVoucherPage extends StatefulWidget {
  const BenefitMyVoucherPage({Key? key}) : super(key: key);

  @override
  State<BenefitMyVoucherPage> createState() => _BenefitMyVoucherPageState();
}

class _BenefitMyVoucherPageState extends State<BenefitMyVoucherPage> {
  late final BenefitIntroduceBundleCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BenefitIntroduceBundleCubit(AppRepository());
    _cubit.loadMyBenefit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: BlocProvider.value(
              value: _cubit,
              child: BlocConsumer<BenefitIntroduceBundleCubit,
                  BenefitIntroduceBundleState>(
                listener: (context, state) {
                  if (state is BenefitIntroduceBundleFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is BenefitIntroduceBundleSuccess) {
                    final items = _partnerIntroItems(state.data);
                    if (items.isEmpty) {
                      return Center(child: Text(R.string.no_data.tr()));
                    }
                    return _buildList(context, items);
                  }
                  if (state is BenefitIntroduceBundleFailure) {
                    return Center(child: Text(R.string.no_data.tr()));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A partnerIntro item only carries an actual voucher when
  /// [BenefitType.hasVoucher] is set — otherwise the intro page falls back
  /// to a promo image/video with no voucher value or expiry to show here.
  List<MyBenefitItem> _partnerIntroItems(MyBenefitData? data) {
    final sections = data?.sections ?? [];
    final now = DateTime.now();
    return sections
        .expand((section) => section.visibleItems)
        .where((item) =>
            item.bundleItemType == BenefitBundleItemType.partnerIntro)
        .where((item) {
          final validUntil = item.benefitType?.validUntil;
          if (validUntil == null) return true;
          return DateTime.fromMillisecondsSinceEpoch(validUntil * 1000)
              .isAfter(now);
        })
        .toList();
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: R.color.color0xFFE5E7EB),
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          R.string.benefit_my_voucher_title.tr(),
          style: TextStyle(
            color: R.color.color0xFF1F2937,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.43,
          ),
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.color0xFF1F2937),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<MyBenefitItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) =>
          _buildVoucherCard(context, items[index]),
    );
  }

  Widget _buildVoucherCard(BuildContext context, MyBenefitItem item) {
    final benefitType = item.benefitType;

    String validUntilStr = '';
    if (benefitType?.validUntil != null) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
          benefitType!.validUntil! * 1000);
      validUntilStr = DateFormat('dd/MM/yyyy').format(dt);
    }

    final voucherValue = benefitType?.voucherValue ?? '';
    final String? subtitle = (voucherValue.isEmpty && validUntilStr.isEmpty)
        ? null
        : R.string.benefit_voucher_subtext.tr(
            args: [voucherValue, validUntilStr],
          );

    final isActive = benefitType?.status == 1;

    return DottedBorder(
      color: R.color.greenGradientTop02,
      strokeWidth: 2,
      dashPattern: const [5, 2],
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            NavigatorName.benefit_partner_intro,
            arguments: {'item': item},
          ),
          child: Container(
            color: Colors.white,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 2, color: R.color.accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  benefitType?.title ?? '',
                                  style: TextStyle(
                                    color: R.color.color0xFF1F2937,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    height: 1.40,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      color: R.color.color0xFF6B7280,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.50,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: R.color.accentColor,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              isActive
                                  ? R.string.benefit_active.tr()
                                  : R.string.benefit_inactive.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: R.color.color0xFF6B7280,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
