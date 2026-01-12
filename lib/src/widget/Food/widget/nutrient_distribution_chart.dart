import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_statistic_distribute_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/daily_nutrition/daily_nutrition.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/empty_data_box.dart';

/// Widget hiển thị phân bổ dinh dưỡng với các thanh tiến trình ngang
/// Hiển thị tỷ lệ phần trăm các nhóm dinh dưỡng: Tinh bột, Chất đạm, Chất béo, Rau củ, Hoa quả
class NutrientDistributionChart extends StatefulWidget {
  NutrientDistributionChart({Key? key}) : super(key: key);
  @override
  NutrientDistributionChartState createState() =>
      NutrientDistributionChartState();
}

class NutrientDistributionChartState extends State<NutrientDistributionChart>
    with AutomaticKeepAliveClientMixin<NutrientDistributionChart> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    _refresh();
  }

  Future<bool> _refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchStatisticDistribute(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  /// Lấy màu sắc dựa trên phần trăm
  /// - <= 50%: Xanh lá nhạt
  /// - 51-80%: Xanh lá đậm
  /// - 81-100%: Vàng
  /// - > 100%: Đỏ/Cam
  Color _getColorByPercent(double percent, String? colorCode) {
    // Nếu có colorCode từ API thì ưu tiên sử dụng
    if (colorCode != null && colorCode.isNotEmpty) {
      return toColor(colorCode);
    }
    // Fallback logic theo percent
    if (percent <= 50) {
      return const Color(0xFF81C784); // Light green
    } else if (percent <= 80) {
      return const Color(0xFF4CAF50); // Green
    } else if (percent <= 100) {
      return const Color(0xFFFFD233); // Yellow
    } else {
      return const Color(0xFFEF5350); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          FoodDistributeModel? model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchStatisticDistribute(
              currentDateTime:
                  (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
              periodFilterType: periodFilterType.toString(),
            ));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }

          if (state is FoodStatisticDistributeLoaded) {
            model = state.model;
          }
          return model == null
              ? Container(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()))
              : Padding(
                  padding:
                      EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      model.carbChart.isEmpty
                          ? EmptyDataBox(
                              text: "chỉ số Dinh dưỡng",
                              onTap: () {
                                NavigationUtil.navigatePage(
                                  context,
                                  DailyNutritionPage(
                                    type: 'input',
                                    id: null,
                                  ),
                                );
                              },
                            )
                          : Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF7DD3FC),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with title and arrow
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        R.string.phan_bo_dinh_duong.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: R.color.black,
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: R.color.primaryGreyColor,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  // Nutrient progress bars using carbChart
                                  ...model.carbChart.map((item) {
                                    return _buildNutrientRow(
                                      item.text ?? '',
                                      item.percentValue ?? 0,
                                      _getColorByPercent(item.percentValue ?? 0,
                                          item.colorCode),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                    ],
                  ),
                );
        }));
  }

  /// Build một row cho mỗi loại dinh dưỡng với thanh tiến trình
  Widget _buildNutrientRow(String name, double percent, Color color) {
    // Giới hạn hiển thị thanh tiến trình tối đa 100% nhưng hiển thị số thực tế
    final double displayPercent = percent > 100 ? 100 : percent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Tên dinh dưỡng
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.black,
              ),
            ),
          ),
          // Thanh progress
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: displayPercent / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          // Phần trăm
          SizedBox(
            width: 50,
            child: Text(
              '${percent.round()}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: R.color.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
