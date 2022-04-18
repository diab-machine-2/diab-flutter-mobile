import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Food/food_detail_tabbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

import '../../widgets/network_image_widget.dart';
import 'daily_nutrition/daily_nutrition.dart';

class FoodDetailController extends StatefulWidget {
  FoodDetailController({Key? key}) : super(key: key);
  @override
  FoodDetailControllerState createState() => FoodDetailControllerState();
}

class FoodDetailControllerState extends State<FoodDetailController>
    with AutomaticKeepAliveClientMixin<FoodDetailController> {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;

  ScrollController scrollController = ScrollController();

  int periodFilterType = 1;

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  @override
  void initState() {
    periodFilterType = FoodDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Diet Detail');
  }

  reloadData(int periodFilter) {
    scrollController.jumpTo(0);
    periodFilterType = periodFilter;
    refresh();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<FoodBloc>(currentContext).add(FetchInputFood(
          currentDateTime:
              (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
          periodFilterType: periodFilterType.toString(),
          page: page));
    }
    return true;
  }

  Future<bool> refresh() async {
    page = 1;
    BlocProvider.of<FoodBloc>(currentContext).add(FetchInputFood(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: periodFilterType.toString(),
        page: 1));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          List<MealDayItemModel>? model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchInputFood(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                page: 1));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is FoodInputLoaded) {
            model = state.inputs;
            hasMore = false;
            if (hasMore) {
              page += 1;
            }
            isLoading = false;
          }
          return RefreshIndicator(
              onRefresh: refresh,
              child: Scaffold(
                backgroundColor: R.color.backgroundColor,
                body: model == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image:
                              AssetImage(R.drawable.bg_detail),
                          fit: BoxFit.cover,
                        )),
                        child: LoadMore(
                            onLoadMore: _loadMore,
                            isFinish: !hasMore,
                            whenEmptyLoad: false,
                            delegate: CustomLoadMoreDelegate(),
                            textBuilder: DefaultLoadMoreTextBuilder.english,
                            child: ListView.builder(
                              controller: scrollController,
                              itemCount: model.length,
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(bottom: 100),
                              itemBuilder: (BuildContext context, int index) {
                                final element = model![index];

                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 16,
                                            left: 16,
                                            right: 16,
                                            bottom: 0),
                                        child: Text(
                                          convertCustomDate(element.date!),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      ListView.builder(
                                          padding: EdgeInsets.all(0),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: element.mealItems.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final mealItem =
                                                element.mealItems[index];
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  top: 16, left: 16, right: 16),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      color: R.color.white),
                                                  padding: EdgeInsets.only(
                                                      bottom: 8),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 12,
                                                                  bottom: 0,
                                                                  left: 16,
                                                                  right: 16),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  mealItem.text!,
                                                                  style: TextStyle(
                                                                      color: R.color
                                                                          .black,
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600)),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      mealItem
                                                                          .caloValue!
                                                                          .round()
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'Viga',
                                                                          color: R.color.green,
                                                                          fontSize:
                                                                              24,
                                                                          fontWeight:
                                                                              FontWeight.w400)),
                                                                  SizedBox(
                                                                      width: 4),
                                                                  Text(R.string.kcal.tr(),
                                                                      style: TextStyle(
                                                                          color: R.color
                                                                              .black,
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.w400))
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        ListView.builder(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    0),
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            shrinkWrap: true,
                                                            itemCount: mealItem
                                                                .inputs.length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              final inputModel =
                                                                  mealItem.inputs[
                                                                      index];
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  NavigationUtil
                                                                      .navigatePage(
                                                                    context,
                                                                    DailyNutritionPage(
                                                                      type:
                                                                          'update',
                                                                      id: inputModel
                                                                          .id,
                                                                    ),
                                                                  );
                                                                },
                                                                child:
                                                                    Container(
                                                                  color: R.color
                                                                      .transparent,
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: EdgeInsets.only(
                                                                            top:
                                                                                8,
                                                                            bottom:
                                                                                8,
                                                                            left:
                                                                                16),
                                                                        child: Text(
                                                                            '${R.string.when.tr()} ' +
                                                                                convertToUTC(inputModel.date!, 'HH:mm'),
                                                                            style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.normal)),
                                                                      ),
                                                                      ListView.separated(
                                                                          physics: NeverScrollableScrollPhysics(),
                                                                          padding: EdgeInsets.all(0),
                                                                          shrinkWrap: true,
                                                                          itemCount: inputModel.foods.length,
                                                                          separatorBuilder: (BuildContext context, int index) {
                                                                            return Container(
                                                                              height: 1,
                                                                              color: R.color.grayBorder,
                                                                            );
                                                                          },
                                                                          itemBuilder: (BuildContext context, int index) {
                                                                            final food =
                                                                                inputModel.foods[index];
                                                                            return Container(
                                                                                padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Row(children: [
                                                                                        Container(
                                                                                          width: 50,
                                                                                          height: 50,
                                                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                                                                                          child: NetWorkImageWidget(imageUrl: food.image!.url ?? ''),
                                                                                        ),
                                                                                        SizedBox(width: 12),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(food.name!, style: TextStyle(color: R.color.black, fontSize: 16, fontWeight: FontWeight.w500)),
                                                                                              const SizedBox(height: 4),
                                                                                              if (food.code == 'OtherUneditable') const SizedBox() else Text(food.text!, style: TextStyle(color: R.color.textDark, fontSize: 16, fontWeight: FontWeight.normal))
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ]),
                                                                                    ),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text(food.calorie!.round().toString(), style: TextStyle(fontFamily: 'Viga', color: R.color.black, fontSize: 20, fontWeight: FontWeight.w400)),
                                                                                        SizedBox(width: 4),
                                                                                        Text(R.string.kcal.tr(), style: TextStyle(color: R.color.black, fontSize: 14, fontWeight: FontWeight.w400))
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ));
                                                                          }),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            })
                                                      ])),
                                            );
                                          })
                                    ]);
                              },
                            ))),
              ));
        }));
  }
}
