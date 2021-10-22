import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/utils/navigation_util.dart';

class FoodSelectPopup extends StatefulWidget {
  const FoodSelectPopup({
    required this.preFoodModel,
    required this.newFoodModel,
    required this.hasSelectQuantity,
  });

  final FoodModel? preFoodModel;
  final FoodModel? newFoodModel;
  final bool hasSelectQuantity;

  @override
  State<FoodSelectPopup> createState() => _FoodSelectPopupState();
}

class _FoodSelectPopupState extends State<FoodSelectPopup> {
  late bool isFavorite;
  FoodModel? foodModel;
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int selectedQuantity = 1;
  int selectedPercent = 0;

  @override
  void initState() {
    super.initState();
    foodModel = widget.newFoodModel;
    isFavorite = widget.newFoodModel?.liked ?? false;
    if (widget.newFoodModel != null) {
      final double quantity = recommendedQuantity;
      selectedQuantity = quantity.floor();
      selectedPercent =
          ((quantity - selectedQuantity) * 10).round();
    }
    hourController = FixedExtentScrollController(
      initialItem: selectedQuantity,
    );
    minuteController = FixedExtentScrollController(
      initialItem: selectedPercent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: R.color.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        R.color.color0xffB1DDDB.withAlpha(90),
                        R.color.color0xFFFED31B.withAlpha(90),
                      ],
                      begin: const FractionalOffset(0.3, -0.5),
                      end: const FractionalOffset(0, 1),
                      stops: const [0.0, 1.0]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  onPop(context, agree: false);
                                },
                                child: const Icon(Icons.arrow_back)),
                            const SizedBox(width: 12),
                            Text(
                              widget.newFoodModel?.name ?? '',
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            isFavorite = !isFavorite;
                            setState(() {});
                          },
                          child: Container(
                            color: R.color.transparent,
                            child: isFavorite
                                ? Image.asset(R.drawable.ic_heart_fill,
                                    width: 24, height: 24)
                                : Image.asset(R.drawable.ic_heart_line,
                                    width: 24, height: 24),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        widget.newFoodModel?.description ?? '',
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Text(
                        '${R.string.khau_phan.tr()} ${(widget.newFoodModel!.portion ?? 0).round()} ${widget.newFoodModel!.unit} ${R.string.bao_gom.tr()}:',
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (widget.newFoodModel?.calorie != null)
                          _buildItem(
                            title: R.string.calo.tr(),
                            number: widget.newFoodModel?.calorie,
                            unit: R.string.kcal.tr(),
                          ),
                        if (widget.newFoodModel?.lipid != null)
                          _buildItem(
                            title: R.string.beo.tr(),
                            number: widget.newFoodModel?.lipid,
                            unit: R.string.gram.tr(),
                          ),
                        if (widget.newFoodModel?.glucose != null)
                          _buildItem(
                            title: R.string.duong.tr(),
                            number: widget.newFoodModel?.glucose,
                            unit: R.string.gram.tr(),
                          ),
                        if (widget.newFoodModel?.protein != null)
                          _buildItem(
                            title: R.string.dam.tr(),
                            number: widget.newFoodModel?.protein,
                            unit: R.string.gram.tr(),
                          ),
                        if (widget.newFoodModel?.fibre != null)
                          _buildItem(
                            title: R.string.xo.tr(),
                            number: widget.newFoodModel?.fibre,
                            unit: R.string.gram.tr(),
                          ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: RichText(
                  text: TextSpan(
                    text: R.string.food_quantity_recommand.tr(),
                    style: TextStyle(
                        color: R.color.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                        text:
                            ' ${recommendedQuantity.toStringAsFixed(1)} ${widget.newFoodModel?.unit} ',
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: R.string.for_this_food.tr(),
                        style: TextStyle(
                            color: R.color.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: widget.hasSelectQuantity,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          height: 150,
                          width: 106,
                          child: CupertinoPicker(
                              scrollController: hourController,
                              selectionOverlay: null,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedQuantity = value;
                                });
                              },
                              itemExtent: 47.0,
                              children: List<int>.generate(16, (i) => i)
                                  .map((e) => Center(
                                        child: Text((e).toString(),
                                            style: TextStyle(
                                                color: selectedQuantity == e
                                                    ? R.color.mainColor
                                                    : R.color.color0xffC0C2C5,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                  .toList())),
                      const SizedBox(width: 8),
                      Text(',',
                          style: TextStyle(
                              color: R.color.mainColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                          height: 150,
                          width: 106,
                          child: CupertinoPicker(
                              scrollController: minuteController,
                              selectionOverlay: null,
                              onSelectedItemChanged: (value) {
                                setState(() {
                                  selectedPercent = value;
                                });
                              },
                              itemExtent: 47.0,
                              children: List<int>.generate(10, (i) => i)
                                  .map((e) => Center(
                                        child: Text('$e',
                                            style: TextStyle(
                                                color: selectedPercent == e
                                                    ? R.color.mainColor
                                                    : R.color.color0xffC0C2C5,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold)),
                                      ))
                                  .toList()))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onPop(context, agree: false);
                    },
                    child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                          color: R.color.grayBorder,
                          borderRadius: BorderRadius.circular(21.5)),
                      child: Center(
                        child: Text(
                          R.string.cancel.tr(),
                          style: TextStyle(
                              color: R.color.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onPop(context, agree: true);
                    },
                    child: Container(
                      height: 43,
                      decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(21.5),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [
                                R.color.greenGradientTop,
                                R.color.greenGradientBottom
                              ])),
                      child: Center(
                        child: Text(
                          R.string.yes.tr(),
                          style: TextStyle(
                              color: R.color.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem({
    required String title,
    double? number,
    String? unit,
  }) {
    if (number == null) return const SizedBox();
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: R.color.primaryGreyColor),
        ),
        const SizedBox(height: 4),
        Text(
          '$number $unit',
          style: TextStyle(
            color: R.color.mainColor,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  void onPop(BuildContext context, {required bool agree}) {
    foodModel = foodModel?.copyWith(
      liked: isFavorite,
      portion: widget.hasSelectQuantity
          ? selectedQuantity + (selectedPercent / 10)
          : recommendedQuantity.toDouble(),
    );
    NavigationUtil.pop(context, result: [agree, foodModel]);
  }

  double get recommendedQuantity =>
      ((widget.preFoodModel?.calorie ?? 0) *
          (widget.preFoodModel?.portion ?? 0.0)) /
      (widget.newFoodModel?.calorie ?? 1);
}
