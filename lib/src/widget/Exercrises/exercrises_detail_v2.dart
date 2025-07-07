import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/modal/exercrises/exercrise_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/utils/app_log.dart';
import 'package:medical/src/widget/Exercrises/exercrises_detail_tabbar.dart';
import 'package:medical/src/widget/Exercrises/widget/filter_segment_button.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import '../../utils/navigator_name.dart';
import 'widget/exercrises_list_card.dart';

class ExercrisesDetailV2 extends StatefulWidget {
  final int periodFilterType;

  ExercrisesDetailV2({Key? key, this.periodFilterType = 0}) : super(key: key);

  ExercrisesDetailV2State createState() => ExercrisesDetailV2State();
}

class ExercrisesDetailV2State extends State<ExercrisesDetailV2>
    with WidgetsBindingObserver, Observer {
  late BuildContext currentContext;
  ScrollController scrollController = ScrollController();

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;
  int periodFilterType = 0;

  List<InputDataExercriseModel> _groupedData = [];

  // Cache để tránh tính toán lại
  Map<int, String> _dateCache = {};
  bool _isDataDirty = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    periodFilterType = widget.periodFilterType;

    final controller = ExercrisesDetailTabbarController.of(context);
    if (controller != null) {
      periodFilterType = controller.periodFilterType;
    } else {
      Console.log('ExercrisesDetailTabbarController is null');
    }
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    Observable.instance.removeObserver(this); // Hủy đăng ký observer
    scrollController.dispose(); // Hủy ScrollController nếu có
    super.dispose(); // Gọi super.dispose() để giải phóng tài nguyên
  }

  reloadData(int periodFilter) {
    if (scrollController.hasClients) {
      scrollController
          .jumpTo(0); // Chỉ gọi jumpTo nếu ScrollController đã được gắn
    }
    periodFilterType = periodFilter;
    // Reset grouped data khi reload
    _groupedData.clear();
    _dateCache.clear();
    _isDataDirty = false;
    _refresh();
  }

  // Debounced filter change để tránh quá nhiều requests
  void _onFilterChanged(int newFilterType) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      setState(() {
        periodFilterType = newFilterType;
        reloadData(periodFilterType);
      });
    });
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
        page: page,
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
      ));
    }
    return true;
  }

  Future<bool> _refresh() async {
    page = 1;
    // Reset grouped data khi refresh
    _groupedData.clear();
    _dateCache.clear();
    _isDataDirty = false;
    BlocProvider.of<ExercrisesBloc>(currentContext).add(FetchInputExercrises(
      page: 1,
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilterType.toString(),
    ));
    return true;
  }

  // Merge data by date - optimized
  void _mergeDataByDate(List<InputDataExercriseModel> newData) {
    if (newData.isEmpty) return;

    // Tạo map từ date để lookup nhanh hơn
    var dateToIndexMap = <int, int>{};
    for (int i = 0; i < _groupedData.length; i++) {
      var date = _groupedData[i].date ?? 0;
      if (date > 0) {
        dateToIndexMap[_getDateKey(date)] = i;
      }
    }

    var itemsToAdd = <InputDataExercriseModel>[];
    var hasChanges = false;

    for (var newItem in newData) {
      var newItemDateKey = _getDateKey(newItem.date ?? 0);
      var existingIndex = dateToIndexMap[newItemDateKey];

      if (existingIndex != null) {
        // Merge với item hiện tại
        var existingItem = _groupedData[existingIndex];
        var mergedExerciseInput =
            List<InputExercriseModel>.from(existingItem.exerciseInput);
        mergedExerciseInput.addAll(newItem.exerciseInput);

        var updatedCalorie = (existingItem.sumBurnedCalorie ?? 0) +
            (newItem.sumBurnedCalorie ?? 0);
        var updatedItem = InputDataExercriseModel(
          date: existingItem.date,
          sumBurnedCalorie: updatedCalorie,
          exerciseInput: mergedExerciseInput,
        );

        _groupedData[existingIndex] = updatedItem;
        hasChanges = true;
      } else {
        //  item mới vào batch
        itemsToAdd.add(newItem);
        dateToIndexMap[newItemDateKey] =
            _groupedData.length + itemsToAdd.length - 1;
      }
    }

    // Batch add items mới
    if (itemsToAdd.isNotEmpty) {
      _groupedData.addAll(itemsToAdd);
      hasChanges = true;
    }

    // Chỉ sort nếu có thay đổi
    if (hasChanges) {
      _groupedData.sort((a, b) => (b.date ?? 0).compareTo(a.date ?? 0));
      _isDataDirty = true;
    }
  }

  // Helper method để kiểm tra 2 timestamp có cùng ngày không
  bool _isSameDate(int timestamp1, int timestamp2) {
    var date1 = DateTime.fromMillisecondsSinceEpoch(timestamp1 * 1000);
    var date2 = DateTime.fromMillisecondsSinceEpoch(timestamp2 * 1000);
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Tạo key unique cho mỗi ngày để lookup nhanh
  int _getDateKey(int timestamp) {
    if (timestamp <= 0) return 0;
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return date.year * 10000 + date.month * 100 + date.day;
  }

  // Cache formatted date để tránh tính toán lại
  String _getFormattedDate(int timestamp) {
    if (timestamp <= 0) return '';

    var cached = _dateCache[timestamp];
    if (cached != null) return cached;

    var formatted = convertToSectionTicketDate(timestamp, '');
    _dateCache[timestamp] = formatted;
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: R.color.backgroundColorNew,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: _goBack),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.exercrise_detail_v2_title.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 20 * 0.002,
                    fontFamily: 'SFPro',
                  ),
                ),
              ),
            ),
            backgroundColor: R.color.transparent, //No more green
            elevation: 0.0, //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xFF0DAB9C),
                    Color(0xFF01847A),
                  ])),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, NavigatorName.exercrise_guide);
                },
                child: Text(
                  R.string.exercrise_step_onboarding_action_btn.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SFPro',
                  ),
                ),
              ),
            ],
          ),
          body: _buildContainer(),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return Column(
      children: [
        // Thêm FilterSegmentButton ở đây
        FilterSegmentButton(
          initialFilterType: periodFilterType,
          onFilterChanged: _onFilterChanged,
        ),
        Expanded(
          child: BlocProvider<ExercrisesBloc>(
            create: (context) => ExercrisesBloc(),
            child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
                builder: (BuildContext context, ExercrisesState state) {
              currentContext = context;
              if (state is ExercrisesInitial) {
                BlocProvider.of<ExercrisesBloc>(context).add(
                    FetchInputExercrises(
                        currentDateTime:
                            (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                                .toString(),
                        periodFilterType: periodFilterType.toString(),
                        page: 1));
              }
              if (state is ExercrisesError) {
                Message.showToastMessage(context, state.message);
              }
              if (state is ExercrisesLoading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state is ExercrisesDataLoaded) {
                // Gộp dữ liệu mới với dữ liệu đã có
                _mergeDataByDate(state.inputExercrisesModel);
                hasMore = state.hasMore;
                if (hasMore!) {
                  page += 1;
                }
                isLoading = false;
              }

              // Sử dụng _groupedData thay vì model từ state
              if (_groupedData.isEmpty) {
                return Center(
                  child: Text(
                    R.string.no_data_available.tr(),
                    style: TextStyle(color: R.color.textDark, fontSize: 16),
                  ),
                );
              }

              return RefreshIndicator(
                  onRefresh: _refresh,
                  child: Container(
                    color: R.color.transparent,
                    child: Container(
                        child: LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore!,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: scrollController,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 80, top: 10),
                              itemCount: _groupedData.length,
                              itemBuilder: (BuildContext context, int index) {
                                final item = _groupedData[index];
                                if (item.exerciseInput.isEmpty) {
                                  return Center(
                                    child: Text(
                                      R.string.no_data_available.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16),
                                    ),
                                  );
                                }

                                List<ListExercriseModel> exercises = [];
                                for (var item in item.exerciseInput) {
                                  exercises.addAll(item.exercise);
                                }
                                if (exercises.isEmpty) {
                                  return Center(
                                    child: Text(
                                      R.string.no_data_available.tr(),
                                      style: TextStyle(
                                          color: R.color.textDark,
                                          fontSize: 16),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: index == 0 ? 0 : 16,
                                      left: 16,
                                      right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_getFormattedDate(item.date ?? 0),
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 20,
                                              fontFamily: 'SFPro',
                                              fontWeight: FontWeight.w700)),
                                      SizedBox(height: 16),
                                      _buildExerciseGroupContainer(
                                          item.exerciseInput),
                                    ],
                                  ),
                                );
                              },
                            ))),
                  ));
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseGroupContainer(List<InputExercriseModel> inputs) {
    final allExercises = <ListExercriseModel>[];
    final exerciseInputIds = <String>[];

    for (var input in inputs) {
      if (input.exercise.isNotEmpty) {
        allExercises.addAll(input.exercise);
        exerciseInputIds.add(input.id ?? '');
      }
    }

    if (allExercises.isEmpty) {
      return SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(allExercises.length, (index) {
          final isLast = index == allExercises.length - 1;
          final exercise = allExercises[index];
          final exerciseInputId = index < exerciseInputIds.length
              ? exerciseInputIds[index]
              : ''; // đảm bảo không out-of-bound

          return ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? Radius.circular(16) : Radius.zero,
              bottom: isLast ? Radius.circular(16) : Radius.zero,
            ),
            child: _buildExerciseItem(exercise, exerciseInputId),
          );
        }),
      ),
    );
  }

  _buildExerciseItem(
    ListExercriseModel exercise,
    String exerciseInputId,
  ) {
    bool isItemFromHealthApp =
        exercise.category?.contains('(health app)') ?? false;
    return InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            NavigatorName.exercrise_add_v2,
            arguments: {
              'isUpdate': true,
              'exerciseInputId': exerciseInputId,
            },
          );
        },
        child: Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(200),
                      child: Container(
                        width: 42.w,
                        height: 42.h,
                        padding: EdgeInsets.all(8),
                        color: R.color.main_1.withOpacity(0.8),
                        child: NetWorkImageWidget(
                          imageUrl: exercise.imageUrl.url ?? '',
                          width: 42.w,
                          height: 42.h,
                          isSelected: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    (isItemFromHealthApp)
                        ? _itemCategoryWithCalorieFromHealthConnect(
                            category: exercise.category
                                    ?.replaceAll(RegExp(r'\s*\(.*?\)'), '') ??
                                '',
                            burnedCalorie: exercise.burnedCalorie ?? 0.0,
                          )
                        : Flexible(
                            child: Text(
                              exercise.category ?? '',
                              style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                    if (!isItemFromHealthApp)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.fiber_manual_record,
                            size: 10, color: R.color.primaryGreyColor),
                      ),
                    if (!isItemFromHealthApp)
                      Text(
                        '${formatNumber(exercise.burnedCalorie)} ${R.string.kcal.tr()}',
                        style: TextStyle(
                          color: R.color.primaryGreyColor,
                          fontSize: 13,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              isItemFromHealthApp
                  ? _itemDurationWithStepsFromHealthConnect(
                      duration: exercise.duration ?? 0.0,
                      steps: exercise.value?.toDouble() ?? 0.0,
                    )
                  : Text(
                      formatNumber(exercise.duration),
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 18,
                        fontFamily: 'SFPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              if (!isItemFromHealthApp)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    isItemFromHealthApp
                        ? R.string.minute.tr()
                        : R.string.minute_upper_case_first.tr(),
                    style: TextStyle(
                      color: R.color.primaryGreyColor,
                      fontSize: 12,
                      fontFamily: 'SFPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _itemCategoryWithCalorieFromHealthConnect(
      {required String category, required double burnedCalorie}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
              text: category,
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: ' (Health app)',
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 12,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w400,
              ),
            ),
          ])),
        ),
        SizedBox(height: 4.h),
        Text(
          '${formatNumber(burnedCalorie)} ${R.string.kcal.tr()}',
          style: TextStyle(
            color: R.color.primaryGreyColor,
            fontSize: 13,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _itemDurationWithStepsFromHealthConnect(
      {required double duration, required double steps}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
              text: formatNumber(duration),
              style: TextStyle(
                color: R.color.greenGradientBottom,
                fontSize: 18,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w700,
              ),
            ),
            WidgetSpan(
              child: SizedBox(width: 8),
            ),
            TextSpan(
              text: R.string.minute.tr(),
              style: TextStyle(
                color: R.color.primaryGreyColor,
                fontSize: 12,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ])),
        ),
        SizedBox(height: 4.h),
        Text(
          '${formatNumber(steps)}  ${R.string.steps.tr()}',
          style: TextStyle(
            color: R.color.primaryGreyColor,
            fontSize: 13,
            fontFamily: 'SFPro',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
