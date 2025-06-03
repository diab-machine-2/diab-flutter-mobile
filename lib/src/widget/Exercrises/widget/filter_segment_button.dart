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
  // Keep all items in dataFilter including the first one we want to hide
  List<String> dataFilter = [
    R.string.filter_day.tr(args: ['1']),
    R.string.filter_day.tr(args: ['7']),
    R.string.filter_day.tr(args: ['14']),
    R.string.filter_day.tr(args: ['30']),
    R.string.filter_day.tr(args: ['90']),
  ];

  // Starting index for visible items (skip first item)
  final int _visibleStartIndex = 1;

  @override
  void initState() {
    super.initState();
    // Initialize with the initialFilterType
    if (widget.initialFilterType < 0 ||
        widget.initialFilterType >= dataFilter.length) {
      _selectedFilterType =
          _visibleStartIndex; // Default to the first visible filter type
    } else {
      _selectedFilterType = widget.initialFilterType;
    }
    _initPeriodFilterType();
  }

  _initPeriodFilterType() async {
    final periodFilterTypeStr =
        await AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index);
    final newFilterType = (int.tryParse(periodFilterTypeStr) ?? 0);

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
      final newFilterType = (int.tryParse(value) ?? 0);
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
    // Calculate the number of visible items (excluding the hidden item)
    int visibleItemCount = dataFilter.length - _visibleStartIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: CustomSlidingSegmentedControl<int>(
        fixedWidth: (MediaQuery.of(context).size.width - 32) / visibleItemCount,
        children: {
          // Create map only for visible items (skip first item)
          for (int i = _visibleStartIndex; i < dataFilter.length; i++)
            i: _buildSegmentButtonItem(
                dataFilter[i], i, _selectedFilterType == i),
        },
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
        initialValue: _selectedFilterType < _visibleStartIndex
            ? _visibleStartIndex
            : _selectedFilterType,
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
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? R.color.white : R.color.color0xff636A6B,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
