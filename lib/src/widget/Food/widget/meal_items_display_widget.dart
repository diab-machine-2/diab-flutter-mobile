import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/widget/Food/food_result.dto.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class MealItemsDisplayWidget extends StatelessWidget {
  final FoodResultDto data;

  const MealItemsDisplayWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.foods.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        // Header
        Text(
          R.string.bua_an_gom.tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: R.color.textDark,
          ),
        ),
        const SizedBox(height: 16),
        // Top 3 images
        if (data.images.isNotEmpty) _buildImageRow(),
        const SizedBox(height: 16),
        // Food items list
        ...data.foods.map((food) => _buildFoodCard(food)).toList(),
      ],
    );
  }

  Widget _buildImageRow() {
    final displayImages = data.images.take(3).toList();

    return Row(
      children: displayImages.map((image) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: NetWorkImageWidget(
                  imageUrl: image.url ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFoodCard(FoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: NetWorkImageWidget(
              imageUrl: food.imageUrl ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: R.color.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${food.portion ?? 1} ${food.unit ?? 'đĩa'} • ${(food.calorie ?? 0).toInt() * (food.portion ?? 1)} kcals',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: R.color.primaryGreyColor,
                  ),
                ),
              ],
            ),
          ),
          // Heart icon
          Icon(
            Icons.favorite_border,
            color: R.color.primaryGreyColor,
            size: 24,
          ),
        ],
      ),
    );
  }
}
