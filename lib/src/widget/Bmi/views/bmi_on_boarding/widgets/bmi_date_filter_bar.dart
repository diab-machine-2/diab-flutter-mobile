import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/enum.dart';

class BmiDateFilterBar extends StatefulWidget {
  const BmiDateFilterBar({super.key, this.onChanged});

  final void Function(BmiDateFilterType filterType)? onChanged;

  @override
  State<BmiDateFilterBar> createState() => _BmiDateFilterBarState();
}

class _BmiDateFilterBarState extends State<BmiDateFilterBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BmiBloc _bmiBloc;
  BmiDateFilterType? _lastPeriodType;

  final List<Widget> _tabs = BmiDateFilterType.values
      .map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${e.days} ${R.string.day.tr()}",
                style: TextStyle(
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ))
      .toList();

  @override
  void initState() {
    super.initState();
    _bmiBloc = context.read();
    _lastPeriodType = _bmiBloc.periodType;
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: _bmiBloc.periodType.index,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync TabController when period type changes externally
    final currentPeriodType = _bmiBloc.periodType;
    if (_lastPeriodType != currentPeriodType &&
        _tabController.index != currentPeriodType.index &&
        currentPeriodType.index >= 0 &&
        currentPeriodType.index < _tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index != currentPeriodType.index) {
          _tabController.animateTo(currentPeriodType.index);
        }
      });
      _lastPeriodType = currentPeriodType;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync TabController with bloc's period type if it changed
    final currentPeriodType = _bmiBloc.periodType;
    if (_lastPeriodType != currentPeriodType &&
        currentPeriodType.index >= 0 &&
        currentPeriodType.index < _tabs.length &&
        _tabController.index != currentPeriodType.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _tabController.index != currentPeriodType.index) {
          _tabController.animateTo(currentPeriodType.index);
        }
      });
      _lastPeriodType = currentPeriodType;
    }

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
        onTap: (value) {
          _lastPeriodType = BmiDateFilterType.values[value];
          widget.onChanged?.call(BmiDateFilterType.values[value]);
        },
      ),
    );
  }
}
