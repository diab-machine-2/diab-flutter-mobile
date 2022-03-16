import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/food/food_input_model.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/widget/BloodSugar/add_bloodSugar.dart';
import 'package:medical/src/widget/Food/search_food_controller.dart';
import 'package:medical/src/widget/Food/widget/time_frame_food.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class AddFoodController extends StatefulWidget {
  final String type;
  final String id;
  AddFoodController({required this.type, required this.id});

  @override
  _AddFoodControllerState createState() => _AddFoodControllerState();
}

class _AddFoodControllerState extends BaseState<AddFoodController> {
  TextEditingController _controllerNote = TextEditingController(text: '');
  TextEditingController _controllerKcal = TextEditingController(text: '');
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  TimeFrameModel? selectedTimeFrame;

  FoodInputModel? model;
  List<String> removeIDs = [];

  List<FoodModel> selectedFoods = [];
  double totalKcal = 0;

  ShortGuiModel? des;

  String otherFoodId = '7e8c6d8e-5d34-4c86-b15e-7ffe2e156999';

  bool addTotalCalo = false;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    } else {
      loadTimeFrame();
    }
    loadDescription();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Diet Input');
  }

  void dispose() {
    _controllerNote.dispose();
    super.dispose();
  }

  loadDetail() async {
    BotToast.showLoading();
    model = await FoodClient().fetchDetailInput(widget.id);
    BotToast.closeAllLoading();
    selectedDate = DateTime.fromMillisecondsSinceEpoch((model!.date ?? 0) * 1000);
    _controllerNote.text = model?.note ?? "";
    files.addAll(model?.images ?? []);
    selectedTimeFrame =
        TimeFrameModel(id: model?.mealId, code: '', name: model?.mealText);
    final index =
        model!.foods.indexWhere((element) => element.id == otherFoodId);
    if (index == -1) {
      selectedFoods = model!.foods;
    } else {
      addTotalCalo = true;
      _controllerKcal.text =
          ((model!.foods[index].quantity ?? 0) * (model!.foods[index].calorie ?? 0))
              .round()
              .toString();
    }

    calculatorCalo();
    setState(() {});
  }

  loadTimeFrame() async {
    BotToast.showLoading();
    final timeFrames = await FoodClient()
        .fetchFoodTimeFrame(time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
    BotToast.closeAllLoading();
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(4);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          _showDialogSave();
          return false;
        },
        child: Scaffold(
          backgroundColor: R.color.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                CustomAppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                      widget.type == 'update'
                          ? 'Cập nhật chỉ số dinh dưỡng'
                          : 'Nhập chỉ số dinh dưỡng',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: R.color.textDark)),
                  leadingIcon: IconButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.textDark),
                      onPressed: () {
                        _showDialogSave();
                      }),
                  actions: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isClicked = !isClicked;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: isClicked
                            ? Image.asset(
                                R.drawable.ic_help_circle_active,
                                width: 24,
                                height: 24)
                            : Image.asset(R.drawable.ic_help_circle,
                                width: 24, height: 24),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.all(0),
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, left: 16, right: 16),
                            child: isClicked
                                ? Description(
                                    input: true,
                                    data: des,
                                    titleDetail:
                                        'Chế độ dinh dưỡng bệnh tiểu đường')
                                : SizedBox()),
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, left: 16, right: 16),
                            child: Stack(children: [
                              Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Container(
                                  height: 136,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Color(0xffF4DBBD)),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(width: 16),
                                  Image.asset(
                                      R.drawable.img_food_person,
                                      width: 113,
                                      height: 148),
                                  SizedBox(width: 16),
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Lượng calo bạn đã nạp:'),
                                        SizedBox(height: 8),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(formatNumber(totalKcal),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(width: 4),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 3),
                                              child: Text('kcal'),
                                            ),
                                          ],
                                        )
                                      ])
                                ],
                              )
                            ])),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor:
                                        Color(0xff003F38).withOpacity(0.5),
                                    context: context,
                                    builder: (_) => DateMultiPicker(
                                      initDate: selectedDate,
                                      callback: (date) {
                                        if (date != null)
                                        setState(() {
                                          selectedDate = date;
                                        });
                                        loadTimeFrame();
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                              R.drawable.ic_calendar,
                                              width: 24,
                                              height: 24),
                                          SizedBox(width: 8),
                                          Text(
                                              convertToUTC(
                                                  selectedDate
                                                          .millisecondsSinceEpoch ~/
                                                      1000,
                                                  'HH:mm - dd/MM/yyyy'),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1, color: Color(0xffE5E5E5)),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showActionFilter(context);
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                              R.drawable.ic_clock,
                                              width: 24,
                                              height: 24),
                                          SizedBox(width: 8),
                                          Text(
                                              selectedTimeFrame == null
                                                  ? 'Chọn khung giờ'
                                                  : selectedTimeFrame?.name ?? "",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1, color: Color(0xffE5E5E5)),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Row(children: [
                            CupertinoSwitch(
                              activeColor: Color(0xff008479),
                              value: addTotalCalo,
                              onChanged: (value) {
                                setState(() {
                                  totalKcal = 0;
                                  selectedFoods = [];
                                  _controllerKcal.text = '';
                                  addTotalCalo = value;
                                });
                              },
                            ),
                            SizedBox(width: 8),
                            Text('Nhập tổng calo',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))
                          ]),
                        ),
                        addTotalCalo
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 16, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(children: [
                                    GestureDetector(
                                      onTap: () {
                                        addFood(context);
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Column(children: [
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Image.asset(
                                                    R.drawable.ic_bowl,
                                                    width: 24,
                                                    height: 24),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      R.drawable.ic_circle_plus_exe,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text('Thêm món ăn',
                                                        style: TextStyle(
                                                            color: R.color.mainColor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ],
                                                ),
                                              ]),
                                          SizedBox(height: 16),
                                          Container(
                                              height: 1,
                                              color: Color(0xffE5E5E5)),
                                          ListView.separated(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              padding: EdgeInsets.all(0),
                                              itemCount: selectedFoods.length,
                                              separatorBuilder:
                                                  (context, index) {
                                                return Container(
                                                    height: 1,
                                                    color: Color(0xffD6D8E0));
                                              },
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Container(
                                                  color: Colors.transparent,
                                                  padding: EdgeInsets.only(
                                                      bottom: 12, top: 12),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width: 50,
                                                              height: 50,
                                                              child:
                                                                  NetWorkImageWidget(imageUrl: 
                                                                selectedFoods[
                                                                            index]
                                                                        .image!
                                                                        .url ??
                                                                    '',
                                                                width: 50,
                                                                height: 50,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                      selectedFoods[
                                                                              index]
                                                                          .name ?? "",
                                                                      style: TextStyle(
                                                                          color:
                                                                          R.color.textDark,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w700)),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                      selectedFoods[index]
                                                                                  .code ==
                                                                              'OtherUneditable'
                                                                          ? 'Đã ăn ${formatNumber((selectedFoods[index].quantity ?? 0) * (selectedFoods[index].calorie ?? 0))} kcal'
                                                                          : 'Đã ăn ${roundAsFixed((selectedFoods[index].portion ?? 0) * (selectedFoods[index].quantity ?? 0))} ${selectedFoods[index].unit}, ${formatNumber((selectedFoods[index].quantity ?? 0) * (selectedFoods[index].calorie ?? 0))} kcal',
                                                                      style: TextStyle(
                                                                          color:
                                                                          R.color.textDark,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.w400))
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            selectedFoods
                                                                .removeAt(
                                                                    index);
                                                            calculatorCalo();
                                                          });
                                                        },
                                                        child: Image.asset(
                                                          R.drawable.ic_trash,
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                        ]),
                                      ),
                                    )
                                  ]),
                                ),
                              ),
                        !addTotalCalo
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 16, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  // color: Colors.white,
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Lượng calo bạn đã nạp',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: 24),
                                        TextField(
                                            controller: _controllerKcal,
                                            //textAlign: TextAlign.center,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.deny(
                                                  RegExp(r'[-.]'))
                                            ],
                                            enableInteractiveSelection: false,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Nhập lượng calo bạn đã nạp',
                                                contentPadding:
                                                    EdgeInsets.only(bottom: 8),
                                                border: InputBorder.none,
                                                counterText: '',
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xff666666))),
                                            onChanged: (value) {
                                              setState(() {
                                                calculatorCalo();
                                              });
                                            }),
                                        Container(
                                            height: 1,
                                            color: Color(0xffE5E5E5)),
                                      ]),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            // color: Colors.white,
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.ic_note_text,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text('Ghi chú',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600))
                                  ]),
                                  SizedBox(height: 24),
                                  TextField(
                                      controller: _controllerNote,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          hintText: 'Nhập ghi chú của bạn',
                                          contentPadding:
                                              EdgeInsets.only(bottom: 8),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xff666666)))),
                                  Container(
                                      height: 1, color: Color(0xffE5E5E5)),
                                  SizedBox(height: 8),
                                  GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: files.length + 1,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              if (index == files.length) {
                                                showActionSheet(context);
                                              }
                                            },
                                            child: index == files.length
                                                ? Container(
                                                    child: Image.asset(
                                                      R.drawable.ic_add_photo))
                                                : GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/photo_view',
                                                          arguments: {
                                                            'files': files,
                                                            'index': index
                                                          });
                                                    },
                                                    child: Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topEnd,
                                                        children: [
                                                          Positioned.fill(
                                                            child: files[index]
                                                                    is PickedFile
                                                                ? Image.file(
                                                                    File(files[
                                                                            index]
                                                                        .path),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : NetWorkImageWidget(imageUrl: 
                                                                    files[index]
                                                                        .url,
                                                                    fit: BoxFit
                                                                        .cover),
                                                          ),
                                                          IconButton(
                                                              icon: Image.asset(R.drawable.ic_trash
                                                                  ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (files[
                                                                          index]
                                                                      is PickedFile) {
                                                                    files.removeAt(
                                                                        index);
                                                                  } else {
                                                                    removeIDs.add(
                                                                        files[index]
                                                                            .id);
                                                                    files.removeAt(
                                                                        index);
                                                                  }
                                                                });
                                                              })
                                                        ]),
                                                  ));
                                      })
                                ]),
                          ),
                        ),
                      ]),
                ),
                widget.type == 'input'
                    ? GestureDetector(
                        onTap: () async {
                          _submitData();
                        },
                        child: SafeArea(
                          top: false,
                          child: Container(
                              height: 48,
                              width: 195,
                              margin: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(200),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        R.color.greenGradientTop,
                                        R.color.greenGradientBottom
                                      ])),
                              child: Center(
                                  child: Text('Lưu',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)))),
                        ),
                      )
                    : SafeArea(
                        top: false,
                        child: Container(
                            margin: EdgeInsets.all(16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showDialogDelete(context);
                                    },
                                    child: Container(
                                        height: 48,
                                        width: 164,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            border: Border.all(
                                                color: R.color.red, width: 2)),
                                        child: Center(
                                          child: Text('Xoá dữ liệu',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      editData();
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          color: R.color.mainColor,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                R.color.greenGradientTop,
                                                R.color.greenGradientBottom
                                              ])),
                                      child: Center(
                                        child: Text('Lưu',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ])),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  addFood(BuildContext context) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (context) {
              return SearchFoodController(
                foods: selectedFoods,
                callback: (foods) {
                  setState(() {
                    selectedFoods = foods;
                    calculatorCalo();
                  });
                },
              );
            }));
  }

  calculatorCalo() {
    if (addTotalCalo) {
      totalKcal = double.tryParse(_controllerKcal.text) ?? 0;
    } else {
      totalKcal = 0;
      selectedFoods.forEach((element) {
        totalKcal += (element.calorie ?? 0) * (element.quantity ?? 0);
      });
    }
  }

  deleteData() async {
    try {
      BotToast.showLoading();
      final result = await FoodClient().deleteInputFood(widget.id);
      if (result == true) {
        Message.showToastMessage(context, 'Xoá thành công');
        Observable.instance.notifyObservers([], notifyName : "food_change_data");
        // DartNotificationCenter.post(channel: 'food_change_data');
        Navigator.pop(context);
      }

      BotToast.closeAllLoading();
      // if(result.)
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  editData() async {
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text;

    if (selectedDate == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian');
      return;
    }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn khung giờ');
      return;
    }
    if (addTotalCalo) {
      if (_controllerKcal.text.isEmpty) {
        Message.showToastMessage(context, 'Bạn chưa nhập tổng calo');
        return;
      }
      if (totalKcal <= 0) {
        Message.showToastMessage(context, 'Tổng số calo phải lớn hơn 0');
        return;
      }
      if (note.isEmpty) {
        Message.showToastMessage(context, 'Bạn chưa nhập ghi chú');
        return;
      }
    } else {
      if (selectedFoods.length == 0) {
        Message.showToastMessage(context, 'Bạn chưa chọn món ăn');
        return;
      }
    }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final result = await FoodClient().updateIndexFood(
          widget.id,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame?.id,
          note,
          addTotalCalo
              ? [FoodModel(id: otherFoodId, quantity: totalKcal)]
              : selectedFoods,
          removeIDs,
          paths);
      if (result == true) {
        Observable.instance.notifyObservers([], notifyName : "food_change_data");
        // DartNotificationCenter.post(channel: 'food_change_data');
        Navigator.pop(context);
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

  _submitData() async {
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text;

    if (selectedDate == null) {
      Message.showToastMessage(context, 'Bạn chưa nhập thời gian');
      return;
    }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, 'Bạn chưa chọn khung giờ');
      return;
    }
    if (addTotalCalo) {
      if (_controllerKcal.text.isEmpty) {
        Message.showToastMessage(context, 'Bạn chưa nhập tổng calo');
        return;
      }
      if (totalKcal <= 0) {
        Message.showToastMessage(context, 'Tổng số calo phải lớn hơn 0');
        return;
      }
      if (note.isEmpty) {
        Message.showToastMessage(context, 'Bạn chưa nhập ghi chú');
        return;
      }
    } else {
      if (selectedFoods.length == 0) {
        Message.showToastMessage(context, 'Bạn chưa chọn món ăn');
        return;
      }
    }

    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await FoodClient().postIndexFood(
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame?.id,
          note,
          addTotalCalo
              ? [FoodModel(id: otherFoodId, quantity: totalKcal)]
              : selectedFoods,
          paths);
      if (result == true) {
        Observable.instance.notifyObservers([], notifyName : "food_change_data");
        // DartNotificationCenter.post(channel: 'food_change_data');
        Navigator.pop(context);
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

  _showDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_earse,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn xoá dữ liệu?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Các thống kê sẽ thay đổi khi dữ liệu bị xoá, bạn vẫn chắc chắn muốn xoá?',
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Quay lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    deleteData();
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                      color: R.color.red,
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Center(
                                      child: Text('Xoá',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  _showDialogSave() {
    final note = _controllerNote.text;

    if (model != null) {
      final noteText = model?.note ?? '';
      final date = DateTime.fromMillisecondsSinceEpoch((model!.date ?? 0) * 1000);
      if (note == noteText &&
          selectedFoods.length == model!.foods.length &&
          files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty && selectedFoods.length == 0 && files.length == 0) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_back_icon,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text('Bạn muốn quay lại ?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Dữ liệu đang nhập sẽ không được lưu lại, bạn vẫn chắc chắn muốn thoát?',
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Vẫn ở lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ))),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: R.color.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text('Thoát',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                            ),
                          ])
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => FoodTimeFrame(
            selected: selectedTimeFrame,
            callback: (value) {
              print(value);
              setState(() {
                selectedTimeFrame = value;
              });
            }));
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (files.length < maxMedia) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_photo,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text("Chọn trong thư viện",
                      style: TextStyle(color: Color(0xff333333), fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openGallery(context);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text("Chụp ảnh",
                      style: TextStyle(color: Color(0xff333333), fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openCamera(context);
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text("Huỷ",
              style: TextStyle(color: Color(0xff333333), fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      //Message.showToastMessage(context, 'Chỉ đuợc chọn tối đa 5 ảnh');
    }
  }

  _openCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Huỷ"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Cấp quyền"),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Thông báo"),
      content: Text("Bạn cần cấp quyền truy cập để sử dụng tính năng này"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
