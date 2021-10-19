import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import '../models/tab_item_enum.dart';

class TabBarWidget extends StatefulWidget {
  const TabBarWidget({
    required this.initTab,
    required this.onSelect,
    this.showOnlySuggestTab,
  });

  final TabItem initTab;
  final Function(TabItem tabItem) onSelect;
  final bool? showOnlySuggestTab;

  @override
  _TabBarWidgetState createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  late TabItem selectedTab;
  late Function(TabItem tabItem) onSelect;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initTab;
    onSelect = (TabItem tab) {
      selectedTab = tab;
      widget.onSelect(tab);
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _buildButtonTabBar(
          isEnable: true,
          tab: TabItem.suggest,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
        _buildButtonTabBar(
          isEnable: !(widget.showOnlySuggestTab ?? false),
          tab: TabItem.recently,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
        _buildButtonTabBar(
          isEnable: !(widget.showOnlySuggestTab ?? false),
          tab: TabItem.favorite,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
        _buildButtonTabBar(
          isEnable: !(widget.showOnlySuggestTab ?? false),
          tab: TabItem.category,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
      ]),
    );
  }

  Widget _buildButtonTabBar({
    required bool isEnable,
    required TabItem tab,
    required TabItem selectedTab,
    required Function(TabItem tabItem) onSelect,
  }) {
    return GestureDetector(
      onTap: isEnable
          ? () {
              onSelect(tab);
            }
          : () {},
      child: Container(
        width: 143.w,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: tab == selectedTab ? R.color.blue_6 : R.color.transparent,
        ),
        child: Text(
          tab.title,
          style: TextStyle(
            color: isEnable
                ? R.color.greenGradientBottom
                : R.color.captionColorGray,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
