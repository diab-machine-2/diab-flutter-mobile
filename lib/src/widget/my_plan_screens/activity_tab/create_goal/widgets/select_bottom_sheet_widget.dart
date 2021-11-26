import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class SelectBottomSheetWidget extends StatefulWidget {
  const SelectBottomSheetWidget({
    required this.title,
    this.selectedList = const [],
    this.elementList = const [],
    required this.onSelected,
    this.isMultipleChoice = false,
  });

  final String title;
  final List<String> selectedList;
  final List<String> elementList;
  final Function(List<String>) onSelected;
  final bool isMultipleChoice;
  @override
  _SelectBottomSheetWidgetState createState() =>
      _SelectBottomSheetWidgetState();
}

class _SelectBottomSheetWidgetState extends State<SelectBottomSheetWidget> {
  List<String> selectedList = [];

  @override
  void initState() {
    super.initState();
    selectedList = widget.selectedList;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        54;

    final double countHight = widget.elementList.length * 48.0 + 216;

    return SafeArea(
      child: Container(
        height: countHight > height ? height : countHight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                height: 3.86,
                width: 60,
                decoration: BoxDecoration(color: R.color.color0xffE5E5E5),
              ),
            ),
            const SizedBox(height: 27),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 24,
                      width: 24,
                      child: Image.asset(R.drawable.ic_close),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                  physics: countHight > height
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, bottom: 8, top: 10),
                  itemCount: widget.elementList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildItem(
                        title: widget.elementList[index],
                        isLast: index == widget.elementList.length - 1);
                  }),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    widget.onSelected(selectedList);
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 48,
                    width: 195,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [
                            R.color.greenGradientTop,
                            R.color.greenGradientBottom
                          ]),
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Center(
                      child: Text(
                        R.string.save.tr(),
                        style: TextStyle(
                            color: R.color.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({required String title, bool isLast = false}) {
    final bool isSelected = title != null && selectedList.contains(title);
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (!isSelected) {
                if (!widget.isMultipleChoice) {
                  selectedList.clear();
                }
                selectedList.add(title);
              } else if (widget.isMultipleChoice) {
                selectedList.remove(title);
              }
            });
          },
          child: Container(
            color: isSelected ? R.color.greenbg : R.color.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isSelected)
                          Text(
                            title,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: R.color.mainColor),
                          )
                        else
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        if (isSelected)
                          Image.asset(R.drawable.ic_check_mark,
                              width: 24, height: 24)
                        else
                          const SizedBox()
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                    height: 1,
                    width: 373,
                    color:
                        isSelected ? R.color.greenbg : R.color.color0xffD6D8E0)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
