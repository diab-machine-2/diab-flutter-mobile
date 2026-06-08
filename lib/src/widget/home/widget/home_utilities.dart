import 'dart:math';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';

import '../schema/home_schema.dart';

class HomeUtilities extends StatelessWidget {
  const HomeUtilities({
    super.key,
    required this.utilities,
    required this.onTap,
  });

  final List<HomeUtilityData> utilities;
  final Function(HomeUtilityData) onTap;

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = max(1.0, MediaQuery.of(context).textScaleFactor);
    final isLargeFont = textScaleFactor > 1.25;

    List<HomeUtilityData> renderingUtilities = utilities;
    if (isLargeFont && utilities.length > 5) {
      renderingUtilities = utilities.take(5).toList()
        ..add(utilities[utilities.length - 1]);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.utilities.tr(),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: R.color.color0xff27272A,
                ),
              ),
              // ! Later
              const SizedBox(),
            ],
          ),

          const SizedBox(height: 16.0),

          // use two rows to keep fixed height
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: renderingUtilities
                .getRange(0, renderingUtilities.length ~/ 2)
                .map((utility) => Expanded(child: _buildActivityItem(utility, context)))
                .toList(),
          ),
          const SizedBox(height: 16.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: renderingUtilities
                .getRange(
                    renderingUtilities.length ~/ 2, renderingUtilities.length)
                .map((utility) => Expanded(child: _buildActivityItem(utility, context)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(HomeUtilityData utility, BuildContext context) {
    return InkWell(
      onTap: () => onTap(utility),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            utility.icon,
            width: 28.0,
            height: 28.0,
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            alignment: Alignment.center,
            width: double.infinity,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context)
                      .textScaler
                      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3)),
              child: Text(
                utility.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 15.0,
                  color: R.color.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
