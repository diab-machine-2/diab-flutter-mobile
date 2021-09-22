import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/Food/widget/food_item.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class NearFood extends StatefulWidget {
  final List<FoodModel> foods;
  NearFood({required this.foods});
  @override
  _NearFoodState createState() => _NearFoodState();
}

class _NearFoodState extends State<NearFood>
    with AutomaticKeepAliveClientMixin<NearFood>, Observer {
  @override
  bool get wantKeepAlive => true;

  late BuildContext currentContext;

  List<FoodModel> selectedFoods = [];

  @override
  void initState() {
    super.initState();
    selectedFoods = [...widget.foods];
    Observable.instance.addObserver(this);
    // DartNotificationCenter.subscribe(
    //     channel: 'add_food_to_cart',
    //     observer: this,
    //     onNotification: (food) {
    //       setState(() {
    //         this.selectedFoods.removeWhere((element) => food.id == element!.id);
    //         this.selectedFoods.add(food);
    //       });
    //     });
    //
    // DartNotificationCenter.subscribe(
    //     channel: 'remove_food_from_cart',
    //     observer: this,
    //     onNotification: (food) {
    //       if (food is FoodModel) {
    //         setState(() {
    //           selectedFoods.removeWhere((element) => element!.id == food.id);
    //         });
    //       }
    //     });
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? food) {
    // TODO: implement update
    var firstValue = food?.values.first;
    if (notifyName == 'add_food_to_cart') {
      if (firstValue is FoodModel) {
        this.selectedFoods.removeWhere((element) => firstValue.id == element.id);
        this.selectedFoods.add(firstValue);
        setState(() {});
      }
    }
    if (notifyName == 'remove_food_from_cart') {
      if (firstValue is FoodModel) {
        selectedFoods.removeWhere((element) => firstValue.id == element.id);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    // DartNotificationCenter.unsubscribe(
    //     channel: 'add_food_to_cart', observer: this);
    // DartNotificationCenter.unsubscribe(
    //     channel: 'remove_food_from_cart', observer: this);
    super.dispose();
  }

  Future<bool> refresh() async {
    BlocProvider.of<FoodBloc>(currentContext).add(FetchFoodLatest(page: 1));
    return true;
  }

  likeFood(FoodModel model, int index) {
    BlocProvider.of<FoodBloc>(currentContext)
        .add(LikeFood(model: model, index: index));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<FoodBloc>(
        create: (context) => FoodBloc(),
        child: BlocBuilder<FoodBloc, FoodState>(
            builder: (BuildContext context, FoodState state) {
          currentContext = context;
          List<FoodModel>? model;
          if (state is FoodInitial) {
            BlocProvider.of<FoodBloc>(context).add(FetchFoodLatest(page: 1));
          }
          if (state is FoodError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is FoodLoaded) {
            model = state.model.foods;
          }
          return model == null
              ? Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView.separated(
                      padding: EdgeInsets.all(0),
                      itemCount: model.length == 0 ? 1 : model.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(height: 1, color: R.color.color0xffE5E5E5);
                      },
                      itemBuilder: (BuildContext context, int index) {
                        if (model!.length == 0) {
                          return Padding(
                            padding:
                                EdgeInsets.only(left: 84, right: 84, top: 100),
                            child: Image.asset(
                                R.drawable.im_near_food_empty),
                          );
                        } else {
                          final selectedIndex = selectedFoods.lastIndexWhere(
                              (element) => element.id == model![index].id);
                          return FoodItem(
                            model: model[index],
                            selectedModel: selectedIndex != -1
                                ? selectedFoods[selectedIndex]
                                : null,
                            index: index,
                            callback: (model, index) {
                              likeFood(model, index);
                            },
                          );
                        }
                      }));
        }));
  }
}
