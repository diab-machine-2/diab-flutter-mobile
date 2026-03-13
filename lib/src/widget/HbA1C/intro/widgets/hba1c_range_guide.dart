import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:url_launcher/url_launcher.dart';

class HbA1cRangeGuide extends StatelessWidget {
  const HbA1cRangeGuide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${R.string.reference_source.tr()}:",
                  style: TextStyle(
                    fontSize: 14,
                    color: R.color.color0xffBFC6C6,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://giaan115.com/kien-thuc-y-khoa/chi-so-hba1c-nhung-dieu-ban-can-biet',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    'https://giaan115.com/kien-thuc-y-khoa/chi-so-hba1c-nhung-dieu-ban-can-biet',
                    style: TextStyle(
                      fontSize: 14,
                      color: R.color.color0xffBFC6C6,
                    ),
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
        'level': 'Lý tưởng',
        'range': '≤ 6.5',
        'color': const Color(0xFF64E18E), // #64E18E
      },
      {
        'level': 'Tốt',
        'range': '6.5 - 7.0',
        'color': const Color(0xFF23C559), // #23C559
      },
      {
        'level': 'Cao',
        'range': '7.0 - 8.0',
        'color': const Color(0xFFF86F6F), // #F86F6F
      },
      {
        'level': 'Rất cao',
        'range': '> 8.0',
        'color': const Color(0xFFD02424), // #D02424
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
