import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

typedef MeasurementCallback = void Function(String? routeName, dynamic args);

class MeasurementSummary extends StatelessWidget {
  const MeasurementSummary({
    super.key,
    required this.inlineMeasurements,
    required this.measurements,
    required this.onAddMeasurement,
    required this.onHealthProfile,
    required this.onMeasurement,
  });

  final List<HomeMeasurementInlineData> inlineMeasurements;
  final List<HomeMeasurementData> measurements;

  final VoidCallback onAddMeasurement;
  final VoidCallback onHealthProfile;
  final MeasurementCallback onMeasurement;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = max(1.0, MediaQuery.of(context).textScaleFactor);
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Inline measurements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: inlineMeasurements.map((e) => _buildInlineMeasurementWidget(e)).toList(),
          ),

          const SizedBox(height: 20.0),

          // Measurements
          SizedBox(
            height: 88.0 * textScaleFactor,
            child: ListView.separated(
              itemBuilder: (_, index) =>
                  _buildMeasurementWidget(measurements[index], textScaleFactor),
              separatorBuilder: (_, index) => const SizedBox(width: 8.0),
              itemCount: measurements.length,
              scrollDirection: Axis.horizontal,
            ),
          ),

          const SizedBox(height: 20.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHealthProfileButton(),
              _buildAddMeasurementButton(),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInlineMeasurementWidget(HomeMeasurementInlineData data) {
    return InkWell(
      onTap: () => onMeasurement(data.navigatorName, data.args),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (data.icon != null)
            Image.asset(
              data.icon!,
              width: 16.0,
              height: 16.0,
              color: Color(data.titleColor),
            ),
          if (data.icon == null && data.title != null)
            Text(
              data.title!,
              style: TextStyle(
                color: Color(data.titleColor),
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          const SizedBox(width: 4.0),
          Text(
            data.value,
            style: TextStyle(
              color: Color(data.color),
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(width: 2.0),
          Text(
            "(${data.unit})",
            style: TextStyle(
              color: R.color.color0xff666666,
              fontWeight: FontWeight.normal,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementWidget(HomeMeasurementData data, double textScaleFactor) {
    Widget valueWidget;
    final withUnit = data.unit.isNotEmpty;
    double valueFontSize = withUnit ? 12.0 : 16.0;
    double height = (valueFontSize + 4.0) / valueFontSize;
    if (data.value2 != null && data.value2!.isNotEmpty) {
      // build textspan with different style data.color
      valueWidget = RichText(
        textScaleFactor: textScaleFactor,
        text: TextSpan(
          children: [
            TextSpan(
              text: data.value1,
              style: TextStyle(color: Color(data.value1Color)),
            ),
            TextSpan(
              text: " / ",
              style: TextStyle(color: R.color.color0xff666666),
            ),
            TextSpan(
              text: data.value2,
              style: TextStyle(color: Color(data.value2Color!)),
            ),
          ],
          style: TextStyle(
            color: Color(data.value1Color),
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
            height: height,
          ),
        ),
      );
    } else {
      valueWidget = Text(
        data.value1 ?? "--",
        style: TextStyle(
            color: Color(data.value1Color),
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
            height: height),
      );
    }
    return InkWell(
      onTap: () => onMeasurement(data.navigatorName, data.args),
      child: Container(
        width: 88.0 * textScaleFactor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              data.icon,
              width: 32.0,
              height: 32.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              data.title,
              style: TextStyle(
                color: R.color.color0xff666666,
                fontWeight: FontWeight.w600,
                fontSize: 12.0,
                height: 16.0 / 12.0,
              ),
            ),
            valueWidget,
            if (withUnit)
              Text(
                "(${data.unit})",
                style: TextStyle(
                  color: R.color.color0xff666666,
                  fontWeight: FontWeight.normal,
                  fontSize: 12.0,
                  height: 16.0 / 12.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthProfileButton() {
    return InkWell(
      onTap: onHealthProfile,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // TODO: Replace with icon
          Image.asset(
            R.drawable.ic_home_health_profile,
            width: 20.0,
            height: 20.0,
          ),
          const SizedBox(width: 6.0),
          Text(
            "Hồ sơ sức khoẻ",
            style: TextStyle(
              color: R.color.greenGradientBottom,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMeasurementButton() {
    return InkWell(
      onTap: onAddMeasurement,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: R.color.greenGradientBottom,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              R.drawable.ic_home_plus,
              width: 16.0,
              height: 16.0,
            ),
            Text(
              "Thêm chỉ số",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.0,
                height: 16.0 / 13.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
