import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import '../../activity_tab/models/schedule_type.dart';

class SelectTypeWidget extends StatefulWidget {
  const SelectTypeWidget({
    required this.title,
    this.onTap,
    this.subList,
    this.onSlectType,
  });

  final String title;
  final VoidCallback? onTap;
  final List<ScheduleType>? subList;
  final Function(ScheduleType type)? onSlectType;

  @override
  _SelectTypeWidgetState createState() => _SelectTypeWidgetState();
}

class _SelectTypeWidgetState extends State<SelectTypeWidget> {
  bool showSubList = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            if (widget.subList == null) {
              widget.onTap?.call();
            } else {
              setState(() {
                showSubList = !showSubList;
              });
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: showSubList ? 0 : 16),
            decoration: BoxDecoration(
                color: R.color.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8))),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    showSubList ? Icons.keyboard_arrow_up : Icons.chevron_right,
                    size: 20,
                    color: R.color.greenGradientBottom,
                  ),
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: showSubList,
          child: Column(
            children: _buildSubList(),
          ),
        )
      ],
    );
  }

  List<Widget> _buildSubList() {
    if (widget.subList?.isNotEmpty != true) return [];

    final List<Widget> subList = [];
    for (int index = 0; index < widget.subList!.length; index++) {
      subList.add(
        InkWell(
          onTap: () {
            if (widget.onSlectType != null) {
              widget.onSlectType!(widget.subList![index]);
            }
          },
          child: Container(
            height: 48,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: R.color.white,
              border: Border(
                bottom: BorderSide(color: R.color.grayComponentBorder),
              ),
            ),
            child: Text(
              widget.subList![index].title,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    subList.add(
      const SizedBox(height: 16),
    );

    return subList;
  }
}
