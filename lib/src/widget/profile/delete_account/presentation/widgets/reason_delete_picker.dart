import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ReasonDeletePicker extends StatelessWidget {
  final Function(String) onSubmit;
  final String? valueSelected;
  const ReasonDeletePicker({
    Key? key,
    required this.onSubmit,
    this.valueSelected,
  }) : super(key: key);

  static showModelSheet(
    BuildContext context, {
    required Function(String) onSubmit,
    String? valueSelected,
  }) {
    showBarModalBottomSheet(
      context: context,
      barrierColor: R.color.mainColor.withOpacity(0.7),
      builder: (context) => ReasonDeletePicker(
        onSubmit: onSubmit,
        valueSelected: valueSelected,
      ),
    );
  }

  static List<String> reasonList = [
    "Không dùng tài khoản",
    "Thay đổi số điện thoại",
    "Muốn dùng tài khoản mới",
    "Khác"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: R.color.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Chọn lý do huỷ",
                      style: TextStyle(
                        color: R.color.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 28),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reasonList
                  .map(
                    (value) => InkWell(
                      onTap: () {
                        onSubmit(value);
                        Navigator.pop(context);
                      },
                      child: _rowOptionWidget(value),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _rowOptionWidget(String title) {
    bool isSelected = valueSelected == title;
    return Container(
      margin: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
      ),
      padding: EdgeInsets.only(
        bottom: 16,
      ),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: R.color.grayBorder))),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? R.color.accentColor : R.color.textDark,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 15),
          Icon(
            Icons.check,
            color: isSelected ? R.color.accentColor : Colors.transparent,
          )
        ],
      ),
    );
  }
}
