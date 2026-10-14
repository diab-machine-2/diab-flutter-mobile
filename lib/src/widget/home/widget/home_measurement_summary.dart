import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/hba1c_navigation_helper.dart';
import 'package:medical/src/widget/home/home_view_flags.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

typedef MeasurementCallback = void Function(
    String? routeName, Map<String, dynamic>? args, String title);

// Special callback for HbA1C that receives context for smart navigation
typedef HbA1cCallback = void Function(
    BuildContext context, String? routeName, dynamic args, String title);

/// Home "Chỉ số sức khỏe" card (Figma KPI card 22514:6099 / Empty B2
/// 22514:8615): the KPI variant when [HomeViewFlags.hasKpi], otherwise the
/// "Theo dõi chỉ số mỗi ngày" empty card.
class MeasurementSummary extends StatelessWidget {
  const MeasurementSummary({
    super.key,
    required this.inlineMeasurements,
    required this.measurements,
    required this.flags,
    required this.onAddMeasurement,
    required this.onConnectDevice,
    required this.onHealthProfile,
    required this.onMeasurement,
    this.onHbA1cTap,
  });

  final List<HomeMeasurementInlineData> inlineMeasurements;
  final List<HomeMeasurementData> measurements;
  final HomeViewFlags flags;

  final VoidCallback onAddMeasurement;
  final VoidCallback onConnectDevice;
  final VoidCallback onHealthProfile;
  final MeasurementCallback onMeasurement;

  // Special callback for HbA1C that receives context for smart navigation
  final HbA1cCallback? onHbA1cTap;

  static const String emptyValue = '---';

  // Icons follow HomeBloc._castMeasurements order: glucose, blood pressure,
  // exercise, nutrition.
  static List<String> get _metricIcons => [
        R.icons.ic_nv_duong_huyet,
        R.icons.ic_nv_huyet_ap,
        R.icons.ic_nv_van_dong,
        R.icons.ic_nv_dinh_duong,
      ];

  @override
  Widget build(BuildContext context) {
    return flags.hasKpi ? _buildKpiCard(context) : _buildEmptyCard();
  }

  // ---------------------------------------------------------------- KPI card

  Widget _buildKpiCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.homeCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Scale down rather than overflow at large text sizes.
              children: inlineMeasurements
                  .map((data) => Flexible(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _buildKeyStat(context, data))))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < measurements.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                      child: _buildMetric(context, measurements[i],
                          i < _metricIcons.length ? _metricIcons[i] : null)),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
            child: Row(
              children: [
                if (flags.hasRecord) ...[
                  _buildHealthProfileButton(),
                  const SizedBox(width: 8),
                ],
                Expanded(child: _buildAddMeasurementButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyStat(BuildContext context, HomeMeasurementInlineData data) {
    final hasValue = data.value.isNotEmpty && data.value != '--';
    return InkWell(
      onTap: () =>
          _onTap(context, data.title ?? '', data.navigatorName, data.args),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (data.icon != null)
            SvgPicture.asset(R.icons.ic_nv_can_nang, width: 16, height: 16)
          else
            Text(
              data.title ?? '',
              style: TextStyle(
                color: R.color.homeTitleText,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            hasValue ? data.value : emptyValue,
            style: TextStyle(
              color: hasValue ? Color(data.color) : R.color.color0xff111515,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(data.unit, style: _captionStyle),
        ],
      ),
    );
  }

  Widget _buildMetric(
      BuildContext context, HomeMeasurementData data, String? icon) {
    final value1 = data.value1;
    final value2 = data.value2;
    final hasValue1 = value1 != null && value1.isNotEmpty && value1 != '--';
    final hasValue2 = hasValue1 &&
        value2 != null &&
        value2.isNotEmpty &&
        value2 != '--' &&
        data.value2Color != null;
    final valueStyle = TextStyle(
      fontFamily: R.font.viga,
      fontSize: 15,
      height: 1.46,
      color: R.color.color0xff111515,
    );

    final Widget value = !hasValue1
        ? Text(emptyValue, style: valueStyle)
        : Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: value1,
                  style: TextStyle(color: Color(data.value1Color))),
              if (hasValue2) ...[
                const TextSpan(text: '/'),
                TextSpan(
                    text: value2,
                    style: TextStyle(color: Color(data.value2Color!))),
              ],
            ]),
            style: valueStyle,
            maxLines: 1,
          );

    return InkWell(
      onTap: () => _onTap(context, data.title, data.navigatorName, data.args),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: R.color.homeMetricCircleBg,
              shape: BoxShape.circle,
              border: Border.all(color: R.color.homeMetricCircleBorder),
            ),
            child: icon == null
                ? Image.asset(data.icon, width: 24, height: 24)
                : SvgPicture.asset(icon, width: 24, height: 24),
          ),
          const SizedBox(height: 6),
          FittedBox(fit: BoxFit.scaleDown, child: value),
          Text(
            data.unit,
            style: _captionStyle.copyWith(fontFamily: R.font.viga),
            maxLines: 1,
          ),
          Text(
            data.title,
            style: _captionStyle.copyWith(fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthProfileButton() {
    return InkWell(
      onTap: onHealthProfile,
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 105,
            height: 44,
            decoration: BoxDecoration(
              color: R.color.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: R.color.color0xff95682E, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(R.icons.ic_home_file_text,
                    width: 18, height: 18),
                const SizedBox(width: 7),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      R.string.ho_so.tr(),
                      maxLines: 1,
                      style: _buttonTextStyle(R.color.color0xff95682E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (flags.hasUnviewedRecord)
            Positioned(
              top: -1.4,
              right: -1.4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: R.color.homeAlertRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- Empty card

  Widget _buildEmptyCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: R.color.accentColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: R.color.homeKpiEmptyShadow,
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      R.string.home_kpi_empty_eyebrow.tr(),
                      style: TextStyle(
                        color: R.color.color0xff95682E,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      R.string.home_kpi_empty_title.tr(),
                      style: TextStyle(
                        color: R.color.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      R.string.home_kpi_empty_desc.tr(),
                      style: TextStyle(
                        color: R.color.homeCaptionText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildEmptyIconGrid(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildConnectDeviceButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildAddMeasurementButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyIconGrid() {
    final cells = [
      (R.icons.ic_nv_duong_huyet, R.string.duong_huyet.tr()),
      (R.icons.ic_nv_huyet_ap, R.string.huyet_ap.tr()),
      (R.icons.ic_nv_van_dong, R.string.van_dong.tr()),
      (R.icons.ic_nv_dinh_duong, R.string.dinh_duong.tr()),
    ];
    Widget cell((String, String) item) => SizedBox(
          width: 56,
          child: Column(
            children: [
              Opacity(
                opacity: 0.5,
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: R.color.homeMetricCircleBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: R.color.homeMetricCircleBorder),
                  ),
                  child: SvgPicture.asset(item.$1, width: 16, height: 16),
                ),
              ),
              const SizedBox(height: 2),
              // Long labels (English, large text) shrink instead of
              // overlapping the neighbouring cell.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.$2,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: R.color.homeCaptionText,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
    return Column(
      children: [
        Row(children: [
          cell(cells[0]),
          const SizedBox(width: 6),
          cell(cells[1])
        ]),
        const SizedBox(height: 4),
        Row(children: [
          cell(cells[2]),
          const SizedBox(width: 6),
          cell(cells[3])
        ]),
      ],
    );
  }

  Widget _buildConnectDeviceButton() {
    return InkWell(
      onTap: onConnectDevice,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: R.color.homeAccentTeal, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(R.icons.ic_ti_ket_noi_thiet_bi,
                width: 20, height: 20),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  R.string.connect_device_home.tr(),
                  maxLines: 1,
                  style: _buttonTextStyle(R.color.homeAccentTeal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ shared

  Widget _buildAddMeasurementButton() {
    return InkWell(
      onTap: onAddMeasurement,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: R.color.color0xff95682E,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(R.icons.ic_home_plus, width: 17, height: 17),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  R.string.add_data.tr(),
                  maxLines: 1,
                  style: _buttonTextStyle(R.color.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _captionStyle => TextStyle(
        color: R.color.homeCaptionText,
        fontSize: 12,
        height: 1.5,
        letterSpacing: 0.2,
      );

  TextStyle _buttonTextStyle(Color color) => TextStyle(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 15,
        height: 1.46,
        letterSpacing: 0.4,
      );

  void _onTap(BuildContext context, String title, String? routeName,
      Map<String, dynamic>? args) {
    if (title.toLowerCase() == 'hba1c' && onHbA1cTap != null) {
      onHbA1cTap!(context, routeName, args, title);
      return;
    }
    onMeasurement(routeName, args, title);
  }

  // Static helper method to create HbA1C callback for smart navigation
  static HbA1cCallback createHbA1cCallback(BuildContext context) {
    return (BuildContext ctx, String? routeName, dynamic args,
        String title) async {
      try {
        // Small delay to ensure data is updated after any recent changes
        await Future.delayed(Duration(milliseconds: 300));

        // Use the unified HbA1cNavigationHelper for consistent behavior
        // This handles first-time users, data availability, and proper navigation
        await HbA1cNavigationHelper.navigateToHbA1C(ctx);
      } catch (e) {
        // Fallback to original navigation if there's any error
        Navigator.pushNamed(ctx, routeName ?? NavigatorName.detail_hba1c,
            arguments: args);
      }
    };
  }
}
