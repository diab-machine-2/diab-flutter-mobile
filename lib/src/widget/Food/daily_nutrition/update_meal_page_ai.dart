import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:medical/src/bloc/food/food_bloc.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/food/food_model.dart';
import 'package:medical/src/repo/food/food_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

import '../search_food_controller.dart';
import '../widget/food_edit_popup.dart';

class UpdateMealPageAI extends StatefulWidget {
  final String updateMealId;

  const UpdateMealPageAI({
    Key? key,
    required this.updateMealId,
  }) : super(key: key);

  @override
  _UpdateMealPageAIState createState() => _UpdateMealPageAIState();
}

class _UpdateMealPageAIState extends State<UpdateMealPageAI> {
  final TextEditingController _controllerNote = TextEditingController();
  final List<FoodModel> _selectedFoods = [];
  List<dynamic> files = [];
  int maxMedia = 5;
  DateTime selectedDate = DateTime.now();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();
  final List<dynamic> _files = [];
  int _currentImageIndex = 0;
  late PageController _pageController;

  /// Displayable carousel items built from:
  /// 1. The main AI captured imageUrl (if isFromAI)
  /// 2. Non-null food thumbnail URLs (manually added foods)
  /// 3. Any additional files (String paths) from notes/images
  List<dynamic> get _carouselItems {
    final items = <dynamic>[];
    // 1. AI-captured meal image
    if (_isFromAI && _mealImageUrl != null && _mealImageUrl!.isNotEmpty) {
      items.add(ImagesModel(id: null, url: _mealImageUrl));
    }
    // 2. Food thumbnail images (manual foods have non-null image.url)
    for (final food in _selectedFoods) {
      if (food.image?.url != null && food.image!.url!.isNotEmpty) {
        final url = food.image!.url!;
        if (!items.any((i) => i is ImagesModel && i.url == url)) {
          items.add(food.image!);
        }
      }
    }
    // 3. Additional raw file paths (e.g. from notes)
    for (final f in _files) {
      if (f is String && f.isNotEmpty) {
        if (!items.contains(f)) {
          items.add(f);
        }
      }
    }
    return items;
  }

  bool get _haveFood => _selectedFoods.isNotEmpty;

  double get totalKcal =>
      _selectedFoods.fold(0, (sum, food) => sum + (food.totalKcal ?? 0));

  bool _isLoading = true;
  bool _isFromAI = false;
  String? _mealImageUrl;
  String timeframe = '';
  String timeframeId = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadData();
  }

  void _loadData() async {
    try {
      final model = await FoodClient().fetchDetailInput(widget.updateMealId);
      if (model != null && mounted) {
        setState(() {
          log("Foods model: ${jsonEncode(model.foods.map((f) => f.toJson()).toList())}");
          _selectedFoods.addAll(model.foods);
          _isFromAI = model.isFromAI ?? false;
          _mealImageUrl = model.imageUrl;
          if (model.date != null) {
            final timezoneOffset = DateTime.now().timeZoneOffset.inSeconds;
            selectedDate = DateTime.fromMillisecondsSinceEpoch(
                (model.date! - timezoneOffset) * 1000);
          }
          _controllerNote.text = model.note ?? '';
          // Populate _files for the notes section (String file paths only)
          for (final img in model.images) {
            if (img.url != null && img.url!.isNotEmpty) {
              _files.add(img.url!);
            }
          }
          timeframe = model.timeFrameName ?? model.mealText ?? '';
          timeframeId = model.timeFrameId ?? model.mealId ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      BotToast.showText(text: e.toString());
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controllerNote.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTapDateTime() async {
    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => DateMultiPicker(
        initDate: selectedDate,
        callback: (date) {
          setState(() {
            selectedDate = date ?? DateTime.now();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: true,
        child: Scaffold(
          backgroundColor: R.color.glucose_bg_color,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              _appBarSection(),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          // Scrollable content
                          Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // Background image section
                                      Container(
                                        height: 298,
                                        child: Stack(
                                          children: [
                                            // Image carousel (from _carouselItems)
                                            if (_carouselItems.isNotEmpty)
                                              Positioned.fill(
                                                child: PageView.builder(
                                                  controller: _pageController,
                                                  onPageChanged: (index) {
                                                    setState(() {
                                                      _currentImageIndex =
                                                          index;
                                                    });
                                                  },
                                                  itemCount:
                                                      _carouselItems.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final item =
                                                        _carouselItems[index];
                                                    return GestureDetector(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/photo_view',
                                                            arguments: {
                                                              'files':
                                                                  _carouselItems,
                                                              'index': index,
                                                            });
                                                      },
                                                      child: (item
                                                              is ImagesModel)
                                                          ? Image.network(
                                                              item.url ?? '',
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Container(
                                                                color: R.color
                                                                    .glucose_bg_color,
                                                              ),
                                                            )
                                                          : (item is String
                                                              ? Image.file(
                                                                  File(item),
                                                                  fit:
                                                                      BoxFit.cover,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Container(
                                                                    color: R.color
                                                                        .glucose_bg_color,
                                                                  ),
                                                                )
                                                              : Container(
                                                                  color: R.color
                                                                      .glucose_bg_color,
                                                                )),
                                                    );
                                                  },
                                                ),
                                              )
                                            else
                                              // Fallback placeholder when no images
                                              Positioned.fill(
                                                child: Container(
                                                  color:
                                                      R.color.glucose_bg_color,
                                                ),
                                              ),
                                            IgnorePointer(
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.black
                                                          .withOpacity(0.3),
                                                      Colors.transparent,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Sticky date time picker overlay
                                            Positioned(
                                              top: 16,
                                              left: 0,
                                              right: 0,
                                              child: Center(
                                                  child:
                                                      _dateTimePickerOverlay()),
                                            ),
                                            // Image counter (1/n) — counts all carousel items in _files
                                            if (_carouselItems.isNotEmpty)
                                              Positioned(
                                                left: 16,
                                                bottom: 86,
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${_currentImageIndex + 1}/${_carouselItems.length}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(0, -70),
                                        child: Column(
                                          children: [
                                            _mealSummarySection(),
                                            const SizedBox(height: 16),
                                            _notesSection(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _buildButton(),
                            ],
                          ),
                          // Sticky date time picker overlay
                          // Positioned(
                          //   top: 16,
                          //   left: 0,
                          //   right: 0,
                          //   child: Center(child: _dateTimePickerOverlay()),
                          // ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        FoodBloc.localizedMealText(timeframeId, timeframe),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.white,
        highlightColor: R.color.white,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      // actions: [
      //   Center(
      //     child: Padding(
      //       padding: const EdgeInsets.only(right: 12.0),
      //       child: InkWell(
      //         onTap: () {
      //           // Show guide or instructions
      //         },
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      //           child: Text(
      //             R.string.huong_dan.tr(),
      //             style: TextStyle(color: R.color.white, fontSize: 15),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  Widget _dateTimePickerOverlay() {
    return GestureDetector(
      onTap: _onTapDateTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: R.color.color0xffDFE4E4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm - dd/MM/yyyy').format(selectedDate),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.textDark,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: R.color.textDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mealSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        children: [
          // Header with total calories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.bua_an_gom.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: R.color.textDark,
                ),
              ),
              Row(
                children: [
                  Text(
                    formatNumber(totalKcal),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: R.color.mainColor,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    R.string.kcal.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.captionColorGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          // Food Items List
          Column(
            children: _selectedFoods
                .asMap()
                .map(
                  (index, food) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () {
                        _showEditFoodPopup(food, index);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: R.color.color0xffF7F8F8,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: R.color.textDark,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '${food.portion?.toStringAsFixed(food.portion! % 1 == 0 ? 0 : 1) ?? "1"} ${food.unit ?? ""}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: R.color.color0xff636A6B,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: R.color.color0xffD6D8E0,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Text(
                                        '${formatNumber((food.totalKcal ?? 0))} ${R.string.kcal.tr()}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: R.color.color0xff636A6B,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Image.asset(
                              R.drawable.ic_food_edit,
                              width: 32,
                              height: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .values
                .toList(),
          ),
          // Add Food Button
          GestureDetector(
            onTap: () {
              _addFood(context);
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: R.color.mainColor,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: R.color.mainColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    R.string.them_mon_an.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: R.color.mainColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _notesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SectionAddNote(
        focusNode: _focusNode,
        controllerNote: _controllerNote,
        maxMedia: 5,
        key: _sectionAddNoteKey,
        initialFiles: _carouselItems,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 12,
        showCameraIcons: false,
        showDeleteIcon: false,
      ),
    );
  }

  Widget _buildButton() {
    return SafeArea(
      top: false,
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showDialogDelete();
                },
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    border: Border.all(color: R.color.red, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      R.string.xoa_du_lieu.tr(),
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _haveFood ? _submitData : null,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _haveFood ? R.color.mainColor : R.color.grayBorder,
                    borderRadius: BorderRadius.circular(200),
                    gradient: _haveFood
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom,
                            ],
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      R.string.save.tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chia sẻ thông tin bữa ăn
  void _shareFood() {
    // Tạo nội dung chia sẻ
    final StringBuffer shareContent = StringBuffer();
    shareContent.writeln('🍽️ Bữa ăn của tôi');
    shareContent
        .writeln('📅 ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDate)}');
    shareContent.writeln('');

    // Thêm thông tin từng món
    for (var food in _selectedFoods) {
      final portion = food.portion ?? 1;
      final unit = food.unit ?? 'phần';
      final calorie = ((food.calorie ?? 0) * portion).round();
      shareContent.writeln('• ${food.name} - $portion $unit ($calorie Kcal)');
    }

    shareContent.writeln('');
    shareContent.writeln('🔥 Tổng: ${totalKcal.round()} Kcal');
    shareContent.writeln('🍚 Carbs: ${_calculateTotalCarbs().round()}g');
    shareContent.writeln('🥩 Protein: ${_calculateTotalProtein().round()}g');
    shareContent.writeln('🧈 Fat: ${_calculateTotalFat().round()}g');

    // TODO: Implement share functionality
    // Share.share(shareContent.toString());

    // Tạm thời show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã copy nội dung chia sẻ'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addFood(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return SearchFoodController(
            foods: _selectedFoods,
            callback: (foods) {
              setState(() {
                _selectedFoods.clear();
                _selectedFoods.addAll(foods);
              });
            },
          );
        },
      ),
    );
  }

  /// Hiển thị popup chỉnh sửa món ăn
  void _showEditFoodPopup(FoodModel food, int index) {
    FoodEditPopup.show(
      context: context,
      food: food,
      index: index,
      onSave: (updatedFood, idx) {
        setState(() {
          _selectedFoods[idx] = updatedFood;
        });
      },
      onDelete: (idx) {
        setState(() {
          _selectedFoods.removeAt(idx);
        });
        // Auto-save or delete meal entirely if no foods are left
        if (_selectedFoods.isEmpty) {
          _deleteMeal();
        } else {
          _submitData(); // Auto-save and exit
        }
      },
    );
  }

  void _deleteMeal() async {
    BotToast.showLoading();
    try {
      final success = await FoodClient().deleteInputFood(widget.updateMealId);
      if (success == true) {
        Navigator.pop(context); // Trở về màn hình trước

        _notifyFoodChange();
      }
      BotToast.closeAllLoading();
    } catch (e) {
      BotToast.closeAllLoading();
      BotToast.showText(text: 'Xoá thất bại: $e');
    }
  }

  void _showDialogDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_earse, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          R.string.ban_muon_xoa_du_lieu.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          R.string.confirm_to_remove_data.tr(),
                          textAlign: TextAlign.center,
                          style: R.style.normalTextStyle,
                        ),
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
                                    borderRadius: BorderRadius.circular(200),
                                    color: R.color.grayBorder,
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.back.tr(),
                                      style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  _deleteMeal();
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: R.color.red,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.delete.tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitData() async {
    BotToast.showLoading();

    try {
      List<String> paths = [];

      // Step 1: Get note data with error handling
      developer.log('[CAPTURE] Starting _submitData (new Nutrition API)',
          name: '[CAPTURE]');

      if (_sectionAddNoteKey.currentState == null) {
        throw Exception('SectionAddNoteState is null. Cannot get note data.');
      }

      final data = _sectionAddNoteKey.currentState!.getNote();
      developer.log(
          '[CAPTURE] Got note data, files count: ${data.files.length}',
          name: '[CAPTURE]');

      // Step 2: Prepare file paths with detailed error handling
      if (data.files.isNotEmpty) {
        for (var file in data.files) {
          try {
            if (file is String) {
              if (file.isNotEmpty) {
                paths.add(file);
              }
            } else if (file is File) {
              if (await file.exists()) {
                paths.add(file.path);
              } else {
                developer.log(
                    '[CAPTURE] WARNING: File does not exist: ${file.path}',
                    name: '[CAPTURE]');
              }
            } else {
              developer.log(
                  '[CAPTURE] WARNING: Unknown file type: ${file.runtimeType}',
                  name: '[CAPTURE]');
            }
          } catch (e) {
            developer.log('[CAPTURE] Error processing file: $e',
                name: '[CAPTURE]');
          }
        }
      }

      developer.log(
          '[CAPTURE] Prepared paths count: ${paths.length}, paths: ${paths.join(", ")}',
          name: '[CAPTURE]');

      // Step 3: Validate file existence (chỉ khi có ảnh)
      if (paths.isNotEmpty) {
        for (String path in paths) {
          if (path.isNotEmpty) {
            final file = File(path);
            if (!await file.exists()) {
              developer.log('[CAPTURE] ERROR: File does not exist: $path',
                  name: '[CAPTURE]');
              throw Exception(
                  'Image file not found: $path. Please select images again.');
            }
          }
        }
      }

      final note = data.note;
      developer.log(
          '[CAPTURE] Calling update API with note: ${note}, foods: ${_selectedFoods.length}, paths: ${paths.length}',
          name: '[CAPTURE]');

      final client = FoodClient();
      List<String?> removeIDs =
          []; // Thêm tính năng lưu danh sách ảnh xoá cần thiết

      // Swap portion and quantity to match the API expectation (like in DailyNutritionCubit editData)
      final List<FoodModel> swappedFoods = _selectedFoods.map((food) {
        return food.copyWith(
          portion: food.quantity,
          quantity: food.portion,
        );
      }).toList();

      final result = await client.updateIndexFood(
          widget.updateMealId,
          selectedDate.millisecondsSinceEpoch ~/ 1000,
          timeframeId,
          _controllerNote.text,
          swappedFoods,
          removeIDs,
          paths);

      developer.log('[CAPTURE] updateIndexFood result: $result',
          name: '[CAPTURE]');

      if (result == true) {
        // Clean up temporary files
        if (paths.isNotEmpty) {
          await _cleanupTempFiles(paths);
        }

        // Go back then notify list to refresh
        BotToast.showText(text: 'Cập nhật thành công!');
        Navigator.pop(context);

        _notifyFoodChange();
      }
      print("[KPI] close all loading.");
      BotToast.closeAllLoading();
    } catch (e, stackTrace) {
      BotToast.closeAllLoading();
      developer.log(
          '[CAPTURE] ERROR in _submitData: $e\nStack trace: $stackTrace',
          name: '[CAPTURE]',
          error: e,
          stackTrace: stackTrace);

      String errorMessage;
      if (e is Error) {
        errorMessage = e.message ?? e.toString();
      } else if (e is Exception) {
        errorMessage = e.toString();
      } else {
        errorMessage = e.toString();
      }

      Message.showToastMessage(context, errorMessage);
    }
  }

  void _notifyFoodChange() {
    Observable.instance.notifyObservers([], notifyName: "food_change_data");
  }

  /// Clean up temporary files created on iOS (files in system temp directory)
  /// This prevents disk space issues from accumulating temp files
  Future<void> _cleanupTempFiles(List<String> paths) async {
    try {
      final tempDir = Directory.systemTemp;
      final tempDirPath = tempDir.path;

      for (String path in paths) {
        try {
          final file = File(path);
          // Only delete if it's in the temp directory (iOS copied files)
          if (path.startsWith(tempDirPath) && await file.exists()) {
            await file.delete();
            developer.log('[CAPTURE] Cleaned up temp file: $path',
                name: '[CAPTURE]');
          }
        } catch (e) {
          // Ignore errors during cleanup - file might already be deleted
          developer.log('[CAPTURE] Error cleaning up temp file $path: $e',
              name: '[CAPTURE]');
        }
      }
    } catch (e) {
      developer.log('[CAPTURE] Error in cleanup process: $e',
          name: '[CAPTURE]');
    }
  }

  double _calculateTotalCarbs() {
    double total = 0;
    _selectedFoods.forEach((element) {
      total += (element.glucose ?? 0) * (element.portion ?? 0);
    });
    return total;
  }

  double _calculateTotalProtein() {
    double total = 0;
    _selectedFoods.forEach((element) {
      total += (element.protein ?? 0) * (element.portion ?? 0);
    });
    return total;
  }

  double _calculateTotalFat() {
    double total = 0;
    _selectedFoods.forEach((element) {
      total += (element.lipid ?? 0) * (element.portion ?? 0);
    });
    return total;
  }

  void _showDialogSave() {
    final note = _controllerNote.text;

    if (note.isEmpty && _selectedFoods.isEmpty && files.isEmpty) {
      Navigator.pop(context);
      Navigator.pushNamed(context, NavigatorName.food_image_capture,
          arguments: {
            'timeframe': timeframe,
            'timeframeId': timeframeId,
          });
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Stack(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(R.drawable.ic_back_icon, width: 64, height: 64),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.ban_muon_quay_lai.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        R.string.confirm_to_back.tr(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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
                                borderRadius: BorderRadius.circular(200),
                                color: R.color.grayBorder,
                              ),
                              child: Center(
                                child: Text(
                                  R.string.van_o_lai.tr(),
                                  style: TextStyle(
                                    color: R.color.textDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Close confirm_gen_food
                              // Navigate back to food image capture screen
                              Navigator.pushNamed(
                                  context, NavigatorName.food_image_capture,
                                  arguments: {
                                    'timeframe': timeframe,
                                    'timeframeId': timeframeId,
                                  });
                            },
                            child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    R.color.greenGradientTop,
                                    R.color.greenGradientBottom,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  R.string.exit.tr(),
                                  style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.close, color: Color(0xffBEC0C8)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

typedef TimeCallback = Function(DateTime?);

class DateMultiPicker extends StatefulWidget {
  final DateTime? initDate;
  final TimeCallback? callback;
  DateMultiPicker({this.initDate, this.callback});
  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime? selectedDate;
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  final GlobalKey<CustomTimePickerState> _calendarDatePickerKey =
      GlobalKey<CustomTimePickerState>();

  @override
  void initState() {
    super.initState();
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedHour = widget.initDate!.hour;
      selectedMinute = widget.initDate!.minute;
    } else {
      selectedDate = DateTime.now();
      selectedHour = DateTime.now().hour;
      selectedMinute = DateTime.now().minute;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(R.string.pick_date.tr(),
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                                icon: Icon(Icons.close,
                                    color: R.color.color0xffBEC0C8),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                          ]),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.initDate == null
                            ? DateTime.now()
                            : widget.initDate!.isAfter(DateTime.now())
                                ? DateTime.now()
                                : widget.initDate!,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (datetime) {
                          selectedDate = datetime ?? DateTime.now();
                          if (_calendarDatePickerKey.currentState != null) {
                            _calendarDatePickerKey.currentState!
                                .setSelectedDate(selectedDate!);
                          }
                        }),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text(R.string.pick_time.tr(),
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomTimePicker(
                        key: _calendarDatePickerKey,
                        initSelectedDate: selectedDate,
                        selectedHour: selectedHour,
                        selectedMinute: selectedMinute,
                        callback: (hour, minute) {
                          selectedHour = hour ?? DateTime.now().hour;
                          selectedMinute = minute ?? DateTime.now().minute;
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 43,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(21.5),
                              border: Border.all(
                                  color: R.color.greenGradientBottom),
                            ),
                            child: Center(
                              child: Text(R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.greenGradientBottom,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            selectedDate = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedHour,
                                selectedMinute);

                            widget.callback!(selectedDate);

                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.greenGradientBottom,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text(R.string.yes.tr(),
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                    ]),
                    SizedBox(height: 16)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef TimeHourCallback = Function(int?, int?);

class CustomTimePicker extends StatefulWidget {
  final int? selectedHour;
  final int? selectedMinute;
  final TimeHourCallback? callback;
  final DateTime? initSelectedDate;
  CustomTimePicker(
      {Key? key,
      this.selectedHour,
      this.selectedMinute,
      this.callback,
      this.initSelectedDate})
      : super(key: key);
  @override
  CustomTimePickerState createState() => CustomTimePickerState();
}

class CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int? selectedHour = 1;
  int? selectedMinute = 1;
  DateTime now = DateTime.now();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initSelectedDate;
    selectedHour = now.hour;
    selectedMinute = now.minute;
    if (widget.selectedHour != null) {
      selectedHour = widget.selectedHour;
    }
    if (widget.selectedMinute != null) {
      selectedMinute = widget.selectedMinute;
    }
    hourController = FixedExtentScrollController(initialItem: selectedHour!);
    minuteController =
        FixedExtentScrollController(initialItem: selectedMinute!);
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    if (_isTimeInFuture(selectedHour!, selectedMinute!)) {
      selectedHour = now.hour;
      selectedMinute = now.minute;
      hourController!.jumpToItem(selectedHour!);
      minuteController!.jumpToItem(selectedMinute!);
    }
    setState(() {});
  }

  // Check if a time is in the future
  bool _isTimeInFuture(int hour, int minute) {
    final now = DateTime.now();
    if (selectedDate != null &&
        selectedDate!.isBefore(DateTime(now.year, now.month, now.day))) {
      return false;
    }
    return now.hour < hour || (now.hour == hour && now.minute < minute);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    // Prevent selecting future hours on current date
                    if (_isTimeInFuture(value, selectedMinute ?? 0)) {
                      // Reset to current hour and minute
                      selectedHour = now.hour;
                      selectedMinute = now.minute;
                      hourController!.jumpToItem(selectedHour!);
                      minuteController!.jumpToItem(selectedMinute!);
                    } else {
                      selectedHour = value;
                      widget.callback!(selectedHour, selectedMinute);
                    }
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(24, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedHour == e
                                      ? R.color.greenGradientBottom
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList())),
        SizedBox(width: 24),
        Container(
            height: 150,
            width: 106,
            child: CupertinoPicker(
                scrollController: minuteController,
                selectionOverlay: null,
                onSelectedItemChanged: (value) {
                  setState(() {
                    // Prevent selecting future minutes in the current hour
                    if (_isTimeInFuture(selectedHour ?? 0, value)) {
                      // Reset to current minute
                      selectedMinute = now.minute;
                      minuteController!.jumpToItem(selectedMinute!);
                    } else {
                      selectedMinute = value;
                      widget.callback!(selectedHour, selectedMinute);
                    }
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(60, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedMinute == e
                                      ? R.color.greenGradientBottom
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList()))
      ],
    );
  }
}
