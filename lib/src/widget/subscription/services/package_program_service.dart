// services/program_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/subscription/model/package_program_model.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class ProgramService {
  // Singleton pattern
  static final ProgramService _instance = ProgramService._internal();

  factory ProgramService() {
    return _instance;
  }

  ProgramService._internal();

  // Cache for loaded programs
  List<PackageProgram>? _programsCache;

  // Load programs from the JSON file
  Future<List<PackageProgram>> getPrograms() async {
    // Return cached data if available
    if (_programsCache != null) {
      return _programsCache!;
    }

    try {
      // Load JSON from asset file
      final String jsonString = await rootBundle
          .loadString('lib/src/widget/subscription/data/package_programs.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Parse JSON data into Program objects
      _programsCache = (jsonData['programs'] as List<dynamic>)
          .map((program) =>
              PackageProgram.fromJson(program as Map<String, dynamic>))
          .toList();

      return _programsCache!;
    } catch (e) {
      // In case of error, return sample data
      print('Error loading programs: $e');
      return [];
    }
  }

  // Get a specific program by ID
  Future<PackageProgram?> getProgramById(String id) async {
    final programs = await getPrograms();
    try {
      return programs.firstWhere((program) => program.id == id);
    } catch (e) {
      return null; // Program not found
    }
  }

  static String getProgramImage(String programId) {
    switch (programId) {
      case "program1":
        return R.drawable.subscription_program_1;
      case "program2":
        return R.drawable.subscription_program_2;
      case "program3":
        return R.drawable.subscription_program_3;
      default:
        return "";
    }
  }

  /// Maps program item IDs to their corresponding drawable resources
  /// @param itemId The ID of the program item
  /// @return Resource drawable path in R.drawable.subscription_[id] format
  static String getItemImageResource(String itemId) {
    switch (itemId) {
      // Program 1 items
      case "blood_sugar":
        return R.drawable.subscription_blood_sugar;
      case "reduce_hba1c":
        return R.drawable.subscription_reduce_hba1c;
      case "exercise_diet":
        return R.drawable.subscription_exercise_diet;

      // Program 2 items
      case "weight_loss":
        return R.drawable.subscription_weight_loss;
      case "increase_exercise":
        return R.drawable.subscription_increase_exercise;
      case "blood_pressure":
        return R.drawable.subscription_blood_pressure;

      // Program 3 items
      case "postpartum":
        return R.drawable.subscription_postpartum;
      case "fetal_complications":
        return R.drawable.subscription_fetal_complications;
      case "pregnancy_health":
        return R.drawable.subscription_pregnancy_health;

      // Default case
      default:
        return "";
    }
  }

  /// Maps audience IDs to their corresponding drawable resources
  /// @param audienceId The ID of the audience
  /// @return Resource drawable path in R.drawable.subscription_[id] format
  static String getAudienceImageResource(String audienceId) {
    switch (audienceId) {
      // Program 1 audiences
      case "diabetic_patient":
        return R.drawable.subscription_diabetic_patient;
      case "family_member":
        return R.drawable.subscription_family_member;

      // Program 2 audiences
      case "overweight":
        return R.drawable.subscription_overweight;
      case "prediabetes":
        return R.drawable.subscription_prediabetes;
      case "hypertension":
        return R.drawable.subscription_hypertension;

      // Program 3 audiences
      case "pregnant_women":
        return R.drawable.subscription_pregnant_women;
      case "family_pregnant":
        return R.drawable.subscription_family_pregnant;

      // Default case
      default:
        return '';
    }
  }

  /// Maps target IDs to their corresponding drawable resources
  /// @param targetId The ID of the target
  /// @return Resource drawable path in R.drawable.subscription_[id] format
  static String getTargetImageResource(String targetId) {
    switch (targetId) {
      // Program 1 targets
      case "weight_loss":
        return R.drawable.subscription_weight_loss;
      case "reduce_hba1c":
        return R.drawable.subscription_reduce_hba1c;
      case "quality_life":
        return R.drawable.subscription_quality_life;

      // Program 2 targets
      case "weight_loss_5":
        return R.drawable.subscription_weight_loss_5;
      case "stabilize_blood_pressure":
        return R.drawable.subscription_stabilize_blood_pressure;
      case "exercise_150_min":
        return R.drawable.subscription_exercise_150;
      case "prevent_diabetes_2":
        return R.drawable.subscription_prevent_diabetes_2;
      case "improve_overall_health":
        return R.drawable.subscription_improve_overall_health;
      case "chronic_disease_knowledge":
        return R.drawable.subscription_chronic_disease_knowledge;

      // Program 3 targets
      case "prevent_diabetes":
        return R.drawable.subscription_prevent_diabetes;
      case "prevent_fetal_complications":
        return R.drawable.subscription_prevent_fetal_complications;
      case "ensure_nutrition":
        return R.drawable.subscription_ensure_nutrition;
      case "safe_exercise_plan":
        return R.drawable.subscription_safe_exercise_plan;
      case "stress_management":
        return R.drawable.subscription_stress_management;
      case "blood_sugar_control":
        return R.drawable.subscription_blood_sugar_control;

      // Default case
      default:
        return '';
    }
  }

  /// Maps action IDs to their corresponding drawable resources
  /// @param actionId The ID of the action
  /// @return Resource drawable path in R.drawable.subscription_[id] format
  static String getActionImageResource(String actionId) {
    switch (actionId) {
      // Program 1 specific actions
      case "medication_1":
        return R.drawable.subscription_medication_1;
      case "healthy_diet":
        return R.drawable.subscription_healthy_diet;
      case "exercise":
        return R.drawable.subscription_exercise;
      case "anxiety_1":
        return R.drawable.subscription_anxiety_1;
      case "monitoring":
        return R.drawable.subscription_monitoring;
      case "prevent_complications":
        return R.drawable.subscription_prevent_complications;

      // Program 2 specific actions
      case "medication_2":
        return R.drawable.subscription_medication_2;
      case "balanced_diet":
        return R.drawable.subscription_balanced_diet;
      case "safe_exercise":
        return R.drawable.subscription_safe_exercise;
      case "anxiety_2":
        return R.drawable.subscription_anxiety_2;
      case "monitor_regimen":
        return R.drawable.subscription_monitor_regimen;
      case "medical_knowledge":
        return R.drawable.subscription_medical_knowledge;

      // Program 3 specific actions
      case "medication_3":
        return R.drawable.subscription_medication_3;
      case "pregnancy_nutrition":
        return R.drawable.subscription_pregnancy_nutrition;
      case "prenatal_yoga":
        return R.drawable.subscription_prenatal_yoga;
      case "anxiety_3":
        return R.drawable.subscription_anxiety_3;
      case "health_assessment":
        return R.drawable.subscription_health_assessment;
      case "support_24_7":
        return R.drawable.subscription_support_24_7;

      // Default case
      default:
        return '';
    }
  }

  static Color getProgramItemColor(String itemId) {
    return R.color.greenGradientTop02;
  }

  // Clear the cache (useful for testing or when data needs to be refreshed)
  void clearCache() {
    _programsCache = null;
  }

  static showPopupRequestConsultSubscription({
    required Function onNavigateHome,
    Function? onContact,
    bool isShowImg = false,
    String? subtitle,
    String? title,
    String? title2,
    String primaryButtonTitle = 'Xác nhận',
    String secondaryButtonTitle = 'Huỷ',
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);

            return false;
          },
          child: Container(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: R.color.color0xff111515,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    GapH(16),
                    if (isShowImg)
                      Image.asset(R.drawable.ic_dialog_success,
                          width: 43, height: 43),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (title2 != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 14.0),
                            child: Text(
                              title2,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: R.color.color0xff636A6B,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            title ?? "",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        subtitle ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff777E90,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GapH(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              onContact?.call();
                            },
                            child: Container(
                              height: 43,
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: R.color.white,
                                borderRadius: BorderRadius.circular(200),
                                border: Border.all(
                                  color: R.color.greenGradientBottom,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  secondaryButtonTitle,
                                  style: TextStyle(
                                    color: R.color.greenGradientBottom,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              onNavigateHome.call();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: R.color.white,
                              ),
                              child: Container(
                                height: 43,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      R.color.greenGradientTop02,
                                      R.color.greenGradientBottom,
                                      R.color.greenGradientBottom,
                                    ],
                                  ),
                                ),
                                child: Text(
                                  primaryButtonTitle,
                                  style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GapH(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static showPopupConfirmBasicSubscription({
    required Function onConfirm,
    String? title,
    String? subtitle,
    String primaryButtonTitle = 'Xác nhận',
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);

            return false;
          },
          child: Container(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close,
                            color: R.color.color0xff111515,
                            size: 24,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        title ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff111515,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        subtitle ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: R.color.color0xff636A6B,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    GapH(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            onConfirm.call();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                            ),
                            child: Container(
                              height: 43,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    R.color.greenGradientTop02,
                                    R.color.greenGradientBottom,
                                    R.color.greenGradientBottom,
                                  ],
                                ),
                              ),
                              child: Text(
                                primaryButtonTitle,
                                style: TextStyle(
                                    color: R.color.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GapH(16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
