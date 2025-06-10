import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/add_exercise_request.dart';
import 'package:medical/src/model/response/exercise_intensity_response.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_categories.dart';
import 'package:medical/src/widget/Exercrises/exercrises_note_with_media.dart';
import 'package:medical/src/widget/Exercrises/widget/health_connect_button.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/modal/error/error_model.dart';

import '../../modal/exercrises/exercrise_Input_detail_model.dart';
import '../../modal/glucose/glucose_timeFrame.dart';
import 'widget/date_multi_picker.dart';

class ExercrisesAddV2 extends StatefulWidget {
  final bool? isUpdate;
  final String? exerciseInputId;
  final bool? isOnlyOne;
  ExercrisesAddV2({
    Key? key,
    this.isUpdate,
    this.exerciseInputId,
    this.isOnlyOne,
  }) : super(key: key);

  ExercrisesAddV2State createState() => ExercrisesAddV2State();
}

class ExercrisesAddV2State extends State<ExercrisesAddV2>
    with WidgetsBindingObserver, Observer {
  late BuildContext currentContext;
  ScrollController scrollController = ScrollController();
  TextEditingController _controllerDuration = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String note = '';
  List<dynamic> files = [];
  List<String> removeFileIds = [];
  final int maxMedia = 5;
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  DateTime? selectedDate;
  ExercrisesCategoryModel? selectedCategory;
  ExerciseIntensity? intensity;
  InputDetailExercriseModel? model;
  TimeFrameModel? selectedTimeFrame;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedDate = DateTime.now();
    // selectedCategory = [];
    if (widget.isUpdate == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadDetail();
      });
    }
  }

  bool _shouldCalculateCalo() {
    return selectedDate != null &&
        selectedCategory != null &&
        intensity != null &&
        _controllerDuration.text.isNotEmpty &&
        double.tryParse(_controllerDuration.text) != null;
  }

  loadDetail() async {
    BotToast.showLoading();

    try {
      model = await ExercrisesClient().fetchDetail(widget.exerciseInputId);
      if (model != null) {
        selectedDate = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
        selectedCategory =
            model?.exercise != null ? model!.exercise.first : null;
        note = model?.note ?? '';
        selectedTimeFrame = TimeFrameModel(
            id: model!.timeFrameId, code: '', name: model!.timeFrame);
        files = List.from(model!.imageUrls);
        _controllerDuration.text = model?.exercise != null
            ? model!.exercise.first.duration != null
                ? model!.exercise.first.duration!.round().toString()
                : ''
            : '';
        if (model?.exercise != null &&
            model!.exercise.first.exerciseIntensityId != null) {
          final updateIntensity = ExerciseIntensity(
            intensityId: model!.exercise.first.exerciseIntensityId!,
            name: intensity?.name ?? '',
          );
          intensity = updateIntensity;
        }

        setState(() {});
      }
    } catch (e) {
      BotToast.showText(text: 'Error load detail fail: $e');
    } finally {
      BotToast.closeAllLoading();
    }
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'active_change_data_v2') {
      // overViewKey.currentState!.reloadData(periodFilterType);
    }
  }

  @override
  void dispose() {
    _controllerDuration.dispose();
    Observable.instance.removeObserver(this); // Hủy đăng ký observer
    scrollController.dispose(); // Hủy ScrollController nếu có
    super.dispose(); // Gọi super.dispose() để giải phóng tài nguyên
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      BotToast.showText(
        text: 'Opps! You can not go back',
        duration: Duration(seconds: 2),
        backgroundColor: R.color.black,
        textStyle: TextStyle(color: R.color.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: R.color.backgroundColorNew,
          appBar: AppBar(
            leading: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: _goBack),
            title: Transform(
              transform: Matrix4.translationValues(-20, 0.0, 0.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  R.string.title_exercise.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, NavigatorName.exercrise_guide);
                },
                child: Text(
                  R.string.exercrise_step_onboarding_action_btn.tr(),
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
            ],
            backgroundColor: R.color.transparent, //No more green
            elevation: 0.0, //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Color(0xFF0DAB9C),
                    Color(0xFF01847A),
                  ])),
            ),
          ),
          body: _buildContainer(),
          bottomNavigationBar:
              // add animation face in/out (opacity) when keyboard show / hide
              KeyboardVisibilityProvider(
            child: KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: isKeyboardVisible ? 0 : 60,
                    width: double.infinity,
                    child: Container(
                      // height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: R.color.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: widget.isUpdate == true
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: ButtonWidget(
                                    title: R.string.delete.tr(),
                                    backgroundColor: R.color.white,
                                    borderColor: R.color.redAccent,
                                    textColor: R.color.redAccent,
                                    onPressed: () {
                                      _showDialogDelete(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: ButtonWidget(
                                    title: R.string.confirm.tr(),
                                    backgroundColor: R.color.greenGradientMid,
                                    textColor: R.color.white,
                                    onPressed: () {
                                      if (widget.exerciseInputId != null) {
                                        editData();
                                      }
                                    },
                                  ),
                                )
                              ],
                            )
                          : ButtonWidget(
                              title: R.string.confirm.tr(),
                              onPressed: _submitData,
                            ),
                    ));
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer() {
    return SingleChildScrollView(
      controller: scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: R.color.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(16),
              child: Column(children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                      context: context,
                      builder: (_) => DateMultiPicker(
                        initDate: selectedDate,
                        callback: (date) {
                          setState(() {
                            selectedDate = date;
                            if (widget.isUpdate == true) {
                              selectedTimeFrame = null;
                            }
                          });
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        border: Border.all(color: R.color.color0xffDFE4E4),
                        color: R.color.white),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              convertToUTC(
                                  (selectedDate?.millisecondsSinceEpoch ?? 0) ~/
                                      1000,
                                  'HH:mm - dd/MM/yyyy'),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400)),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.expand_more,
                            color: R.color.primaryGreyColor,
                            size: 24,
                          ),
                        ]),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _controllerDuration,
                    textAlign: TextAlign.center,
                    cursorColor: _controllerDuration.text.isNotEmpty
                        ? R.color.greenGradientBottom
                        : R.color.color0xff636A6B,
                    cursorHeight: 36,
                    cursorWidth: 3,
                    autofocus: true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: TextStyle(
                      fontSize: 48,
                      color: R.color.textDark,
                      fontWeight: FontWeight.w700,
                      height: 0.95,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      hintText: '00',
                      hintStyle: TextStyle(
                        fontSize: 48,
                        color: R.color.color0xff636A6B,
                        fontWeight: FontWeight.w700,
                        height: 0.95,
                      ),
                      // set border bottom only
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.lerp(
                          BorderSide(color: R.color.primaryGreyColor, width: 1),
                          BorderSide(color: R.color.primaryGreyColor, width: 1),
                          0.5,
                        ),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(top: 22),
                        child: Text(
                          R.string.minute_upper_case_first.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            color: R.color.color0xff636A6B,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _controllerDuration.text = value;
                        _controllerDuration.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset: _controllerDuration.text.length));
                      }
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return R.string.nhap_chi_so_van_dong.tr();
                      }
                      // check if value is number
                      if (double.tryParse(value) == null) {
                        return R.string.data_input_not_valid.tr();
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ExerxisesIntensity(
                  selectedIntensity: intensity,
                  onIntensityChanged: (newIntensity) {
                    setState(() {
                      intensity = newIntensity;
                    });
                  },
                )
              ])),
          const SizedBox(height: 16),
          ExercisesCategories(
            selected: selectedCategory,
            onChanged: (ExercrisesCategoryModel? item) {
              setState(() {
                selectedCategory = item;
              });
            },
          ),
          const SizedBox(height: 16),
          ExercisesNoteWithMedia(
            mediaUrls: files,
            maxMedia: maxMedia,
            note: note,
            onChangedNote: (String notes) {
              setState(() {
                this.note = notes;
              });
            },
            onChangedMediaUrls: (mediaUrls) {
              setState(() {
                this.files = mediaUrls;
              });
            },
            onFileRemoved: (fileId) {
              if (fileId.isNotEmpty) {
                setState(() {
                  removeFileIds.add(fileId);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // add divider vertical with label 'hello' in the middle
          Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(R.string.or.tr(),
                        style: TextStyle(
                            fontSize: 14,
                            color: R.color.greenGradientBottom,
                            fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),
          // add button to connect to health app / apple health
          HealthConnectButton(
            margin: const EdgeInsets.all(0),
            callback: () {
              print('HealthConnectButton pressed');
            },
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  calculatorCalo() async {
    // Only proceed if we have all required values
    if (_shouldCalculateCalo()) {
      return;
    }

    // Show loading indicator
    setState(() {
      isLoading = true;
    });

    try {
      BotToast.showLoading();
      ExercrisesCategoryModel updatedCategories = selectedCategory!;
      final int duration = int.tryParse(_controllerDuration.text) ?? 0;

      final response = await ExercrisesClient().fetchCalories(
        updatedCategories.categoryId,
        intensity?.intensityId, // Sử dụng intensity từ state
        duration,
      );
      // Debug kiểm tra
      print('API Response: $response');

      // Trích xuất thông tin từ response
      final caloriesNumber = response['calories'] ?? 0.0;
      final unit = response['unit'] ?? 'kcal';

      // Cập nhật danh sách bài tập trong category
      updatedCategories = ExercrisesCategoryModel(
        categoryId: updatedCategories.categoryId,
        category: updatedCategories.category,
        exerciseId: '',
        code: '',
        duration: duration.toDouble(),
        burnedCalorie: caloriesNumber,
        exerciseIntensityId: intensity?.intensityId,
        unit: unit,
        exercises: [],
        // Copy other fields from the original category
        description: updatedCategories.description,
        order: updatedCategories.order,
        cover: updatedCategories.cover,
      );

      // Cập nhật state một lần duy nhất
      setState(() {
        selectedCategory = updatedCategories;
      });

      BotToast.closeAllLoading();
    } catch (e) {
      print('Calculator error: $e');
      BotToast.showText(text: 'Error calculating calories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  editData() async {
    FocusScope.of(context).unfocus();

    if (selectedDate == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
      return;
    }
    if (selectedCategory == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_hoat_dong.tr());
      return;
    }

    BotToast.showLoading();

    try {
      await calculatorCalo();

      List<String> paths = [];
      for (var file in files) {
        if (file is XFile) {
          paths.add(file.path);
        }
      }
      final result = await ExercrisesClient().updateExercrises(
        widget.exerciseInputId,
        (selectedDate!.millisecondsSinceEpoch ~/ 1000).toInt(),
        selectedTimeFrame?.id,
        note,
        selectedCategory!,
        removeFileIds,
        paths,
        intensity?.intensityId ?? '',
      );
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "active_change_data_v2");
      }
      BotToast.closeAllLoading();
      Navigator.pop(context);
      Message.showToastMessage(context, R.string.exercise_delete_success.tr());

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

  deleteData() async {
    try {
      BotToast.showLoading();
      final result =
          await ExercrisesClient().deleteExercrises(widget.exerciseInputId);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "active_change_data_v2");
      }
      // if(result.)
      BotToast.closeAllLoading();
      if (widget.isOnlyOne == true) {
        AppSettings.clearLastOpenedExerciseInputType();
        Navigator.pushNamedAndRemoveUntil(
          context,
          NavigatorName.exercrise_onboarding,
          (route) => false,
        );
      } else {
        Navigator.pop(context);
      }
      Message.showToastMessage(context, R.string.exercise_delete_success.tr());
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.exercise_delete_popup_title.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            '${R.string.exercise_delete_popup_body.tr()} " ${selectedCategory?.category} " ',
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            if (widget.exerciseInputId != null) {
                              deleteData();
                            }
                          },
                          child: Container(
                            height: 43,
                            decoration: BoxDecoration(
                              color: R.color.red_2,
                              borderRadius: BorderRadius.circular(200),
                            ),
                            child: Center(
                              child: Text(R.string.confirm.tr(),
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.textDark),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  _submitData() async {
    if (selectedCategory == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_hoat_dong.tr());
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Hiển thị loading
        BotToast.showLoading();

        await calculatorCalo();

        // Process files for upload
        // List<File> filesToUpload = [];
        // List<String> existingFileIds = [];

        // for (var item in files) {
        //   if (item is XFile) {
        //     filesToUpload.add(File(item.path));
        //   } else if (item is Map<String, dynamic> && item.containsKey('id')) {
        //     existingFileIds.add(item['id'].toString());
        //   }
        // }

        // Chuẩn bị dữ liệu
        List<String> paths = [];
        for (var file in files) {
          paths.add(file.path);
        }

        // Use repository to handle both API call and file upload
        final result = await ExercrisesClient().postIndexExercrises(
            ((selectedDate?.millisecondsSinceEpoch ?? 0) ~/ 1000).toInt(),
            null,
            note,
            selectedCategory!,
            paths,
            intensity?.intensityId);
        if (result) {
          // Xử lý thành công
          // BotToast.showText(text: 'Thêm bài tập thành công!');
          Message.showToastMessage(
              context, R.string.add_exercise_successfully.tr());
          Observable.instance
              .notifyObservers([], notifyName: "active_change_data_v2");
          if (widget.isOnlyOne == true) {
            AppSettings.clearLastOpenedExerciseInputType();
          }
          Navigator.pushNamed(context, NavigatorName.exercrise_result,
              arguments: {
                'date': selectedDate,
                'periodFilterType': 1,
              });
        } else {
          // Xử lý lỗi
          // BotToast.showText(text: 'Thêm bài tập thất bại');
          Message.showToastMessage(context, R.string.add_exercise_failed.tr());
        }
      } catch (e) {
        // Xử lý lỗi
        BotToast.showText(text: 'Đã xảy ra lỗi: $e');
      } finally {
        BotToast.closeAllLoading();
      }
    }
  }
}

class ExerxisesIntensity extends StatefulWidget {
  final ExerciseIntensity? selectedIntensity;
  final ValueChanged<ExerciseIntensity> onIntensityChanged;

  const ExerxisesIntensity({
    Key? key,
    required this.selectedIntensity,
    required this.onIntensityChanged,
  }) : super(key: key);

  @override
  _ExerxisesIntensityState createState() => _ExerxisesIntensityState();
}

class _ExerxisesIntensityState extends State<ExerxisesIntensity> {
  List<ExerciseIntensity> intensities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchIntensities();
  }

  @override
  void didUpdateWidget(covariant ExerxisesIntensity oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIntensity != null &&
        widget.selectedIntensity != oldWidget.selectedIntensity) {
      _fetchIntensities();
    }
  }

  Future<void> _fetchIntensities() async {
    final token = await AppSettings.getToken();
    print('Token: $token');
    try {
      final result = await AppRepository().getExerciseIntensities();

      result.when(
        success: (data) {
          setState(() {
            intensities = data;
            if (widget.selectedIntensity == null) {
              widget.onIntensityChanged(intensities
                  .where((e) =>
                      e.intensityId == "3f29e372-1179-477e-b183-33356a28ece5")
                  .first);
            }
            isLoading = false;
          });
        },
        failure: (error) {
          setState(() {
            isLoading = false;
          });
          BotToast.showText(text: 'Failed to load intensities: $error');
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      BotToast.showText(text: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (intensities.isEmpty) {
      return Center(child: Text('No intensities available'));
    }

    return Theme(
      data: Theme.of(context).copyWith(
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                side: BorderSide(
                  color: R.color.color0xffDFE4E4,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
            ),
          ),
        ),
      ),
      child: Container(
        // width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: SegmentedButton<String>(
          segments: intensities.map((intensity) {
            return ButtonSegment(
              value: intensity.intensityId,
              label: Text(
                intensity.name,
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
          selected: {widget.selectedIntensity?.intensityId ?? ''},
          onSelectionChanged: (Set<String> newSelectionId) {
            final selectedIntensity = intensities.firstWhere(
              (intensity) => newSelectionId.contains(intensity.intensityId),
            );
            widget.onIntensityChanged(selectedIntensity);
            // The parent will handle calling calculatorCalo when intensity changes
          },
          style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size(100, 40)),
            textStyle: MaterialStateProperty.resolveWith<TextStyle>(
              (Set<MaterialState> states) {
                return TextStyle(
                  fontSize: 15,
                  fontWeight: states.contains(MaterialState.selected)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: states.contains(MaterialState.selected)
                      ? R.color.color0xffF7F8F8
                      : R.color.color0xff636A6B,
                );
              },
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return R.color.greenGradientBottom;
                }
                return R.color.color0xffF7F8F8;
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return R.color.white;
                }
                return R.color.color0xff003F38;
              },
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            side: MaterialStateProperty.all(
              BorderSide(
                color: R.color.color0xffDFE4E4,
                width: 1,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
          ),
          showSelectedIcon: false,
        ),
      ),
    );
  }
}
