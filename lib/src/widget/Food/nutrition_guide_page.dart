import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

/// Nutrition Guide Page - Hướng dẫn dinh dưỡng
class NutritionGuidePage extends StatelessWidget {
  const NutritionGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.white,
      appBar: AppBar(
        backgroundColor: R.color.greenGradientBottom,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: R.color.white),
        ),
        leadingWidth: 30,
        centerTitle: false,
        title: Text(
          'Hướng dẫn dinh dưỡng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: R.color.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal Scoring Image
            _buildSectionTitle('Bữa ăn của bạn bao nhiêu điểm?'),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                R.drawable.nuti,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // Nutrient Percentage Image
            _buildSectionTitle('% các nhóm chất có ý nghĩa gì?'),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                R.drawable.chat,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 24),

            // Nutrition Distribution Section
            _buildSectionTitle('Phân bổ dinh dưỡng trong 1 bữa ăn'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildNutritionRow('Tinh bột', '1 chén cơm'),
                  const Divider(height: 24),
                  _buildNutritionRow('Chất đạm', '1/2 chén'),
                  const Divider(height: 24),
                  _buildNutritionRow('Chất béo', '1–2 thìa dầu'),
                  const Divider(height: 24),
                  _buildNutritionRow('Rau củ', '1 chén'),
                  const Divider(height: 24),
                  _buildNutritionRow('Hoa quả', '1/2 chén'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Daily Energy Calculation Section
            _buildSectionTitle('Tính nhu cầu năng lượng mỗi ngày'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildGenderCard(
                    gender: 'Nam',
                    formula: 'Cân nặng (kg) × 35 kcal',
                    icon: Icons.male,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderCard(
                    gender: 'Nữ',
                    formula: 'Cân nặng (kg) × 30 kcal',
                    icon: Icons.female,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildWeightAdjustmentCard(
                    label: 'Để giảm cân',
                    value: '300–500',
                    unit: 'kcal/ngày',
                    color: const Color(0xffF5A623),
                    backgroundColor: const Color(0xffFFF9E6),
                    isDecrease: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeightAdjustmentCard(
                    label: 'Để tăng cân',
                    value: '300–500',
                    unit: 'kcal/ngày',
                    color: const Color(0xff008479),
                    backgroundColor: const Color(0xffE8F5F3),
                    isDecrease: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xff1A1A1A),
      ),
    );
  }

  Widget _buildNutritionRow(String nutrient, String portion) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          nutrient,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff1A1A1A),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Color(0xff008479)),
            const SizedBox(width: 8),
            Text(
              portion,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xff666666),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required String gender,
    required String formula,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffE8F5F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xff008479)),
          const SizedBox(height: 8),
          Text(
            gender,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xff1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formula,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xff666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightAdjustmentCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color backgroundColor,
    required bool isDecrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xff1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isDecrease ? Icons.remove : Icons.add,
                size: 20,
                color: color,
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff666666),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
