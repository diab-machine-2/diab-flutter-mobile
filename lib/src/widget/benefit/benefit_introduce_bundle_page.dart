import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'benefit_introduce_bundle_cubit.dart';

class BenefitIntroduceBundlePage extends StatefulWidget {
  const BenefitIntroduceBundlePage({Key? key}) : super(key: key);

  @override
  _BenefitIntroduceBundlePageState createState() =>
      _BenefitIntroduceBundlePageState();
}

class _BenefitIntroduceBundlePageState
    extends State<BenefitIntroduceBundlePage> {
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
      body: BlocProvider.value(
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
            if (state is BenefitIntroduceBundleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BenefitIntroduceBundleSuccess) {
              final data = state.data;
              if (data == null) {
                return const Center(child: Text('No data'));
              }
              return _buildPage(context, data);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, MyBenefitData data) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildAppBar(context, partnerHotline: data.partnerHotline),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context, data),
                  const SizedBox(height: 16),
                  _buildProgressCard(context, data),
                  const SizedBox(height: 20),
                  ..._buildSections(context, data),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, data),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, {String? partnerHotline}) {
    return CustomAppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        R.string.benefit_detail_title.tr(),
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: R.color.color0xFF1F2937,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.color0xFF1F2937),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: SvgPicture.asset(
            R.icons.ic_telephone,
            width: 24,
            height: 24,
            fit: BoxFit.scaleDown,
          ),
          onPressed: () async {
            await HomeSupportFunctions.showModalAddData(
              context,
              hotline: partnerHotline,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, MyBenefitData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: ShapeDecoration(
        color: const Color(0xFF0FB4A5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 7,
                child: Text(
                  data.name ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: -0.43,
                  ),
                ),
              ),
              Flexible(
                flex: 3,
                child: GestureDetector(
                  onTap: () => Observable.instance.notifyObservers(
                    [],
                    notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB,
                    map: {'position': 0},
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: ShapeDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16777200),
                      ),
                    ),
                    child: Text(
                      R.string.benefit_active.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.50,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, MyBenefitData data) {
    final int total = data.totalItems ?? 0;
    final int used = data.usedItems ?? 0;
    final double percent = total > 0 ? used / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: R.color.color0xFFE5E7EB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.benefit_progress_title.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: R.color.color0xFF1F2937,
                ),
              ),
              Text(
                R.string.benefit_service_count.tr(args: ['$used', '$total']),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: R.color.color0xffF3F4F6,
              valueColor: AlwaysStoppedAnimation<Color>(
                R.color.accentColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF01645A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, MyBenefitData data) {
    final sections = data.sections ?? [];
    final List<Widget> widgets = [];

    for (final section in sections) {
      final items = section.items ?? [];
      if (items.isEmpty) continue;

      // Section header
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            section.tagName ?? '',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: R.color.color0xFF1F2937,
            ),
          ),
        ),
      );

      // Section card with items
      widgets.add(const SizedBox(height: 10));
      widgets.add(_buildSectionCard(context, items));
      widgets.add(const SizedBox(height: 24));
    }

    return widgets;
  }

  Widget _buildSectionCard(BuildContext context, List<MyBenefitItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: R.color.color0xFFE5E7EB),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          return _buildSectionItem(
            context,
            items[index],
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildSectionItem(
    BuildContext context,
    MyBenefitItem item, {
    bool isLast = false,
  }) {
    final type = item.bundleItemType;
    final bool hasDiscount = (item.discountValue ?? 0) > 0 &&
        type != BenefitBundleItemType.booking &&
        type != BenefitBundleItemType.partnerIntro &&
        type != BenefitBundleItemType.report;
    final bool isUnlimited = item.isUnlimitedBenefit;
    final int quantity = item.quantity ?? 0;
    final int used = item.quantityUsed ?? 0;
    final int remaining = quantity - used;
    final bool isUsed = used > 0;

    // Show progress bar for items with quantity tracking or unlimited
    final bool showProgress = !hasDiscount &&
        type != BenefitBundleItemType.report &&
        (quantity > 0 || isUnlimited);
    final double progressValue = isUnlimited
        ? 1.0
        : (quantity > 0 ? (used / quantity).clamp(0.0, 1.0) : 0.0);

    // Secondary text
    String? secondaryText;
    if (hasDiscount) {
      secondaryText = null;
    } else if (isUnlimited) {
      secondaryText = R.string.benefit_unlimited.tr();
    } else if (remaining > 0 && quantity > 0) {
      secondaryText = R.string.benefit_remaining_count.tr(args: ['$remaining']);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _onItemTap(context, item, type),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemIcon(type),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name + right element
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: R.color.color0xFF1F2937,
                              ),
                            ),
                          ),
                          if (hasDiscount)
                            _buildDiscountBadge(item.discountValue ?? 0),
                          if (!hasDiscount)
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: Color(0xFF6B7280),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Row 2: Status + secondary text
                      Row(
                        children: [
                          Text(
                            isUsed
                                ? R.string.used.tr()
                                : R.string.not_used.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isUsed
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFF01645A),
                            ),
                          ),
                          if (secondaryText != null) ...[
                            const Spacer(),
                            Text(
                              secondaryText,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Progress bar
                      if (showProgress) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 6,
                            backgroundColor: R.color.color0xffF3F4F6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              R.color.accentColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: R.color.color0xFFE5E7EB,
          ),
      ],
    );
  }

  Widget _buildItemIcon(BenefitBundleItemType type) {
    String iconPath;
    switch (type) {
      case BenefitBundleItemType.booking:
        iconPath = R.icons.ic_benefit_item_dat_lich;
        break;
      case BenefitBundleItemType.partnerIntro:
        iconPath = R.icons.ic_benefit_item_gioi_thieu;
        break;
      case BenefitBundleItemType.report:
        iconPath = R.icons.ic_benefit_item_bao_cao;
        break;
      case BenefitBundleItemType.medicine:
      case BenefitBundleItemType.medicinePurchase:
        iconPath = R.icons.ic_benefit_item_thuoc;
        break;
      case BenefitBundleItemType.dsp:
        iconPath = R.icons.ic_benefit_item_dsp;
        break;
      case BenefitBundleItemType.labTest:
        iconPath = R.icons.ic_benefit_item_dat_xet_nghiem;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: R.color.color0xFFF0FDF4,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(
        iconPath,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildDiscountBadge(int discountValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: R.color.color0xffF3F4F6,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        R.string.benefit_discount_badge.tr(args: ['$discountValue']),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, MyBenefitData data) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: R.color.color0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.schedule, size: 16, color: R.color.color0xFF6B7280),
              const SizedBox(width: 6),
              Text(
                R.string.benefit_remaining_days.tr(
                  args: ['${data.remainingDays ?? 0}'],
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to booking screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: R.color.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                R.string.benefit_booking_button.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTap(
    BuildContext context,
    MyBenefitItem item,
    BenefitBundleItemType type,
  ) {
    switch (type) {
      case BenefitBundleItemType.booking:
        // TODO: Handle booking item tap
        break;

      case BenefitBundleItemType.partnerIntro:
        // TODO: Handle partner intro item tap
        break;

      case BenefitBundleItemType.report:
        Navigator.pushNamed(context, NavigatorName.view_test_result);
        break;

      case BenefitBundleItemType.medicine:
        // Temporarily no action for medicine
        break;

      case BenefitBundleItemType.dsp:
        // Navigate to program tab via existing observer notification
        Observable.instance.notifyObservers(
          [],
          notifyName: Const.NAVIGATE_TO_MY_PLAN_TAB,
          map: {'position': 0},
        );
        break;

      case BenefitBundleItemType.medicinePurchase:
        Navigator.pushNamed(
          context,
          NavigatorName.benefit_medicine_intro,
        );
        break;

      case BenefitBundleItemType.labTest:
        Navigator.pushNamed(
          context,
          NavigatorName.benefit_lab_test_intro,
        );
        break;
    }
  }
}
