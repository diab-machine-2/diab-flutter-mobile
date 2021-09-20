import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/Food/search_food_controller.dart';
import 'package:medical/src/widget/Food/widget/food_choose_quantity.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';

typedef FoodItemCallback = Function(FoodModel, int);

class FoodItem extends StatelessWidget {
  FoodItem(
      {@required this.model,
      @required this.selectedModel,
      @required this.index,
      this.isSearch = false,
      this.isCategory = false,
      this.categoryId,
      @required this.callback});

  final FoodModel model;
  final FoodModel selectedModel;
  final int index;
  final bool isSearch;
  final bool isCategory;
  final String categoryId;
  final FoodItemCallback callback;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSearch) {
          Navigator.pop(context);
        }
        if (isCategory) {
          Navigator.pop(context);
        }

        showFoodQuantity(context);
      },
      child: Container(
          decoration: BoxDecoration(
              color: selectedModel != null
                  ? R.color.color0xFFC3E8D3
                  : R.color.transparent,
              border: Border.all(
                  color: selectedModel != null
                      ? R.color.color0xff72CB9C
                      : R.color.transparent)),
          padding: EdgeInsets.only(left: 16, right: 16, top: 11, bottom: 11),
          child: Row(children: [
            Image.network(model.image == null ? '' : model.image.url ?? '',
                width: 50, height: 50),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.name,
                      style: TextStyle(
                          color: R.color.black, fontWeight: FontWeight.w500)),
                  selectedModel == null
                      ? SizedBox()
                      : Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                              'Đã ăn ${roundAsFixed(selectedModel.portion * selectedModel.quantity)} ${selectedModel.unit}, ${formatNumber(selectedModel.quantity * selectedModel.calorie)} kcal',
                              style: TextStyle(
                                  color: R.color.black,
                                  fontWeight: FontWeight.w400)),
                        )
                ],
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final newModel = FoodModel(
                    id: model.id,
                    name: model.name,
                    portion: model.portion,
                    unit: model.unit,
                    calorie: model.calorie,
                    glucose: model.glucose,
                    lipid: model.lipid,
                    protein: model.protein,
                    fibre: model.fibre,
                    image: model.image,
                    liked: !model.liked,
                    text: model.text,
                    description: model.description,
                    foodCategoryId: model.foodCategoryId,
                    quantity: model.quantity);
                callback(newModel, index);
                likeFood(context);
              },
              child: Image.asset(
                  model.liked
                      ? R.drawable.ic_heart_fill
                      : R.drawable.ic_heart_line,
                  width: 24,
                  height: 24),
            )
          ])),
    );
  }

  showFoodQuantity(BuildContext context) {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => FoodChooseQuantity(
          model: model,
          selectedModel: selectedModel,
          categoryId: categoryId,
          callback: (value) {}),
    );
  }

  likeFood(BuildContext context) async {
    BotToast.showLoading();
    try {
      if (!model.liked) {
        await FoodClient().addFoodToFavorite(model.id);
        DartNotificationCenter.post(channel: 'add_food_to_favorite');
      } else {
        await FoodClient().romoveFoodFromFavorite(model.id);
        DartNotificationCenter.post(channel: 'add_food_to_favorite');
      }
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }
}
