import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';

import 'food_select_popup.dart';

class FoodItemWidget extends StatelessWidget {
  const FoodItemWidget({
    required this.model,
    required this.onFavorite,
    required this.onConfirm,
    required this.hasSelectQuantity,
  });

  final FoodModel model;
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
            color: R.color.transparent,
            border: Border.all(color: R.color.transparent),
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
              child: Image.network(
                  model.image == null ? '' : model.image!.url ?? '',
                  width: 50,
                  height: 50),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(model.name!,
                    style: TextStyle(
                        color: R.color.black, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onFavorite,
              child: Image.asset(
                  model.liked!
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
        model: model,
        hasSelectQuantity: hasSelectQuantity,
      ),
    );
    if (response.first is bool && response.last is FoodModel) {
      //Check if favorite is toggle
      final bool isFavorite = model.liked ?? false;
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
