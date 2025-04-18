import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';

import '../../../../res/R.dart';

class FilterSegmentButton extends StatefulWidget {
  final int initialFilterType;
  final Function(int) onFilterChanged;

  const FilterSegmentButton({
    Key? key,
    required this.initialFilterType,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  _FilterSegmentButtonState createState() => _FilterSegmentButtonState();
}

class _FilterSegmentButtonState extends BaseState<FilterSegmentButton> {
  late int _selectedFilterType;
  List<String> dataFilter = [
    R.string.filter_day.tr(args: ['7']),
    R.string.filter_day.tr(args: ['14']),
    R.string.filter_day.tr(args: ['30']),
    R.string.filter_day.tr(args: ['90']),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with the initialFilterType
    _selectedFilterType = widget.initialFilterType;
    _initPeriodFilterType();
  }

  _initPeriodFilterType() async {
    final periodFilterTypeStr =
        await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
    final newFilterType = (int.tryParse(periodFilterTypeStr) ?? 0) -
        1; // because in getPeriodByScreen has +1

    // Update the state after the async operation
    setState(() {
      _selectedFilterType = newFilterType;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Khi quay lại màn hình này
    print("Screen is refocused via navigation (didPopNext)");
    AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index).then((value) {
      final newFilterType =
          (int.tryParse(value) ?? 0) - 1; // because in getPeriodByScreen has +1
      _onValueChanged(newFilterType);
    });
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: CustomSlidingSegmentedControl<int>(
        fixedWidth:
            (MediaQuery.of(context).size.width - 38) / dataFilter.length,
        children: dataFilter.asMap().map((index, value) => MapEntry(
              index,
              _buildSegmentButtonItem(
                  value, index, _selectedFilterType == index),
            )),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(200),
          border: Border.all(
            color: R.color.color0xffDFE4E4,
            width: 1,
          ),
        ),
        thumbDecoration: BoxDecoration(
          color: R.color.greenGradientBottom,
          borderRadius: BorderRadius.circular(200),
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInToLinear,
        initialValue: _selectedFilterType,
        onValueChanged: _onValueChanged,
      ),
    );
  }

  _onValueChanged(int value) async {
    await AppSettings.setHomeFilters(
        ScreenList.EXERCISE.index, dataFilter[value]);
    setState(() {
      _selectedFilterType = value;
    });
    widget.onFilterChanged(value);
  }

  Widget _buildSegmentButtonItem(String title, int index, bool isSelected) {
    return Container(
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? R.color.white : R.color.color0xff636A6B,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
