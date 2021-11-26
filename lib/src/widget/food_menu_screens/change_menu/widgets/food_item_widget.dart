import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import 'food_select_popup.dart';

class FoodItemWidget extends StatelessWidget {
  const FoodItemWidget({
    required this.preFoodModel,
    required this.newFoodModel,
    required this.isSelected,
    required this.onFavorite,
    required this.onConfirm,
    required this.hasSelectQuantity,
  });

  final FoodModel? preFoodModel;
  final FoodModel newFoodModel;
  final bool isSelected;
  final VoidCallback onFavorite;
  final Function(FoodModel foodModel) onConfirm;
  final bool hasSelectQuantity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showConfirmPopup(context);
      },
      child: Container(
          decoration: BoxDecoration(
            color: isSelected ? R.color.color0xFFC3E8D3 : R.color.transparent,
            border: Border.all(
              color: isSelected ? R.color.color0xff72CB9C : R.color.transparent,
            ),
          ),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 11,
            bottom: 11,
          ),
          child: Row(children: [
            Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              child: NetWorkImageWidget(
                imageUrl: newFoodModel.image == null
                    ? ''
                    : newFoodModel.image!.url ?? '',
                width: 50,
                height: 50,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newFoodModel.name!,
                    style: TextStyle(
                      color: R.color.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${R.string.da_an.tr()} ${roundAsFixed(newFoodModel.portion ?? 0)} ${newFoodModel.unit}, ${formatNumber((newFoodModel.portion ?? 0) * newFoodModel.calorie!)} ${R.string.kcal.tr()}',
                        style: TextStyle(
                          color: R.color.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFavorite,
              child: Image.asset(
                  newFoodModel.liked!
                      ? R.drawable.ic_heart_fill
                      : R.drawable.ic_heart_line,
                  width: 24,
                  height: 24),
            )
          ])),
    );
  }

  showConfirmPopup(BuildContext context) async {
    final List<dynamic> response = await showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => FoodSelectPopup(
        preFoodModel: preFoodModel,
        newFoodModel: newFoodModel,
        hasSelectQuantity: hasSelectQuantity,
      ),
    );
    if (response.first is bool && response.last is FoodModel) {
      //Check if favorite is toggle
      final bool isFavorite = newFoodModel.liked ?? false;
      if (response.last != null &&
          response.last.liked != null &&
          response.last.liked != isFavorite) {
        onFavorite.call();
      }
      //Check if hit confirm
      if (response.first) {
        onConfirm(response.last);
      }
    }
  }
}
