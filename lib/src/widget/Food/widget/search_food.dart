import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loadmore/loadmore.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/components/load_more.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class SearchFood extends StatefulWidget {
  final List<FoodModel> foods;
  SearchFood({@required this.foods});
  @override
  _SearchFoodState createState() => _SearchFoodState();
}

class _SearchFoodState extends State<SearchFood> {
  BuildContext currentContext;

  TextEditingController controller = TextEditingController();

  List<FoodModel> selectedFoods = [];

  int page = 1;
  bool hasMore = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller.text = '';
    selectedFoods = [...widget.foods];
    // DartNotificationCenter.subscribe(
    //     channel: 'add_food_to_favorite',
    //     observer: this,
    //     onNotification: (_) {
    //       refresh();
    //     });

    DartNotificationCenter.subscribe(
        channel: 'add_food_to_cart',
        observer: this,
        onNotification: (food) {
          setState(() {
            this.selectedFoods.add(food);
          });
        });
  }

  @override
  void dispose() {
    // DartNotificationCenter.unsubscribe(
    //     channel: 'add_food_to_favorite', observer: this);
    DartNotificationCenter.unsubscribe(
        channel: 'add_food_to_cart', observer: this);
    super.dispose();
  }

  Future<bool> _loadMore() async {
    if (isLoading || !hasMore) {
      return true;
    } else {
      isLoading = true;
      BlocProvider.of<FoodBloc>(currentContext)
          .add(FetchSearchFood(keyword: controller.text ?? '', page: page));
    }
    return true;
  }

  Future<bool> refresh() async {
    page = 1;
    BlocProvider.of<FoodBloc>(currentContext)
        .add(FetchSearchFood(keyword: controller.text ?? '', page: page));
    return true;
  }

  likeFood(FoodModel model, int index) {
    BlocProvider.of<FoodBloc>(currentContext)
        .add(LikeFood(model: model, index: index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(R.drawable.bg_splash),
                  fit: BoxFit.cover)),
          child: SafeArea(
            top: false,
            child: Column(children: [
              CustomAppBar(
                  title: Text(
                    'Nhập món ăn',
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
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: R.color.grayComponentBorder)),
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: CupertinoTextField(
                                    autofocus: true,
                                    controller: controller,
                                    placeholder: 'Tìm kiếm món ăn',
                                    decoration: BoxDecoration(border: null),
                                    onChanged: (value) {
                                      refresh();
                                      // Future.delayed(
                                      //     Duration(milliseconds: 500), () {
                                      //   refresh();
                                      // });
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
                    List<FoodModel> model;
                    if (state is FoodInitial) {
                      BlocProvider.of<FoodBloc>(currentContext).add(
                          FetchSearchFood(
                              keyword: controller.text ?? '', page: 1));
                    }
                    if (state is FoodError) {
                      Message.showToastMessage(context, state.message);
                    }
                    if (state is FoodSearchLoaded) {
                      model = state.searchModel.foods;
                      hasMore = state.searchModel.hasMore;
                      if (hasMore) {
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
                                    isFinish: !hasMore,
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
                                          if (model.length == 0) {
                                            return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 64,
                                                  right: 64,
                                                  top: 100),
                                              child: Image.asset(
                                                  R.drawable.im_near_food_empty),
                                            );
                                          } else {
                                            final selectedIndex = selectedFoods
                                                .lastIndexWhere((element) =>
                                                    element.id ==
                                                    model[index].id);
                                            return FoodItem(
                                              model: model[index],
                                              selectedModel: selectedIndex != -1
                                                  ? selectedFoods[selectedIndex]
                                                  : null,
                                              index: index,
                                              isSearch: true,
                                              callback: (model, index) {
                                                likeFood(model, index);
                                              },
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
