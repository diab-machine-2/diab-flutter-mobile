import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/widget/Bmi_temp/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi_temp/enum.dart';

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
            child: Text("${e.days} ${R.string.day.tr()}",
                style: TextStyle(
                  fontSize: 14,
                )),
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
        labelStyle: R.style.boldLargeStyle.copyWith(color: Colors.white),
        unselectedLabelStyle:
            R.style.largeTextStyle.copyWith(color: AppColors.neutral3),
        onTap: (value) =>
            widget.onChanged?.call(BmiDateFilterType.values[value]),
      ),
    );
  }
}
