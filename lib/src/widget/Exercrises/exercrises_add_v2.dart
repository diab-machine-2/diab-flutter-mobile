import 'dart:developer';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/request/add_exercise_request.dart';
import 'package:medical/src/model/response/exercise_intensity_response.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Exercrises/exercrises_categories.dart';
import 'package:medical/src/widget/Exercrises/exercrises_note_with_media.dart';
import 'package:medical/src/widget/Exercrises/widget/health_connect_button.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker2.dart';
import 'package:medical/src/widgets/button_widget.dart';

import 'widget/date_multi_picker.dart';

class ExercrisesAddV2 extends StatefulWidget {
  ExercrisesAddV2({Key? key}) : super(key: key);

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
  List<ExercrisesCategoryModel> selectedCategory = [];
  ExerciseIntensity? intensity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controllerDuration.addListener(_onDurationChanged);
    selectedDate = DateTime.now();
    selectedCategory = [];
  }

  void _onDurationChanged() {
    calculatorCalo();
  }

  bool _shouldCalculateCalo() {
    return selectedDate != null &&
        selectedCategory.isNotEmpty &&
        intensity != null &&
        _controllerDuration.text.isNotEmpty &&
        double.tryParse(_controllerDuration.text) != null;
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
    _controllerDuration.removeListener(_onDurationChanged);
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
                  R.string.exercrise_add_v2_title.tr(),
                  style: TextStyle(
                      color: R.color.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            backgroundColor: R.color.transparent, //No more green
            elevation: 0.0, //Shadow gone
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    R.color.greenGradientMid,
                    R.color.greenGradientBottom
                  ])),
            ),
          ),
          body: _buildContainer(),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    CustomCalendarDatePicker2.showDatePicker(context,
        maxTime: DateTime.now(),
        minTime: DateTime.parse('1900-01-01 00:00:00.000Z'),
        showTitleActions: true,
        onChanged: (date) {}, onConfirm: (date) async {
      // FirebaseTracking.onSelectBirthDay(date);
      setState(() {
        selectedDate = date;
        calculatorCalo();
      });
    },
        currentTime: selectedDate == null
            ? DateTime.parse('1970-01-01 00:00:00.000Z')
            : selectedDate,
        locale: LocaleType.vi);
  }

  Widget _buildContainer() {
    return Form(
        key: _formKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                controller: scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                barrierColor:
                                    R.color.color0xff003F38.withOpacity(0.5),
                                context: context,
                                builder: (_) => DateMultiPicker(
                                  initDate: selectedDate,
                                  callback: (date) {
                                    setState(() {
                                      selectedDate = date;
                                      calculatorCalo();
                                    });
                                  },
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(200),
                                  border: Border.all(
                                      color: R.color.color0xffDFE4E4),
                                  color: R.color.white),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        convertToUTC(
                                            (selectedDate
                                                        ?.millisecondsSinceEpoch ??
                                                    0) ~/
                                                1000,
                                            'HH:mm - dd/MM/yyyy'),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400)),
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
                          TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _controllerDuration,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 36,
                                color: R.color.textDark,
                                fontWeight: FontWeight.w900),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              hintText: '0',
                              hintStyle: TextStyle(
                                  fontSize: 36,
                                  color:
                                      R.color.primaryGreyColor.withOpacity(0.5),
                                  fontWeight: FontWeight.w900),
                              // set border bottom only
                              border: UnderlineInputBorder(
                                  borderSide: BorderSide.lerp(
                                      BorderSide(
                                          color: R.color.primaryGreyColor,
                                          width: 1),
                                      BorderSide(
                                          color: R.color.primaryGreyColor,
                                          width: 1),
                                      0.5)),
                              suffixText: R.string.minute.tr(),
                              suffixStyle: TextStyle(
                                  fontSize: 16,
                                  color: R.color.primaryGreyColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            onChanged: (value) {
                              // Handle input change
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
                          const SizedBox(height: 16),
                          ExerxisesIntensity(
                            selectedIntensity: intensity,
                            onIntensityChanged: (newIntensity) {
                              setState(() {
                                intensity = newIntensity;
                                calculatorCalo();
                              });
                            },
                          )
                        ])),
                    const SizedBox(height: 16),
                    ExercisesCategories(
                      selected: selectedCategory,
                      onChanged: (List<ExercrisesCategoryModel> list) {
                        setState(() {
                          selectedCategory = list;
                          calculatorCalo();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ExercisesNoteWithMedia(
                      mediaUrls: files,
                      maxMedia: maxMedia,
                      onChangedNote: (String note) {
                        setState(() {
                          this.note = note;
                        });
                      },
                      onChangedMediaUrls: (mediaUrls) {
                        setState(() {
                          files = mediaUrls;
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
              ),
            ),
            // add animation face in/out (opacity) when keyboard show / hide
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: KeyboardVisibilityProvider(
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
                            child: ButtonWidget(
                              title: R.string.confirm.tr(),
                              onPressed: _submitData,
                            ),
                          ));
                    },
                  ),
                ))
          ],
        ));
  }

  calculatorCalo() async {
    // Only proceed if we have all required values
    if (!_shouldCalculateCalo()) {
      return;
    }

    // Show loading indicator or disable inputs during calculation
    setState(() {
      isLoading = true;
    });

    try {
      // Create a list to store updated categories
      final List<ExercrisesCategoryModel> updatedCategories =
          List.from(selectedCategory);
      final int duration = int.tryParse(_controllerDuration.text) ?? 0;

      // Process each category and its exercises
      for (int i = 0; i < updatedCategories.length; i++) {
        final category = updatedCategories[i];

        // Create a list of Future requests for all exercises in this category
        final List<Future> exerciseRequests = [];

        for (final exercise in category.exercises) {
          final request = ExercrisesClient().fetchCalories(
              exercise.exerciseCategoryId,
              exercise.exerciseId,
              exercise.intensityId,
              duration);
          exerciseRequests.add(request);
        }

        // Wait for all exercise requests to complete
        final results = await Future.wait(exerciseRequests);

        // Process the results and update exercises
        double totalCalories = 0;
        for (int j = 0; j < results.length; j++) {
          final response = results[j];
          final calories = response['calories'] ?? 0;
          totalCalories += calories;

          // Update individual exercise if needed
          // This depends on your data structure
        }

        // Update the category with the total calories
        updatedCategories[i] = ExercrisesCategoryModel(
          categoryId: category.categoryId,
          category: category.category,
          exerciseId: category.exerciseId,
          code: category.code,
          duration: duration.toDouble(),
          burnedCalorie: totalCalories,
          exerciseIntensityId: category.exerciseIntensityId,
          unit: category.unit,
          description: category.description,
          order: category.order,
          cover: category.cover,
          exercises: category.exercises
              .map((e) => e.copyWith(
                    burnedCalorie: e.burnedCalorie,
                    duration: duration.toDouble(),
                  ))
              .toList(),
        );
      }

      // Update state once with all changes
      setState(() {
        selectedCategory = updatedCategories;
      });
    } catch (e) {
      // Handle errors
      BotToast.showText(text: 'Error calculating calories: $e');
      print('Calculator error: $e');
    } finally {
      // Always reset loading state
      setState(() {
        isLoading = false;
      });
    }
  }

  _submitData() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Hiển thị loading
        BotToast.showLoading();

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
            selectedCategory,
            paths,
            intensity?.intensityId);
        if (result) {
          // Xử lý thành công
          BotToast.showText(text: 'Thêm bài tập thành công!');
          Observable.instance
              .notifyObservers([], notifyName: "active_change_data_v2");
          Navigator.pushNamed(context, NavigatorName.exercrise_result,
              arguments: {
                'date': selectedDate,
                'periodFilterType':
                    AppSettings.getPeriodByScreen(ScreenList.EXERCISE.index),
              });
        } else {
          // Xử lý lỗi
          BotToast.showText(text: 'Thêm bài tập thất bại');
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

  Future<void> _fetchIntensities() async {
    final token = await AppSettings.getToken();
    print('Token: $token');
    try {
      final result = await AppRepository().getExerciseIntensities();

      result.when(
        success: (data) {
          setState(() {
            intensities = data;
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: SegmentedButton<String>(
          segments: intensities.map((intensity) {
            return ButtonSegment(
              value: intensity.intensityId,
              label: Text(
                intensity.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
