import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';

/// Popup widget để chỉnh sửa món ăn AI đã phân tích
/// Hiển thị: Tên món ăn, Số lượng, Đơn vị, Nút Xoá và Lưu
class FoodEditPopup extends StatefulWidget {
  final FoodModel food;
  final int index;
  final Function(FoodModel updatedFood, int index) onSave;
  final Function(int index) onDelete;

  const FoodEditPopup({
    Key? key,
    required this.food,
    required this.index,
    required this.onSave,
    required this.onDelete,
  }) : super(key: key);

  /// Hiển thị popup chỉnh sửa món ăn
  static Future<void> show({
    required BuildContext context,
    required FoodModel food,
    required int index,
    required Function(FoodModel updatedFood, int index) onSave,
    required Function(int index) onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodEditPopup(
        food: food,
        index: index,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<FoodEditPopup> createState() => _FoodEditPopupState();
}

class _FoodEditPopupState extends State<FoodEditPopup> {
  late TextEditingController _nameController;
  late double _portion;
  late String _selectedUnit;

  // Danh sách đơn vị có sẵn
  final List<String> _availableUnits = [
    'Bát',
    'Tô',
    'Miếng to',
    'Miếng nhỏ',
    'Chén nhỏ',
    'Tách',
    'Ly',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.food.name ?? '');
    _portion = widget.food.portion ?? 1.0;
    _selectedUnit = widget.food.unit ?? 'Bát';

    // Đảm bảo đơn vị hiện tại nằm trong danh sách
    if (!_availableUnits.contains(_selectedUnit)) {
      _availableUnits.insert(0, _selectedUnit);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _incrementPortion() {
    setState(() {
      _portion = (_portion + 0.5).clamp(0.5, 100);
    });
  }

  void _decrementPortion() {
    setState(() {
      _portion = (_portion - 0.5).clamp(0.5, 100);
    });
  }

  void _onSave() {
    final updatedFood = widget.food.copyWith(
      name: _nameController.text,
      portion: _portion,
      unit: _selectedUnit,
    );
    widget.onSave(updatedFood, widget.index);
    Navigator.pop(context);
  }

  void _onDelete() {
    widget.onDelete(widget.index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle và nút đóng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 40), // Placeholder để căn giữa handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: R.color.grayBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.close, color: R.color.textDark, size: 24),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Tên món ăn
          Text(
            'Tên món ăn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên món ăn',
              hintStyle: TextStyle(
                color: R.color.captionColorGray,
                fontSize: 15,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: R.color.grayBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: R.color.grayBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: R.color.mainColor, width: 1.5),
              ),
            ),
            style: TextStyle(
              fontSize: 15,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 20),

          // Số lượng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Số lượng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark,
                ),
              ),
              Row(
                children: [
                  // Nút giảm
                  GestureDetector(
                    onTap: _decrementPortion,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: R.color.color0xffF7F8F8,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: R.color.grayBorder),
                      ),
                      child: Center(
                        child: Icon(Icons.remove,
                            color: R.color.mainColor, size: 20),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Hiển thị số lượng
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      _portion.toStringAsFixed(_portion % 1 == 0 ? 0 : 1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: R.color.mainColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Nút tăng
                  GestureDetector(
                    onTap: _incrementPortion,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: R.color.color0xffF7F8F8,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: R.color.grayBorder),
                      ),
                      child: Center(
                        child:
                            Icon(Icons.add, color: R.color.mainColor, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          // Đơn vị
          Text(
            'Đơn vị',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableUnits.map((unit) {
              final isSelected = unit == _selectedUnit;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUnit = unit;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? R.color.mainColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected ? R.color.mainColor : R.color.grayBorder,
                    ),
                  ),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : R.color.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 32),

          // Nút Xoá và Lưu
          Row(
            children: [
              // Nút Xoá món ăn
              Expanded(
                child: GestureDetector(
                  onTap: _onDelete,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Color(0xFFEF5350), width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        'Xoá món ăn',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF5350),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Nút Lưu
              Expanded(
                child: GestureDetector(
                  onTap: _onSave,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: R.color.mainColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: R.color.mainColor, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        R.string.save.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
