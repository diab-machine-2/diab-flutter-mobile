import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/utils/debouncer.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class SearchFood extends StatefulWidget {
  final List<FoodModel> foods;
  final double? suggestKcal;
  const SearchFood({required this.foods, required this.suggestKcal});
  @override
  _SearchFoodState createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> with Observer {
  late BuildContext currentContext;

  TextEditingController controller = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  List<FoodModel> selectedFoods = [];

  int page = 1;
  bool? hasMore = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller.text = '';
    selectedFoods = [...widget.foods];
    Observable.instance.addObserver(this);
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName != 'add_food_to_cart') return;
    final FoodModel? foodModel = map?['food'];
    if (foodModel == null) return;
    this.selectedFoods.add(foodModel);
    setState(() {});
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore!) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<FoodBloc>(currentContext)
          .add(FetchSearchFood(keyword: controller.text, page: page));
    }
    return true;
  }

  Future<bool> refresh() async {
    if (isLoading) {
      return true;
    } else {
      isLoading = true;
      page = 1;
      BlocProvider.of<FoodBloc>(currentContext)
          .add(FetchSearchFood(keyword: controller.text, page: page));
      return true;
    }
  }

  likeFood(FoodModel model, int index) {
    BlocProvider.of<FoodBloc>(currentContext)
        .add(LikeFood(model: model, index: index));
  }

  double? getKcalLeft(FoodModel? selectedModel) {
    if (widget.suggestKcal == null) return null;
    double totalSelectedKcal = 0;
    for (final food in selectedFoods) {
      totalSelectedKcal += food.totalKcal ?? 0;
    }
    final double kcalLeft = widget.suggestKcal! -
        totalSelectedKcal +
        (selectedModel?.totalKcal ?? 0);
    return max(kcalLeft, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: BoxDecoration(
            color: R.color.backgroundColorNew,
          ),
          child: SafeArea(
            top: false,
            child: Column(children: [
              CustomAppBar(
                  title: Text(
                    R.string.nhap_mon_an.tr(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark),
                  ),
                  backgroundColor: R.color.transparent,
                  leadingIcon: IconButton(
                      splashColor: R.color.transparent,
                      highlightColor: R.color.transparent,
                      icon: Icon(Icons.close, color: R.color.textDark),
                      onPressed: () {
                        Navigator.pop(context);
                      })),
              Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: R.color.grayComponentBorder)),
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: CupertinoTextField(
                                    textInputAction: TextInputAction.search,
                                    autofocus: true,
                                    controller: controller,
                                    placeholder: R.string.tim_kiem_mon_an.tr(),
                                    decoration: BoxDecoration(border: null),
                                    onSubmitted: (value) {
                                      refresh();
                                    },
                                    onChanged: (value) {
                                      _debouncer.run(() { refresh(); });
                                    })),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(R.drawable.ic_clear,
                                  width: 35, height: 35),
                            )
                          ],
                        ),
                      )),
                ),
              ),
              BlocProvider<FoodBloc>(
                  create: (context) => FoodBloc(),
                  child: BlocBuilder<FoodBloc, FoodState>(
                      builder: (BuildContext context, FoodState state) {
                    currentContext = context;
                    List<FoodModel>? model;
                    if (state is FoodInitial) {
                      BlocProvider.of<FoodBloc>(currentContext).add(
                          FetchSearchFood(keyword: controller.text, page: 1));
                    }
                    if (state is FoodError) {
                      Message.showToastMessage(context, state.message);
                    }
                    if (state is FoodSearchLoaded) {
                      model = state.searchModel!.foods;
                      hasMore = state.searchModel!.hasMore;
                      if (hasMore!) {
                        page += 1;
                      }
                      isLoading = false;
                    }

                    return model == null
                        ? Center(child: CircularProgressIndicator())
                        : Expanded(
                            child: RefreshIndicator(
                                onRefresh: refresh,
                                child: LoadMore(
                                    onLoadMore: _loadMore,
                                    isFinish: !hasMore!,
                                    whenEmptyLoad: false,
                                    delegate: CustomLoadMoreDelegate(),
                                    textBuilder:
                                        DefaultLoadMoreTextBuilder.english,
                                    child: ListView.separated(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
                                        itemCount: model.length == 0
                                            ? 1
                                            : model.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                              height: 1,
                                              color: R.color.color0xffE5E5E5);
                                        },
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (model!.length == 0) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 64,
                                                  right: 64,
                                                  top: 100),
                                              child: Image.asset(
                                                  R.drawable.img_near_food_empty),
                                            );
                                          } else {
                                            final selectedIndex = selectedFoods
                                                .lastIndexWhere((element) =>
                                                    element.id ==
                                                    model![index].id);
                                            final FoodModel? selectedModel =
                                                selectedIndex != -1
                                                    ? selectedFoods[
                                                        selectedIndex]
                                                    : null;
                                            return FoodItem(
                                              model: model[index],
                                              selectedModel: selectedModel,
                                              index: index,
                                              isSearch: true,
                                              callback: (model, index) {
                                                likeFood(model, index);
                                              },
                                              kcalLeft: getKcalLeft(selectedModel),
                                            );
                                          }
                                        }))),
                          );
                  }))
            ]),
          )),
    );
  }
}
