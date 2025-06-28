import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class FoodActionPopup extends StatelessWidget {
  final Function()? onDismiss;

  const FoodActionPopup({
    Key? key,
    this.onDismiss,
  }) : super(key: key);

  void _handleItemTap(String timeframeId) {
    // TODO:
  }

  @override
  Widget build(BuildContext context) {
    final List<_FoodPopupItemModel> items = _FoodPopupItemModel.getFoodPopupItems();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          height: 52,
          child: Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: IconButton(
                  onPressed: null,
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Chọn bữa',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Food Action Items List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final int index = entry.key;
              final _FoodPopupItemModel item = entry.value;
              return Column(
                children: [
                  _buildActionItem(context, item),
                  if (index < items.length - 1) const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SafeArea(
          top: false,
          bottom: true,
          child: SizedBox(),
        )
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, _FoodPopupItemModel item) {
    double heightAndIconSize = 80;
    return GestureDetector(
      onTap: () => _handleItemTap(item.timeframeId),
      child: Container(
        height: heightAndIconSize,
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            // Icon container
            Image.asset(
              item.imageAssetPath,
              width: heightAndIconSize,
              height: heightAndIconSize,
            ),

            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: Text(
                item.name,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111515),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Arrow icon
            Image.asset(
              R.drawable.ic_food_plus,
              width: 32,
              height: 32,
            ),

            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  // Static method to show the popup
  static void show(BuildContext context, {Function()? onDismiss}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 480 + MediaQuery.of(context).viewInsets.bottom / 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: FoodActionPopup(onDismiss: onDismiss),
      ),
    );
  }
}

class _FoodPopupItemModel {
  final String imageAssetPath;
  final String name;
  final Color backgroundColor;
  final String timeframeId;

  _FoodPopupItemModel({
    required this.imageAssetPath,
    required this.name,
    required this.backgroundColor,
    required this.timeframeId,
  });

  // Static method to get the list of food popup items
  // TODO:
  static List<_FoodPopupItemModel> getFoodPopupItems() {
    return [
      _FoodPopupItemModel(
        imageAssetPath: R.drawable.im_food_breakfast,
        name: 'Bữa sáng',
        backgroundColor: const Color(0xFFEAFFEC),
        timeframeId: '1',
      ),
      _FoodPopupItemModel(
        imageAssetPath: R.drawable.im_food_lunch,
        name: 'Bữa trưa',
        backgroundColor: const Color(0xFFFEEDDC),
        timeframeId: '2',
      ),
      _FoodPopupItemModel(
        imageAssetPath: R.drawable.im_food_dinner,
        name: 'Bữa tối',
        backgroundColor: const Color(0xFFFFFAEB),
        timeframeId: '3',
      ),
      _FoodPopupItemModel(
        imageAssetPath: R.drawable.im_food_snack,
        name: 'Bữa phụ',
        backgroundColor: const Color(0xFFF1F6FF),
        timeframeId: '4',
      ),
    ];
  }
  
}
