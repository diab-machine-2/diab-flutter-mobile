import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/helper/show_message.dart';

import '../../../modal/food/food_model.dart';

class FoodInfo extends StatefulWidget {
  final FoodModel? model;
//  final MenuResponseListdayfoodTimeGroupsDefaultFood? selectedModel;
  final Function(FoodModel)? callback;
  final double? kcalLeft;

  const FoodInfo(
      {this.model,
    //  this.selectedModel,
      this.callback,
      required this.kcalLeft});

  @override
  _FoodInfoState createState() => _FoodInfoState();
}

class _FoodInfoState extends State<FoodInfo> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _controllerKcal = TextEditingController(text: '');
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int selectedQuantity = 1;
  int selectedPercent = 0;
  bool? isLike = false;

  @override
  void initState() {
    super.initState();
    isLike = widget.model!.liked;
    // if (widget.selectedModel != null) {
    //   selectedQuantity = (widget.selectedModel!.portion ?? 0).floor();
    //   selectedPercent =
    //       (((widget.selectedModel!.portion ?? 0) - selectedQuantity) * 10)
    //           .round();
    //   //selectedPercent = selectedPercent == 0 ? 0 : (selectedPercent + 1);
    //   _controllerKcal.text = (widget.selectedModel!.calorie ?? 0)
    //       .round()
    //       .toString();
    // }
    hourController = FixedExtentScrollController(initialItem: selectedQuantity);
    minuteController =
        FixedExtentScrollController(initialItem: selectedPercent);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];
    if (widget.model!.calorie != null) {
      items.add(buildItem(
          R.string.calo.tr(), widget.model!.calorie, R.string.kcal.tr()));
    }
    if (widget.model!.lipid != null) {
      items.add(buildItem(R.string.beo.tr(), widget.model!.lipid, 'g'));
    }
    if (widget.model!.glucose != null) {
      items.add(buildItem(R.string.duong.tr(), widget.model!.glucose, 'g'));
    }
    if (widget.model!.protein != null) {
      items.add(buildItem(R.string.dam.tr(), widget.model!.protein, 'g'));
    }
    if (widget.model!.fibre != null) {
      items.add(buildItem(R.string.xo.tr(), widget.model!.fibre, 'g'));
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  R.color.color0xffB1DDDB.withAlpha(90),
                                  R.color.color0xFFFED31B.withAlpha(90),
                                ],
                                begin: const FractionalOffset(0.3, -0.5),
                                end: const FractionalOffset(0, 1),
                                stops: const [0.0, 1.0])),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Icon(Icons.arrow_back)),
                                      const SizedBox(width: 12),
                                      Text(widget.model!.name ?? '',
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Visibility(
                                    visible: false,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isLike = !isLike!;
                                        });
                                        likeFood();
                                      },
                                      child: Container(
                                          color: R.color.transparent,
                                          child: !isLike!
                                              ? Image.asset(
                                                  R.drawable.ic_heart_line,
                                                  width: 24,
                                                  height: 24)
                                              : Image.asset(
                                                  R.drawable.ic_heart_fill,
                                                  width: 24,
                                                  height: 24)),
                                    ),
                                  )
                                ],
                              ),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Text(widget.model!.description ?? '',
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                                    const SizedBox(height: 12),
                                    Text(
                                        '${R.string.khau_phan.tr()} ${(widget.model!.portion ?? 0).round()} ${widget.model!.unit} ${R.string.bao_gom.tr()}:',
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400)),
                                    const SizedBox(height: 12),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: items),
                                  ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                            visible: widget.kcalLeft != null,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: RichText(
                                    text: TextSpan(
                                      text:
                                          R.string.food_quantity_recommand.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      children: [
                                        TextSpan(
                                          text:
                                              ' ${recommendedQuantity?.toStringAsFixed(1)} ${widget.model?.unit} ',
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
                            ],
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double? get recommendedQuantity {
    if (widget.kcalLeft != null) {
      return widget.kcalLeft! / (widget.model?.calorie ?? 1);
    }
    return null;
  }

  Widget buildItem(String title, double? number, String unit) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: R.color.primaryGreyColor)),
        const SizedBox(height: 4),
        Text('$number $unit',
            style: TextStyle(
                color: R.color.mainColor, fontWeight: FontWeight.w600))
      ],
    );
  }

  likeFood() async {
    BotToast.showLoading();
    try {
      if (isLike!) {
        await FoodClient().addFoodToFavorite(widget.model!.id);
      } else {
        await FoodClient().romoveFoodFromFavorite(widget.model!.id);
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
