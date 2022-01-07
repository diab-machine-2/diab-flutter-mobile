import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widgets/select_bottom_sheet_widget.dart';
import 'package:medical/src/widgets/user_icon_widget.dart';

class ItemProfile extends StatefulWidget {
  String? image;
  String? icon;
  String title;
  String subTitle;
  Widget? subIcon;
  Function(List<int>)? callback;
  List<String> elementList;
  List<String> selectedList;
  String selectedDialogTitle;
  bool isShowSelectedDialog;
  bool isMultipleChoice;

  ItemProfile({
    this.image,
    this.icon,
    required this.title,
    required this.subTitle,
    this.elementList = const [],
    this.selectedList = const [],
    this.selectedDialogTitle = '',
    this.subIcon,
    this.callback,
    this.isShowSelectedDialog = false,
    this.isMultipleChoice = false,
  });

  @override
  _ItemProfileState createState() => _ItemProfileState();
}

class _ItemProfileState extends State<ItemProfile> {
  String title = '';
  List<String> selectedList = [];

  @override
  void initState() {
    selectedList = widget.selectedList;
    title = getTitleFromSelectedList(widget.selectedList);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isShowSelectedDialog) {
          showActionFilter(
              context: context,
              builder: (context) {
                return SelectBottomSheetWidget(
                  title: widget.selectedDialogTitle,
                  selectedList: selectedList,
                  elementList: widget.elementList,
                  isMultipleChoice: widget.isMultipleChoice,
                  onSelected: (typeList) {
                    selectedList = typeList;
                    if (typeList.isNotEmpty) {
                      var selectedIndexList = getSelectedIndexList(widget.elementList, typeList);
                      title = getTitleFromSelectedList(typeList);
                      //  setState(() {});

                      if (widget.callback != null) {
                        widget.callback!(selectedIndexList);
                      }
                    }
                  },
                );
              });
        } else {
          if (widget.callback != null) {
            widget.callback!([]);
          }
        }
      },
      child: Container(
        color: R.color.transparent,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (widget.image != null)
                Image.asset(widget.image!, width: 33, height: 33)
              else
                UserIconWidget(
                  icon: widget.icon!,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    title,
                    style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subTitle,
                    style: TextStyle(
                      color: R.color.captionColorGray,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ]),
              )
            ]),
          ),
          if (widget.subIcon != null) widget.subIcon!
        ]),
      ),
    );
  }

  showActionFilter({required BuildContext context, required Widget Function(BuildContext) builder}) {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: builder,
    );
  }

  List<int> getSelectedIndexList(List<String> elementList, List<String> selectedList) {
    List<int> selectedIndexList = [];
    for (var selectedItem in selectedList) {
      for (int j = 0; j < elementList.length; j++) {
        if (selectedItem == elementList[j]) {
          selectedIndexList.add(j);
        }
      }
    }
    selectedIndexList.sort((a, b) => a.compareTo(b));
    return selectedIndexList;
  }

  String getTitleFromSelectedList(List<String> selectedList) {
    String title = '';
    for (var selectedItem in selectedList) {
      title += selectedItem + ", ";
    }
    if (title.length > 2) {
      title = title.substring(0, title.length - 2);
    }
    if (title.isEmpty) {
      title = 'Chưa có';
    }
    return title;
  }
}
