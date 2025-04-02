import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'widget/aihelp_button.dart';
import 'add_bloodSugar_result_note.dart';
import 'bloodpressure_result.dto.dart';

class PageAddBloodPressureResult extends StatefulWidget {
  const PageAddBloodPressureResult({super.key, required this.data});
  final BloodPressureResultDto data;

  @override
  State<PageAddBloodPressureResult> createState() => _PageAddBloodPressureResultState();
}

class _PageAddBloodPressureResultState extends State<PageAddBloodPressureResult> {
  bool get _haveNote => _note.isNotEmpty == true || _files.isNotEmpty == true;
  String? _aiResult;

  bool _haveEditNote = false;
  late String _note = widget.data.note ?? '';
  List<String?> _removeIDs = [];
  List<dynamic> _files = [];

  @override
  void initState() {
    _loadData();
    super.initState();
  }

  void _loadData() async {
    final data = widget.data;
    _files = data.files ?? [];
    final unit = AppSettings.userInfo?.glucoseUnit ?? 1;

    bool shouldFetchNewData = (data.isFetchAnalysis ?? false) ||
        ((data.healthRecommendation?.isEmpty) ?? true);

    final aiResult = shouldFetchNewData
        ? await GlucoseClient()
            .fetchGlucoseInputAnalysis(widget.data.id, unit)
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
      if (_haveEditNote) {
        List<String> paths = [];
        for (var file in _files) {
          if (file is PickedFile) {
            paths.add(file.path);
          }
        }
        final result = await GlucoseClient().putIndexGlucose(
            widget.data.id,
            null,
            (widget.data.dateTime.millisecondsSinceEpoch ~/ 1000).toInt(),
            widget.data.glucose.toString(),
            null,
            _note,
            // TODO: check fromNipro
            false,
            _removeIDs,
            paths);
        if (result == true) {
          BotToast.closeAllLoading();
          Observable.instance.notifyObservers([], notifyName: "glucose_change_data");
          return;
        }
      }
      Observable.instance.notifyObservers([], notifyName: "glucose_change_data");
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
    Navigator.of(context).pushNamed(NavigatorName.glucose_intro_2nd_page);
  }

  void _doBack() {
    Observable.instance.notifyObservers([], notifyName: "glucose_change_data");
  }

  void _doEditNote() async {
    final noteResult = await NavigationUtil.navigatePage(
        context,
        PageAddBloodPressureResultNote(
          note: _note,
          files: _files,
        ));
    if (noteResult != null) {
      _haveEditNote = true;
      _note = noteResult['note'];
      _files = noteResult['files'];
      _removeIDs = noteResult['removeIDs'];
      setState(() {});
    }
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
      backgroundColor: R.color.transparent,
      centerTitle: true,
      title: Text(
        formattedDateTime,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.textDark),
        onPressed: _doBack,
      ),
      actions: [
        GestureDetector(
          onTap: _doGuide,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Image.asset(R.drawable.ic_help_outlined, width: 24, height: 24),
          ),
        ),
      ],
    );
  }

  Widget _bloodpressureResultSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            height: 200,
            width: 250,
            child: _SegmentedCircularGauge(
              rangeValue: widget.data.rangeValue,
              glucose: widget.data.glucose,
              glucoseUnit: widget.data.glucoseUnit,
              timeFrame: widget.data.timeFrame,
              rangeLabel: widget.data.rangeLabel,
              indexRange: widget.data.indexRange,
              rangeColor: widget.data.rangeColor,
            ),
          ),

          // const SizedBox(height: 24),
          // button add note
          _buildNoteOrAddNoteSection(),

          const SizedBox(height: 24),
          Container(
            height: 1,
            color: Color(0xFFE5E5E5),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    R.drawable.ic_info,
                    width: 16,
                    height: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Thông tin',
                    style: TextStyle(
                      fontSize: 14,
                      color: R.color.primaryGreyColor,
                    ),
                  ),
                ],
              ),
              Text(
                'Cao',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
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

  Widget _buildNoteOrAddNoteSection() {
    if (_haveNote) {
      // Section show note
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: R.color.color0xffF2F6F9,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  R.string.ghi_chu.tr(),
                  style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: R.color.textDark),
                ),
                Spacer(),
                GestureDetector(
                  onTap: _doEditNote,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    child: Image.asset(R.drawable.ic_pencil_create, width: 20, height: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _note,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 16 / 12,
              ),
            ),
            // images
            if (_files.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _files.map((e) {
                  final index = _files.indexOf(e);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/photo_view',
                          arguments: {'files': _files, 'index': index});
                    },
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 56,
                        height: 56,
                        clipBehavior: Clip.hardEdge,
                        child: _files[index] is PickedFile
                            ? Image.file(
                                File(_files[index].path),
                                fit: BoxFit.cover,
                              )
                            : NetWorkImageWidget(imageUrl: _files[index].url, fit: BoxFit.cover),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      );
    }
    return ElevatedButton(
      onPressed: _doEditNote,
      child: Center(
        child: Text(
          R.string.them_ghi_chu.tr(),
          style: TextStyle(color: R.color.dark, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: R.color.color0xffF2F6F9,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        fixedSize: const Size(146, 32),
        elevation: 0,
      ),
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
  final List<int> rangeValue;
  final double glucose;
  final String glucoseUnit;
  final String timeFrame;
  final String rangeLabel;
  final int indexRange;
  final Color rangeColor;
  const _SegmentedCircularGauge({
    required this.rangeValue,
    required this.glucose,
    required this.glucoseUnit,
    required this.timeFrame,
    required this.rangeLabel,
    required this.indexRange,
    required this.rangeColor,
  });

  @override
  Widget build(BuildContext context) {
    double startAngle = 135;
    double endAngle = 405;

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

    // recalculate glucose by scaleListRendering
    double glucoseRendering = glucose;
    if (scaleListRendering.length > 2) {
      glucoseRendering = scaleListRendering[indexRange] + (step / 2);
    }

    return Center(
      child: SfRadialGauge(
        backgroundColor: Colors.white,
        axes: <RadialAxis>[
          RadialAxis(
            startAngle: startAngle,
            endAngle: endAngle,
            minimum: minValue, // 0
            maximum: renderMaxValue, // 200
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0,
              thicknessUnit: GaugeSizeUnit.logicalPixel,
              cornerStyle: CornerStyle.bothFlat,
            ),
            ranges: <GaugeRange>[
              for (int i = 0; i < scaleListRendering.length - 1; i++)
                GaugeRange(
                  startValue: scaleListRendering[i] + 1,
                  endValue: max(0, scaleListRendering[i + 1] - 1),
                  color: i == indexRange ? rangeColor : Color(0xFFE6ECF1),
                  startWidth: 10,
                  endWidth: 10,
                ),
            ],
            pointers: <GaugePointer>[
              MarkerPointer(
                value: glucoseRendering, // Current value
                markerType: MarkerType.invertedTriangle,
                color: R.color.dark,
                markerHeight: 8,
                markerWidth: 12,
                markerOffset: -6,
              ),
            ],
            annotations: <GaugeAnnotation>[
              // Add the text annotations for "Trước ăn", "Cao", and "135 mg/dL"
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeFrame,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      rangeLabel,
                      style: TextStyle(
                        fontSize: 24,
                        color: rangeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${roundNumber(glucose)} $glucoseUnit',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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
