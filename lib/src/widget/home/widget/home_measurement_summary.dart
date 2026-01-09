import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/hba1c_navigation_helper.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

typedef MeasurementCallback = void Function(
    String? routeName, Map<String, dynamic>? args, String title);

// Special callback for HbA1C that receives context for smart navigation
typedef HbA1cCallback = void Function(
    BuildContext context, String? routeName, dynamic args, String title);

class MeasurementSummary extends StatelessWidget {
  const MeasurementSummary({
    super.key,
    required this.inlineMeasurements,
    required this.measurements,
    required this.onAddMeasurement,
    required this.onHealthProfile,
    required this.onMeasurement,
    this.onHbA1cTap,
    this.loading = false,
  });

  final bool loading;

  final List<HomeMeasurementInlineData> inlineMeasurements;
  final List<HomeMeasurementData> measurements;

  final VoidCallback onAddMeasurement;
  final VoidCallback onHealthProfile;
  final MeasurementCallback onMeasurement;

  // Special callback for HbA1C that receives context for smart navigation
  final HbA1cCallback? onHbA1cTap;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = max(1.0, MediaQuery.of(context).textScaleFactor);
    return Stack(
      fit: StackFit.loose,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Inline measurements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: inlineMeasurements
                      .map((e) => _buildInlineMeasurementWidget(e))
                      .toList(),
                ),

                const SizedBox(height: 20.0),

                // Measurements
                SizedBox(
                  height: 88.0 * textScaleFactor,
                  child: ListView.separated(
                    itemBuilder: (_, index) => _buildMeasurementWidget(
                        measurements[index], textScaleFactor),
                    separatorBuilder: (_, index) => const SizedBox(width: 8.0),
                    itemCount: measurements.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),

                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Health Profile Button
              // _buildHealthProfileButton(),

              // Add measurement
              _buildAddMeasurementButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInlineMeasurementWidget(HomeMeasurementInlineData data) {
    return InkWell(
      onTap: () {
        // Special handling for HbA1C based on data availability
        if (data.title?.toLowerCase() == "hba1c" && onHbA1cTap != null) {
          // Use WidgetsBinding to access context after frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = _getCurrentContext();
            if (context != null) {
              onHbA1cTap!(
                  context, data.navigatorName, data.args, data.title ?? "");
            } else {
              onMeasurement(data.navigatorName, data.args, data.title ?? "");
            }
          });
        } else {
          onMeasurement(data.navigatorName, data.args, data.title ?? "");
        }
      },
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

  Widget _buildMeasurementWidget(
      HomeMeasurementData data, double textScaleFactor) {
    Widget valueWidget;
    final withUnit = data.unit.isNotEmpty;
    double valueFontSize = withUnit ? 12.0 : 14.0;
    double height = (valueFontSize + 4.0) / valueFontSize;

    // Determine the display value
    var value1 = data.value1 ?? "--";
    var value2 = data.value2;

    // Debug log for blood pressure
    if (data.title.toLowerCase() == "huyết áp") {
      print('🔍 Blood Pressure Display Check:');
      print('  value1: $value1');
      print('  value2: $value2');
      print('  value1Color: ${data.value1Color}');
      print('  value2Color: ${data.value2Color}');
    }

    // Special handling for Blood Pressure: Force empty state if value2 is null or value2Color is noValueColor
    // Backend may return default values (120/90) even when there's no real data
    // The key indicators are:
    // 1. value2Color is null (when haveBloodPressure is false)
    // 2. value1Color or value2Color equals _noValueColor (0xFF172823) - indicates no real data
    if (data.title.toLowerCase() == "huyết áp") {
      const int noValueColor = 0xFF172823; // _noValueColor from home_bloc.dart

      // If value2Color is null, treat as no data
      if (data.value2Color == null) {
        value1 = "--";
        value2 = null;
      }
      // If value2Color equals noValueColor, treat as no data (backend returned default values)
      else if (data.value2Color == noValueColor) {
        value1 = "--";
        value2 = null;
      }
      // If value1Color equals noValueColor, treat as no data
      else if (data.value1Color == noValueColor) {
        value1 = "--";
        value2 = null;
      }
      // If value2 is null, treat as no data
      if (value2 == null) {
        value1 = "--";
        value2 = null;
      }
      // Also check if value1 is "--" - this is the explicit empty state marker
      if (value1 == "--" || value1.isEmpty) {
        value1 = "--";
        value2 = null;
      }
    }

    // Check if we should display as "value1 / value2" format
    // Only show dual format if:
    // 1. value2 is not null and not empty
    // 2. value1 is not "--" (empty state)
    // 3. value2 is not "--" (empty state)
    // 4. value2Color is not null (indicates valid data)
    final shouldShowDualFormat = value2 != null &&
        value2.isNotEmpty &&
        value2 != "--" &&
        value1 != "--" &&
        value1.isNotEmpty &&
        data.value2Color !=
            null; // Additional check: value2Color should exist for valid data

    if (shouldShowDualFormat) {
      // Display as "value1 / value2" with different colors
      valueWidget = RichText(
        textScaleFactor: textScaleFactor,
        text: TextSpan(
          children: [
            TextSpan(
              text: value1,
              style: TextStyle(color: Color(data.value1Color)),
            ),
            TextSpan(
              text: " / ",
              style: TextStyle(color: R.color.color0xff666666),
            ),
            TextSpan(
              text: value2,
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
      // Display single value (either "--" or value1)
      // If value1 is "--", ensure we display it as empty state
      final displayValue = (value1 == "--" || value1.isEmpty) ? "--" : value1;
      valueWidget = Text(
        displayValue,
        style: TextStyle(
            color: Color(data.value1Color),
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
            height: height),
      );
    }
    return InkWell(
      onTap: () {
        // Special handling for HbA1C based on data availability
        if (data.title.toLowerCase() == "hba1c" && onHbA1cTap != null) {
          // Use WidgetsBinding to access context after frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = _getCurrentContext();
            if (context != null) {
              onHbA1cTap!(context, data.navigatorName, data.args, data.title);
            } else {
              onMeasurement(data.navigatorName, data.args, data.title);
            }
          });
        } else {
          onMeasurement(data.navigatorName, data.args, data.title);
        }
      },
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

  // Widget _buildHealthProfileButton() {
  //   return InkWell(
  //     onTap: onHealthProfile,
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.end,
  //       children: [
  //         Image.asset(
  //           R.drawable.ic_home_health_profile,
  //           width: 20.0,
  //           height: 20.0,
  //         ),
  //         const SizedBox(width: 6.0),
  //         Text(
  //           "Hồ sơ sức khoẻ",
  //           style: TextStyle(
  //             color: R.color.greenGradientBottom,
  //             fontWeight: FontWeight.bold,
  //             fontSize: 14.0,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildAddMeasurementButton() {
    return InkWell(
      onTap: onAddMeasurement,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: R.color.burntSienna,
          border: Border.all(
            width: 8,
            color: Color(0xffD8D8D8),
            style: BorderStyle.solid,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get current context using WidgetsBinding
  BuildContext? _getCurrentContext() {
    try {
      // Try to get the current context from the navigator
      final context = WidgetsBinding.instance.focusManager.rootScope?.context;
      return context;
    } catch (e) {
      // If that fails, try to get it from the render tree
      try {
        final element = WidgetsBinding.instance.renderViewElement;
        if (element != null) {
          return element;
        }
      } catch (e2) {
        // Ignore errors
      }
    }
    return null;
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
