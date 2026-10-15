import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/shimmer_box.dart';
import 'package:medical/src/widgets/specialty_grid.dart';

enum SpecialtySelectStatus { loading, error, ready }

/// "Chọn nhu cầu khám" screen (Figma 22514:9046): gradient header and the
/// [SpecialtyGrid], with loading / empty / error states. Shared by the
/// benefit flow and the Home daily-care booking flows, which keep their own
/// data and navigation.
class SpecialtySelectView extends StatelessWidget {
  const SpecialtySelectView({
    super.key,
    required this.status,
    required this.items,
    required this.onBack,
    this.actions,
    this.onRetry,
  });

  final SpecialtySelectStatus status;
  final List<SpecialtyGridItem> items;
  final VoidCallback onBack;

  /// Header actions, e.g. the daily-care "Lịch hẹn" button.
  final List<Widget>? actions;

  /// Shown as a retry button in the error state.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: R.color.backgroundColorNew,
      child: Column(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.greenGradientTop02,
                  R.color.greenGradientBottom
                ],
                stops: const [0.01, 0.99],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: CustomAppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                R.string.chon_nhu_cau_kham_title.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: R.color.white,
                ),
              ),
              actions: actions,
              leadingIcon: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: onBack,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (status) {
      case SpecialtySelectStatus.loading:
        return const _SpecialtyGridSkeleton();
      case SpecialtySelectStatus.error:
        return _Message(onRetry: onRetry);
      case SpecialtySelectStatus.ready:
        if (items.isEmpty) return const _Message();
        return SingleChildScrollView(child: SpecialtyGrid(items: items));
    }
  }
}

/// "Lịch hẹn" header button of the Home daily-care booking flows.
class SpecialtyHistoryButton extends StatelessWidget {
  const SpecialtyHistoryButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 33,
        // Grows with the label (English, larger text) instead of overflowing.
        constraints: const BoxConstraints(minWidth: 90),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        margin: const EdgeInsets.fromLTRB(0, 12, 16, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: R.color.color0xffECFFFD,
          border: Border.all(color: R.color.color0xffA4E3DD),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              R.icons.ic_clock,
              width: 16,
              height: 16,
              color: R.color.color0xff239A90,
              fit: BoxFit.scaleDown,
            ),
            const SizedBox(width: 4),
            Text(
              R.string.consulting_history.tr(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: R.color.color0xff239A90,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              R.string.empty_clinic_content.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: R.color.color0xff111515),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  R.string.retry.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: R.color.color0xff239A90,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpecialtyGridSkeleton extends StatefulWidget {
  const _SpecialtyGridSkeleton();

  @override
  State<_SpecialtyGridSkeleton> createState() => _SpecialtyGridSkeletonState();
}

class _SpecialtyGridSkeletonState extends State<_SpecialtyGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const columns = SpecialtyGrid.columns;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Roughly one icon + 2-line label of SpecialtyGrid.
        childAspectRatio: 106 / 134,
      ),
      itemCount: columns * 3,
      itemBuilder: (context, index) => ShimmerBox(
        animation: _shimmer,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
