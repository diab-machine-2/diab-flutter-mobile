import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/HbA1C/hba1c_functions.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widget/HbA1C/hba1c_navigation_helper.dart';

class HbA1cHelpSection extends StatelessWidget {
  const HbA1cHelpSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            "Bạn cần hỗ trợ gì?",
            style: TextStyle(
              fontSize: 18,
              fontFamily: R.font.sfpro,
              fontWeight: FontWeight.w700,
              height: 24 / 18,
              letterSpacing: 0.2,
              color: R.color.dark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildHelpGrid(context),
      ],
    );
  }

  Widget _buildHelpGrid(BuildContext context) {
    final helpItems = [
      {
        'title': 'Ghi lại HbA1c trên ứng dụng DiaB',
        'image': R.drawable.im_hba1c_supports_1,
        'onTap': () async => await showHbA1cInputMethodModal(context),
      },
      {
        'title': 'Kết nối thiết bị theo dõi sức khỏe',
        'image': R.drawable.im_hba1c_supports_2,
        'onTap': () {
          RequestHealthConnect.showModal(
            context,
            callback: () => Navigator.pop(context),
          );
        },
      },
      {
        'title': 'Theo dõi chỉ số trên biểu đồ',
        'image': R.drawable.im_hba1c_supports_3,
        'onTap': () => HbA1cNavigationHelper.navigateToHbA1C(context),
      },
      {
        'title': 'Thiết lập nhắc đo HbA1c',
        'image': R.drawable.im_hba1c_supports_4,
        'onTap': () {
          Navigator.pushNamed(context, NavigatorName.reminder);
        },
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildHelpItem(helpItems[0])),
            const SizedBox(width: 8),
            Expanded(child: _buildHelpItem(helpItems[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildHelpItem(helpItems[2])),
            const SizedBox(width: 8),
            Expanded(child: _buildHelpItem(helpItems[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildHelpItem(Map<String, dynamic> item) {
    String title = item['title'] as String;
    String imagePath = item['image'] as String;
    VoidCallback onTap = item['onTap'] as VoidCallback;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        height: 152.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
          // border: Border.all(color: R.color.grayComponentBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              child: ClipRRect(
                child: Image.asset(
                  imagePath,
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 72,
                      height: 72,
                      child: Icon(
                        Icons.image,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: 146,
                height: 44,
                alignment: Alignment.center,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                    fontFamily: R.font.sfpro,
                    color: R.color.hba1c_text_color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
