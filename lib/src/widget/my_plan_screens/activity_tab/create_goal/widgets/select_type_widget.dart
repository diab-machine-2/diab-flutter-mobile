import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class SelectTypeWidget extends StatefulWidget {
  const SelectTypeWidget({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  _SelectTypeWidgetState createState() => _SelectTypeWidgetState();
}

class _SelectTypeWidgetState extends State<SelectTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: R.color.main_6,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: R.color.greenGradientBottom,
            ),
          ],
        ),
      ),
    );
  }
}
