import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

typedef FoodItemCallback = Function(FoodModel, int);
typedef FoodSelectionCallback = Function(FoodModel, bool); // food, isSelected

class FoodItem extends StatelessWidget {
  const FoodItem({
    required this.model,
    required this.selectedModel,
    required this.index,
    this.isSearch = false,
    this.isCategory = false,
    this.categoryId,
    required this.callback,
    required this.kcalLeft,
    this.onSelectionChanged, // Optional: for local selection handling (e.g., search mode)
  });

  final FoodModel model;
  final FoodModel? selectedModel;
  final int index;
  final bool isSearch;
  final bool isCategory;
  final String? categoryId;
  final FoodItemCallback callback;
  final double? kcalLeft;
  final FoodSelectionCallback? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    // Build subtitle: portion info + kcal
    final String portionText = _buildPortionText();
    final bool isSelected = selectedModel != null;

    return GestureDetector(
      onTap: () {
        if (isCategory) {
          Navigator.pop(context);
        }

        // Use local callback if provided (e.g., search mode), otherwise use observer
        if (onSelectionChanged != null) {
          onSelectionChanged!(model, !isSelected);
        } else if (isSelected) {
          _removeFoodDirectly();
        } else {
          _addFoodDirectly();
        }
      },
      child: Container(
          decoration: BoxDecoration(
              color: (isSelected && !isSearch)
                  ? R.color.color0xFFC3E8D3
                  : R.color.transparent,
              border: Border.all(
                  color: (isSelected && !isSearch)
                      ? R.color.color0xff72CB9C
                      : (isSearch ? R.color.transparent : R.color.transparent))),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(children: [
            // Food image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: NetWorkImageWidget(
                  imageUrl: model.image == null ? '' : model.image!.url ?? '',
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            SizedBox(width: 12),
            // Name + portion/kcal info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.name ?? '',
                      style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 2),
                  // Subtitle: portion · kcal
                  Text(
                    portionText,
                    style: TextStyle(
                      color: R.color.color0xff636A6B,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // If selected, show selected portion info
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                          _buildSelectedText(),
                          style: TextStyle(
                              color: R.color.mainColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
            SizedBox(width: 8),
            // Checkbox or Heart icon
            isSearch 
              ? GestureDetector(
                  onTap: () {
                    if (onSelectionChanged != null) {
                      onSelectionChanged!(model, !isSelected);
                    }
                  },
                  child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? R.color.greenGradientBottom : R.color.grayBorder, 
                          width: 1.5
                        ),
                        color: isSelected ? R.color.greenGradientBottom : R.color.transparent,
                      ),
                      child: isSelected ? Icon(Icons.check, color: R.color.white, size: 18) : null,
                    ),
                )
              : GestureDetector(
                  onTap: () {
                    final newModel = model.copyWith(
                      mealId: selectedModel?.mealId,
                      liked: !(model.liked ?? true),
                    );
                    callback(newModel, index);
                    likeFood(context);
                  },
                  child: Image.asset(
                      model.liked == true
                          ? R.drawable.ic_heart_fill
                          : R.drawable.ic_heart_line,
                      width: 24,
                      height: 24),
                )
          ])),
    );
  }

  /// Build portion text like "1 Tô · 200.5 kcals"
  String _buildPortionText() {
    final parts = <String>[];

    // Portion + unit (e.g. "1 Tô")
    final double qty = model.quantity ?? 1;
    final String unit = model.unit ?? '';
    if (unit.isNotEmpty) {
      parts.add('${qty == qty.roundToDouble() ? qty.round().toString() : formatNumber(qty)} $unit');
    }

    // Calories per unit
    final double cal = model.calorie ?? 0;
    if (cal > 0) {
      parts.add('${formatNumber(cal)} kcals');
    }

    return parts.join(' · ');
  }

  /// Build selected portion text
  String _buildSelectedText() {
    if (selectedModel == null) return '';
    if (selectedModel!.code == 'OtherUneditable') {
      return '${R.string.da_an.tr()} ${formatNumber((selectedModel?.quantity ?? 0) * (selectedModel?.calorie ?? 0))} kcal';
    }
    return '${R.string.da_an.tr()} ${roundAsFixed((selectedModel?.portion ?? 0) * (selectedModel?.quantity ?? 0))} ${selectedModel?.unit ?? ''}, ${((selectedModel?.portion ?? 0) * (selectedModel?.calorie ?? 0)).round()} kcal';
  }

  void _addFoodDirectly() {
    Observable.instance.notifyObservers([],
        notifyName: "add_food_to_cart",
        map: {
          "food": model.copyWith(
            portion: 1,
            quantity: model.quantity ?? 1,
            mealId: selectedModel?.mealId ?? model.mealId,
          ),
        });
  }

  void _removeFoodDirectly() {
    Observable.instance.notifyObservers([],
        notifyName: "remove_food_from_cart",
        map: {
          "food": selectedModel ?? model,
        });
  }

  likeFood(BuildContext context) async {
    BotToast.showLoading();
    try {
      if (!model.liked!) {
        await FoodClient().addFoodToFavorite(model.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(model.id);
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
