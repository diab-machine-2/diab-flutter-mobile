import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

import '../schema/measurement_schema.dart';

class HomeUtilities extends StatelessWidget {
  const HomeUtilities({
    super.key,
    required this.utilities,
    required this.onNavigate,
  });

  final List<HomeUtilityData> utilities;
  final Function(String) onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiện ích",
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

          const SizedBox(height: 4.0),

          if (utilities.isEmpty)
            SizedBox(
              height: 100.0,
              child: Center(
                child: Text(
                  "Không có tiện ích nào",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: R.color.grey,
                    height: 20.0 / 14.0,
                  ),
                ),
              ),
            ),

          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 0.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 84.0 / 92.0,
            ),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: utilities.length,
            itemBuilder: (context, index) {
              return _buildActivityItem(utilities[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(HomeUtilityData utility) {
    return InkWell(
      onTap: () => onNavigate(utility.navigatorName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            utility.icon,
            width: 40.0,
            height: 40.0,
          ),
          const SizedBox(height: 12.0),
          Text(
            utility.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.0,
              color: R.color.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
