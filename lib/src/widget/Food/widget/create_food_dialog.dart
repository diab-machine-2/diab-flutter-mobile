import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';

/// Popup widget để tạo món ăn mới
/// Hiển thị: Tên món ăn, Số lượng, Đơn vị, Ghi chú và Nút Tạo ra
class CreateFoodDialog extends StatefulWidget {
  const CreateFoodDialog({Key? key}) : super(key: key);

  /// Hiển thị popup tạo món mới
  static Future<FoodModel?> show({
    required BuildContext context,
  }) {
    return showModalBottomSheet<FoodModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateFoodDialog(),
    );
  }

  @override
  State<CreateFoodDialog> createState() => _CreateFoodDialogState();
}

class _CreateFoodDialogState extends State<CreateFoodDialog> {
  late TextEditingController _nameController;
  late TextEditingController _noteController;
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
    _nameController = TextEditingController();
    _noteController = TextEditingController();
    _portion = 1.0;
    _selectedUnit = 'Bát';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
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

  void _onCreate() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng nhập tên món ăn')),
      );
      return;
    }

    // Tạo FoodModel mới
    final newFood = FoodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      portion: _portion,
      unit: _selectedUnit,
      code: 'OtherUneditable',
      calorie: 0,
      quantity: 1,
    );

    Navigator.pop(context, newFood);
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
          SizedBox(height: 10),

          // Title: Tạo món mới
          Text(
            'Tạo món mới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 20),

          // Tên món ăn và Số lượng (cùng hàng)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên món ăn (bên trái)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        hintText: 'Nhập tên món',
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
                          borderSide:
                              BorderSide(color: R.color.mainColor, width: 1.5),
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        color: R.color.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Số lượng (bên phải)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Số lượng',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: R.color.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
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
                      SizedBox(width: 8),
                      // Hiển thị số lượng
                      Container(
                        width: 40,
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
                      SizedBox(width: 8),
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
                            child: Icon(Icons.add,
                                color: R.color.mainColor, size: 20),
                          ),
                        ),
                      ),
                    ],
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
          SizedBox(height: 20),

          // Ghi chú về món ăn
          Text(
            'Ghi chú về món ăn',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Nhập tên món ăn, cách chế biến...',
              hintStyle: TextStyle(
                color: R.color.captionColorGray,
                fontSize: 14,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 8, top: 8),
                child: Icon(Icons.image_outlined,
                    color: R.color.captionColorGray, size: 20),
              ),
              contentPadding: EdgeInsets.all(12),
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
              fontSize: 14,
              color: R.color.textDark,
            ),
          ),
          SizedBox(height: 24),

          // Nút Tiếp tục
          GestureDetector(
            onTap: _onCreate,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: R.color.mainColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: R.color.mainColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  'Tiếp tục',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
