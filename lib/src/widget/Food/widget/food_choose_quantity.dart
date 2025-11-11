
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class FoodChooseQuantity extends StatefulWidget {
  final FoodModel? model;
  final FoodModel? selectedModel;
  final String? categoryId;
  final Function(FoodModel)? callback;
  final double? kcalLeft;

  const FoodChooseQuantity(
      {this.model,
      this.selectedModel,
      this.categoryId,
      this.callback,
      required this.kcalLeft});

  @override
  _FoodChooseQuantityState createState() => _FoodChooseQuantityState();
}

class _FoodChooseQuantityState extends State<FoodChooseQuantity> {
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
    if (widget.selectedModel != null) {
      selectedQuantity = (widget.selectedModel!.portion ?? 0).floor();
      selectedPercent =
          (((widget.selectedModel!.portion ?? 0) - selectedQuantity) * 10)
              .round();
      //selectedPercent = selectedPercent == 0 ? 0 : (selectedPercent + 1);
      _controllerKcal.text = ((widget.selectedModel!.calorie ?? 0) *
              (widget.selectedModel!.quantity ?? 0))
          .round()
          .toString();
    }
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
                  padding: const EdgeInsets.only(bottom: 16),
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
                                      Text(widget.model!.name!,
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
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
                                  )
                                ],
                              ),
                              if (widget.model!.code == 'OtherUneditable')
                                const SizedBox()
                              else
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
                                )
                            ],
                          ),
                        ),
                      ),
                      if (widget.model?.code == 'OtherUneditable')
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                Text(R.string.kcal_input.tr(),
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 20),
                                TextField(
                                    controller: _controllerKcal,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r'[-.]'))
                                    ],
                                    enableInteractiveSelection: false,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                        hintText: R.string.enter_kcal_hint.tr(),
                                        contentPadding:
                                            const EdgeInsets.only(bottom: 8),
                                        border: InputBorder.none,
                                        counterText: '',
                                        hintStyle: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: R.color.primaryGreyColor))),
                                Container(
                                    height: 1, color: R.color.color0xffE5E5E5),
                                const SizedBox(height: 20),
                              ]),
                        )
                      else
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Visibility(
                                visible: widget.selectedModel != null && widget.kcalLeft != null,
                                child: Padding(
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
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Text(R.string.khau_phan_cua_ban.tr(),
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                              const SizedBox(height: 16),
                              Row(
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
                                              //widget.callback(selectedHour, selectedMinute);
                                            });
                                          },
                                          itemExtent: 47.0,
                                          children:
                                              List<int>.generate(16, (i) => i)
                                                  .map((e) => Center(
                                                        child: Text(
                                                            (e).toString(),
                                                            style: TextStyle(
                                                                color: selectedQuantity ==
                                                                        e
                                                                    ? R.color
                                                                        .mainColor
                                                                    : R.color
                                                                        .color0xffC0C2C5,
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
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
                                              //widget.callback(selectedHour, selectedMinute);
                                            });
                                          },
                                          itemExtent: 47.0,
                                          children:
                                              List<int>.generate(10, (i) => i)
                                                  .map((e) => Center(
                                                        child: Text('$e',
                                                            style: TextStyle(
                                                                color: selectedPercent ==
                                                                        e
                                                                    ? R.color
                                                                        .mainColor
                                                                    : R.color
                                                                        .color0xffC0C2C5,
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ))
                                                  .toList()))
                                ],
                              ),
                            ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                height: 43,
                                decoration: BoxDecoration(
                                    color: R.color.grayBorder,
                                    borderRadius: BorderRadius.circular(21.5)),
                                child: Center(
                                    child: Text(R.string.cancel.tr(),
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)))),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              double quantity =
                                  selectedQuantity + (selectedPercent / 10);
                              if (quantity == 0) {
                                Message.showToastMessage(context,
                                    R.string.ban_chua_nhap_du_lieu.tr());
                                return;
                              }
                              if (_controllerKcal.text.isEmpty &&
                                  widget.model!.code == 'OtherUneditable') {
                                Message.showToastMessage(
                                    context, R.string.ban_chua_nhap_du_lieu.tr());
                                return;
                              }
                              if (widget.model!.code == 'OtherUneditable') {
                                quantity = double.parse(_controllerKcal.text);
                                if (quantity == 0) {
                                  Message.showToastMessage(
                                      context, R.string.invalid_kcal.tr());
                                  return;
                                }
                              }
                              Observable.instance.notifyObservers([],
                                  notifyName: "add_food_to_cart",
                                  map: {
                                    "food": widget.model!.copyWith(
                                      portion: quantity,
                                      quantity: widget.model?.portion ?? 1,
                                      mealId: widget.selectedModel?.mealId ??
                                          widget.model!.mealId,
                                    ),
                                  });
                              Navigator.pop(context);
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
                                    child: Text(R.string.yes.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)))),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ]),
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
