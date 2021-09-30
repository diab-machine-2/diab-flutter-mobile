import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/utils/navigation_util.dart';

class FoodSelectPopup extends StatefulWidget {
  const FoodSelectPopup({
    this.model,
    this.onTapYes,
  });

  final FoodModel? model;
  final VoidCallback? onTapYes;

  @override
  State<FoodSelectPopup> createState() => _FoodSelectPopupState();
}

class _FoodSelectPopupState extends State<FoodSelectPopup> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.model?.liked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPop(context);
      },
      child: Scaffold(
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
                                    onPop(context);
                                  },
                                  child: const Icon(Icons.arrow_back)),
                              const SizedBox(width: 12),
                              Text(
                                widget.model?.name ?? '',
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
                          widget.model?.description ?? '',
                          style: TextStyle(
                              color: R.color.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Text(
                          '${R.string.khau_phan.tr()} ${widget.model!.portion.round()} ${widget.model!.unit} ${R.string.bao_gom.tr()}:',
                          style: TextStyle(
                              color: R.color.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.model?.calorie != null)
                            _buildItem(
                              title: R.string.calo.tr(),
                              number: widget.model?.calorie,
                              unit: R.string.kcal.tr(),
                            ),
                          if (widget.model?.lipid != null)
                            _buildItem(
                              title: R.string.beo.tr(),
                              number: widget.model?.lipid,
                              unit: R.string.gram.tr(),
                            ),
                          if (widget.model?.glucose != null)
                            _buildItem(
                              title: R.string.duong.tr(),
                              number: widget.model?.glucose,
                              unit: R.string.gram.tr(),
                            ),
                          if (widget.model?.protein != null)
                            _buildItem(
                              title: R.string.dam.tr(),
                              number: widget.model?.protein,
                              unit: R.string.gram.tr(),
                            ),
                          if (widget.model?.fibre != null)
                            _buildItem(
                              title: R.string.xo.tr(),
                              number: widget.model?.fibre,
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
                              ' ${widget.model?.quantity.round()} ${widget.model?.unit} ',
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
                const SizedBox(height: 16),
                Row(children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onPop(context);
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
                        if (widget.onTapYes != null) {
                          widget.onTapYes!.call();
                        }
                        onPop(context);
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

  void onPop(BuildContext context) {
    NavigationUtil.pop(context, result: isFavorite);
  }
}
