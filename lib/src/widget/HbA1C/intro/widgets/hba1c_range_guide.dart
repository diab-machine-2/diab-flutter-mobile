import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class HbA1cRangeGuide extends StatelessWidget {
  const HbA1cRangeGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              "HbA1c của bạn đang trong khoảng nào?",
              style: TextStyle(
                fontFamily: R.font.sfpro,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: R.color.textDark,
                letterSpacing: 0.2,
              ),
            ),
          ),
          _buildRangeItems(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nguồn tham khảo:",
                  style: TextStyle(
                    fontFamily: R.font.sfpro,
                    fontSize: 14,
                    color: const Color(0xFFBFC6C6),
                    height: 1.4,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Việt P. K. B. V. Đ. H. Y. D. 1.-. C. T. C. Y. (2022, May 19). CHỈ SỐ KHỐI CƠ THỂ BMI LÀ GÌ? Ngày tham khảo April 25, 2025, từ https://umcclinic.com.vn/chi-so-khoi-co-the-bmi-la-gi",
                  style: TextStyle(
                    fontFamily: R.font.sfpro,
                    fontSize: 14,
                    color: const Color(0xFFBFC6C6),
                    height: 1.5,
                    letterSpacing: 0.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeItems() {
    final rangeData = [
      {
        'level': 'Phân loại HbA1c',
        'range': 'Khoảng HbA1c (%)',
        'color': const Color(0xFF4F7F7),
      },
      {
        'level': 'Tốt',
        'range': '< 6.5',
        'color': const Color(0xFF61D48A),
      },
      {
        'level': 'Rất tốt',
        'range': '6.5 - 7',
        'color': const Color(0xFF17B545),
      },
      {
        'level': 'Cao',
        'range': '7 - 8',
        'color': const Color(0xFFF06969),
      },
      {
        'level': 'Rất cao',
        'range': '> 8',
        'color': const Color(0xFFD04E4E),
      },
    ];

    final List<Widget> rows = [];
    for (var i = 0; i < rangeData.length; i++) {
      final data = rangeData[i];
      rows.add(_buildTableRow(
        leftLabel: data['level'] as String,
        rightLabel: data['range'] as String,
        baseColor: data['color'] as Color,
        isHeader: i == 0,
      ));
      if (i != rangeData.length - 1) {
        rows.add(Container(height: 1, color: Colors.white));
      }
    }

    return Column(children: rows);
  }

  Widget _buildTableRow({
    required String leftLabel,
    required String rightLabel,
    required Color baseColor,
    bool isHeader = false,
  }) {
    final Color headerBackground = const Color(0xFFF4F7F7);
    final Color leftBackground = isHeader ? headerBackground : baseColor;
    final Color rightBackground =
        isHeader ? headerBackground : baseColor.withOpacity(0.15);
    final Color headerTextColor = const Color(0xFF5E6566);

    return Row(
      children: [
        Expanded(
          child: Container(
            color: leftBackground,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              leftLabel,
              style: TextStyle(
                color: isHeader ? headerTextColor : Colors.white,
                fontFamily: R.font.sfpro,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        Container(width: 1, color: Colors.white),
        Expanded(
          child: Container(
            color: rightBackground,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            alignment: Alignment.center,
            child: Text(
              rightLabel,
              style: TextStyle(
                color: isHeader ? headerTextColor : R.color.textDark,
                fontFamily: R.font.sfpro,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
