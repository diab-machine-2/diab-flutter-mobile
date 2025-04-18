import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'bloodpressure_result.dto.dart';
import 'widget/aihelp_button.dart';

class PageAddBloodPressureResult extends StatefulWidget {
  const PageAddBloodPressureResult({super.key, required this.data});
  final BloodPressureResultDto data;

  @override
  State<PageAddBloodPressureResult> createState() => _PageAddBloodPressureResultState();
}

class _PageAddBloodPressureResultState extends State<PageAddBloodPressureResult> {
  // bool get _haveNote => _note.isNotEmpty == true || _files.isNotEmpty == true;
  String? _aiResult;
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();

  List<dynamic> _files = [];
  late TextEditingController _controllerNote;

  @override
  void initState() {
    _loadData();
    _controllerNote = TextEditingController(text: widget.data.note);
    super.initState();
  }

  void _loadData() async {
    final data = widget.data;
    _files = data.files ?? [];

    bool shouldFetchNewData =
        (data.isFetchAnalysis ?? false) || ((data.healthRecommendation?.isEmpty) ?? true);

    final aiResult = shouldFetchNewData
        ? await BloodPressureClient()
            .fetchBloodPressureInputAnalysis(widget.data.id)
            .catchError((e, s) {
            TrackingManager.recordError(e, s);
            return null;
          })
        : data.healthRecommendation;

    _aiResult = aiResult ?? '';
    if (mounted) {
      setState(() {});
    }
  }

  void _doComplete() async {
    try {
      BotToast.showLoading();
      List<String> paths = [];
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in data.files) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final _ = await BloodPressureClient().updateBloodPressureInput(
          widget.data.id,
          widget.data.systolic.toString(),
          widget.data.diastolic.toString(),
          widget.data.pulse.toString(),
          widget.data.dateTime.millisecondsSinceEpoch ~/ 1000,
          widget.data.timeFrameId,
          data.note,
          '',
          data.removeIDs,
          paths);
      // TODO: which is goalId?
      await HomeClient()
          .completeSmartGoal(widget.data.dateTime, '', 1, ScheduleType.blood_pressure.typeIndex);
      BotToast.closeAllLoading();
      Observable.instance.notifyObservers([], notifyName: "BloodPressure_change_data");
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      BotToast.closeAllLoading();
    }
  }

  void _doShare() {
    // TODO: share
  }

  void _doChatWithDiabExpert() {
    // TODO: share
  }

  void _doGuide() async {
    Navigator.of(context).pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
  }

  void _doBack() {
    Observable.instance.notifyObservers([], notifyName: "BloodPressure_change_data");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                _appBarSection(),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 100),
                      physics: const ClampingScrollPhysics(),
                      child: _bloodpressureResultSection(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 8 + MediaQuery.of(context).padding.bottom / 2,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: _bottomSection(),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBarSection() {
    String formattedDateTime = DateFormat('HH:mm - dd/MM/yyyy').format(widget.data.dateTime);
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: true,
      title: Text(
        formattedDateTime,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.white),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.white),
        onPressed: _doBack,
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                _doGuide();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bloodpressureResultSection() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 80,
                child: _SegmentedCircularGauge(
                  rangeValue: widget.data.rangeValue,
                  indexRange: widget.data.indexRange,
                  diastolic: widget.data.diastolic,
                  systolic: widget.data.systolic,
                  pulse: widget.data.pulse,
                  pulseResultText: widget.data.pulseResultText,
                  timeFrame: widget.data.timeFrame,
                  rangeLabel: widget.data.rangeType.title,
                  rangeColor: widget.data.rangeType.color,
                  rangeType: widget.data.rangeType,
                ),
              ),
              if (widget.data.pulse != null) ...[
                Divider(
                  height: 1,
                  color: Color(0xFFDFE4E4),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 16),
                    Image.asset(R.drawable.ic_bloodpressure_pulse, width: 20, height: 20),
                    const SizedBox(width: 8),
                    Text.rich(
                      TextSpan(
                        text: '${widget.data.pulse!.round()}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: R.color.textDark,
                        ),
                        children: [
                          TextSpan(
                            text: ' nhịp/phút',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: R.color.primaryGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // text
                    Text(
                      'Cao',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF636A6B),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),
        // result
        _buildAIResult(),

        if (widget.data.reasons.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildReasons(),
        ],

        const SizedBox(height: 16),
        // button add note
        _noteSection(),
      ],
    );
  }

  Widget _buildAIResult() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          // result
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.ai_suggestion_glucose.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                  height: 21 / 15,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(R.drawable.ic_info, width: 18, height: 18),
              // InkWell(
              //   onTap: () {},
              //   child: Image.asset(R.drawable.ic_speak_text, width: 24, height: 24),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          if (_aiResult == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const AILoadingTextWidget(),
            )
          else if (_aiResult!.isEmpty)
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFFC82221),
              ),
            )
          else ...[
            Text(
              _aiResult ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 16 / 12,
              ),
            ),
            const SizedBox(height: 16),
            // elevated button, ic_zalo and text, full width
            AIHelpButton(rangeType: widget.data.rangeType),
          ],
        ],
      ),
    );
  }

  Widget _buildReasons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lý do',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: R.color.textDark,
              height: 21 / 15,
            ),
          ),
          const SizedBox(height: 8, width: double.infinity),
          Text(
            widget.data.reasons.join(' | '),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: R.color.color0xff111515,
              height: 16 / 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteSection() {
    return SectionAddNote(
      // focusNode: _focusNode,
      controllerNote: _controllerNote,
      maxMedia: 5,
      key: _sectionAddNoteKey,
      initialFiles: _files,
      noteTitle: 'Ghi chú',
      horizontalPadding: 12,
    );
  }

  Widget _bottomSection() {
    return ElevatedButton(
      onPressed: _doComplete,
      child: Text(R.string.completed.tr(), style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: R.color.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
    // return Row(
    //   children: [
    //     Expanded(
    //       child: ElevatedButton(
    //         onPressed: _doShare,
    //         child: Text(R.string.share.tr(), style: TextStyle(color: R.color.textDark)),
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Colors.white,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(24),
    //           ),
    //         ),
    //       ),
    //     ),
    //     const SizedBox(width: 16),
    //     Expanded(
    //       child: ElevatedButton(
    //         onPressed: _doComplete,
    //         child: Text(R.string.completed.tr(), style: TextStyle(color: Colors.white)),
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: R.color.mainColor,
    //           shape: RoundedRectangleBorder(
    //             borderRadius: BorderRadius.circular(24),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}

class _SegmentedCircularGauge extends StatelessWidget {
  final List<double> rangeValue;
  final double diastolic;
  final double systolic;
  final String timeFrame;
  final String rangeLabel;
  final int indexRange;
  final Color rangeColor;
  final double? pulse;
  final String? pulseResultText;
  final BloodPressureRangeType rangeType;
  const _SegmentedCircularGauge({
    required this.rangeValue,
    required this.diastolic,
    required this.systolic,
    required this.timeFrame,
    required this.rangeLabel,
    required this.indexRange,
    required this.rangeColor,
    this.pulse,
    this.pulseResultText,
    required this.rangeType,
  });

  @override
  Widget build(BuildContext context) {
    double startAngle = 155;
    double endAngle = 385;

    // scale list rangeValue
    List<double> scaleList = rangeValue.map((e) => e.toDouble()).toList();
    double minValue = -1;
    double maxValue = -1;
    for (var i = 0; i < scaleList.length; i++) {
      if (minValue == -1 || scaleList[i] < minValue) {
        minValue = scaleList[i];
      }
      if (maxValue == -1 || scaleList[i] > maxValue) {
        maxValue = scaleList[i];
      }
    }

    // from minValue to maxValue, separate equally
    double step = (maxValue - minValue) / (scaleList.length - 1);
    List<double> scaleListRendering = List.generate(
      scaleList.length,
      (i) => minValue + i * step,
    );
    double renderMaxValue = maxValue;
    if (scaleListRendering.length > 2) {
      renderMaxValue = maxValue +
          (scaleListRendering[scaleListRendering.length - 1] -
              scaleListRendering[scaleListRendering.length - 2]);
      scaleListRendering.add(renderMaxValue);
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width - 80,
      height: (MediaQuery.of(context).size.width - 80) * 0.8,
      child: SfRadialGauge(
        backgroundColor: Colors.white,
        axes: <RadialAxis>[
          RadialAxis(
            canScaleToFit: true,
            startAngle: startAngle,
            endAngle: endAngle,
            minimum: minValue,
            maximum: renderMaxValue,
            showLabels: false,
            showTicks: false,
            radiusFactor: 1.0, // Make gauge slightly smaller to fit within container
            axisLineStyle: AxisLineStyle(
              thickness: 0,
              thicknessUnit: GaugeSizeUnit.logicalPixel,
              cornerStyle: CornerStyle.bothCurve,
            ),
            ranges: <GaugeRange>[
              for (int i = 0; i < scaleListRendering.length - 1; i++)
                GaugeRange(
                  startValue: scaleListRendering[i] + 0.5,
                  endValue: max(0, scaleListRendering[i + 1] - 0.5),
                  color: i == indexRange ? rangeColor : Color(0xFFE6ECF1),
                  startWidth: 36,
                  endWidth: 36,
                ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeFrame,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 175,
                      ),
                      child: Text(
                        rangeLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: rangeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: '${roundNumber(diastolic)}/${roundNumber(systolic)}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF111515),
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: ' mmHg',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF636A6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
                positionFactor: 0,
                angle: 90,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
