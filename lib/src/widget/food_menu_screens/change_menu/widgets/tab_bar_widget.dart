import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import '../models/tab_item_enum.dart';

class TabBarWidget extends StatefulWidget {
  const TabBarWidget({
    required this.initTab,
    required this.onSelect,
  });

  final TabItem initTab;
  final Function(TabItem tabItem) onSelect;

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
          tab: TabItem.suggest,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
        _buildButtonTabBar(
          tab: TabItem.recently,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
        _buildButtonTabBar(
          tab: TabItem.favorite,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
        _buildButtonTabBar(
          tab: TabItem.category,
          selectedTab: selectedTab,
          onSelect: onSelect,
        ),
      ]),
    );
  }

  Widget _buildButtonTabBar({
    required TabItem tab,
    required TabItem selectedTab,
    required Function(TabItem tabItem) onSelect,
  }) {
    final bool isSelected = tab == selectedTab;
    return GestureDetector(
      onTap: () {
        onSelect(tab);
      },
      child: Container(
        width: 143 ,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          color: isSelected ? R.color.blue_6 : R.color.transparent,
        ),
        child: Text(
          tab.title,
          style: TextStyle(
            color: isSelected
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
