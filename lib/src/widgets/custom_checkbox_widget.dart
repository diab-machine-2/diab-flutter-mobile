import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class CustomCheckboxWidget extends StatelessWidget {
  const CustomCheckboxWidget({
    required this.isChecked,
    this.title,
    this.titleStyle,
    required this.onTap,
  });

  final bool isChecked;
  final String? title;
  final TextStyle? titleStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? R.color.greenGradientBottom : R.color.white,
              border: isChecked
                  ? null
                  : Border.all(width: 2, color: R.color.primaryGreyColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isChecked
                ? Icon(
                    Icons.check,
                    color: R.color.white,
                    size: 22,
                  )
                : const SizedBox(),
          ),
        ),
        if (title != null) const SizedBox(width: 16),
        if (title != null)
          Text(
            title!,
            style: titleStyle ??
                TextStyle(
                  color: R.color.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
          ),
      ],
    );
  }
}
