import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/widget/bmi/enum.dart';

class BmiDateFilterBar extends StatefulWidget {
  const BmiDateFilterBar({super.key, this.onChanged});

  final void Function(BmiDateFilterType filterType)? onChanged;

  @override
  State<BmiDateFilterBar> createState() => _BmiDateFilterBarState();
}

class _BmiDateFilterBarState extends State<BmiDateFilterBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = BmiDateFilterType.values
      .map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text("${e.days} "),
          ))
      .toList();

  @override
  void initState() {
    _tabController = TabController(length: _tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral5),
          borderRadius: BorderRadius.circular(
            50.0,
          ),
          color: Colors.white),
      child: TabBar(
        controller: _tabController,
        unselectedLabelColor: AppColors.neutral3,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(
            50.0,
          ),
          color: R.color.mainColor,
        ),
        tabs: _tabs,
        labelStyle: R.style.largeTextStyle.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        unselectedLabelStyle:
            R.style.largeTextStyle.copyWith(color: AppColors.neutral3),
        onTap: (value) =>
            widget.onChanged?.call(BmiDateFilterType.values[value]),
      ),
    );
  }
}
