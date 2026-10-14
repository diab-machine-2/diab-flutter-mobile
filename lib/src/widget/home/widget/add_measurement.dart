import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/home/schema/home_schema.dart';

typedef OnItemCallback = void Function(HomeMeasurementIndex index);

/// "Nhập chỉ số" bottom sheet (Figma 22514:9282). Item icons are SVGs from
/// HomeBloc.getAllMeasurements.
class AddMeasurement extends StatelessWidget {
  const AddMeasurement({
    super.key,
    required this.measurements,
    required this.onItemTap,
  });

  final List<HomeMeasurementIndex> measurements;
  final OnItemCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      R.string.add_data.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: R.color.textDark,
                        fontSize: 16,
                        height: 24 / 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  InkResponse(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24, color: R.color.textDark),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: measurements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    _buildItem(measurements[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(HomeMeasurementIndex measurement) {
    return Material(
      color: R.color.color0xffE1FAF8,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onItemTap(measurement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SvgPicture.asset(measurement.icon, width: 32, height: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  measurement.title,
                  style: TextStyle(
                    color: R.color.accentColor,
                    fontSize: 15,
                    height: 24 / 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, size: 24, color: R.color.accentColor),
            ],
          ),
        ),
      ),
    );
  }
}
