import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:url_launcher/url_launcher.dart';

class GlucoseIntro2ndPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        background: R.drawable.bg_lesson_detail,
        title: R.string.huong_dan.tr(),
        child: _composeLayout(),
      ),
    );
  }

  Widget _composeLayout() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildFAQSection(),
          const SizedBox(height: 26),
          _buildRangeTableSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildFAQItem(
                      'Hướng dẫn kết nối máy đo và app DiaB', R.drawable.im_guide_connectdevice)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildFAQItem(
                      'Hướng dẫn xem biểu đồ đường huyết', R.drawable.im_guide_viewchart)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildFAQItem(
                      'Hướng dẫn đặt lịch đo đường huyết', R.drawable.im_guide_schedule)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildFAQItem(
                      'Hướng dẫn xem bảng theo dõi đường huyết', R.drawable.im_guide_read_glucose)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeTableSection() {
    // ref: _colorList
    final Map<String, Color> _colorMap = {
      'Rất Thấp': Color(0xFFF69A4C),
      'Thấp': Color(0xFFF9B047),
      'Bình thường': Color(0xFF4CB684),
      'Cao': Color(0xFFD24D4C),
      'Rất Cao': Color(0xFF9F3838),
    };
    // Mức độ,      Trước ăn, Sau ăn, Đường huyết đói, Đường huyết thai kỳ
    // Rất Cao:     >130,     >180,     >130,           >130
    // Cao:         >130,     >180,     >130,           >130
    // Bình thường: 70-130,   70-179,   70-130,         70-130
    // Thấp:        54 - 69
    // Rất Thấp:    54 - 69
    List<List<String>> rangeTable = [
      ['Mức độ', 'Trước ăn', 'Sau ăn', 'Đường huyết đói', 'Đường huyết thai kỳ'],
      ['Rất Cao', '>130', '>180', '>130', '>130'],
      ['Cao', '>130', '>180', '>130', '>130'],
      ['Bình thường', '70-130', '70-179', '70-130', '70-130'],
      ['Thấp', '54-69', '54 - 69', '54 - 69', '54 - 69'],
      ['Rất Thấp', '54-69', '54-69', '54-69', '54-69'],
    ];
    Color _headerBgColor = R.color.color0xffF2F6F9;
    final _headerTextStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: R.color.primaryGreyColor,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: R.color.gray_btn),
      ),
      child: Column(
        children: [
          // header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Text(
              'Đường huyết của bạn đang ở ngưỡng nào?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: R.color.textDark,
              ),
            ),
          ),
          // Table range
          ColoredBox(
            color: _headerBgColor,
            child: Row(
              children: [
                for (var i = 0; i < rangeTable[0].length; i++)
                  Expanded(
                    child: SizedBox(
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          rangeTable[0][i],
                          style: _headerTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      )),
                      height: 64,
                    ),
                    flex: i == 0 ? 5 : 4,
                  ),
              ],
            ),
          ),
          for (var i = 1; i < rangeTable.length; i++)
            Row(
              children: [
                for (var j = 0; j < rangeTable[i].length; j++)
                  Expanded(
                    flex: j == 0 ? 5 : 4,
                    child: Container(
                      color: j == 0
                          ? _colorMap[rangeTable[i][0]]
                          : _colorMap[rangeTable[i][0]]?.withOpacity(0.1),
                      alignment: j == 0 ? Alignment.centerLeft : Alignment.center,
                      padding: j == 0 ? const EdgeInsets.only(left: 12) : null,
                      child: Text(
                        rangeTable[i][j],
                        textAlign: TextAlign.center,
                        style: j == 0
                            ? _headerTextStyle.copyWith(
                                color: Colors.white,
                              )
                            : TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: R.color.textDark,
                              ),
                      ),
                      height: i == 2 ? 40 : 50,
                      width: double.infinity,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 12),
          // Reference info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w400,
                  color: R.color.captionColorGray,
                ),
                children: [
                  TextSpan(
                    text: 'Nguồn tham khảo: Testing for Diabetes | Diabetes. (2024, May 15).' +
                        ' CDC. Tham khảo ngày 21, Tháng 8, 2024, từ ',
                  ),
                  TextSpan(
                    text: 'https://www.cdc.gov/diabetes/diabetes-testing/',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          launchUrl(Uri.parse('https://www.cdc.gov/diabetes/diabetes-testing/')),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String title, String iconPath) {
    // just return content and padding itself
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: R.color.grayComponentBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 72, height: 72),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: R.color.primaryGreyColor,
            ),
          ),
        ],
      ),
    );
  }
}
