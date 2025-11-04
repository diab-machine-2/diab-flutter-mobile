import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/widget/ai_loading_text_widget.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'hba1c_result.dto.dart';

class PageAddHbA1CResult extends StatefulWidget {
  const PageAddHbA1CResult({super.key, required this.data});
  final HbA1CResultDto data;

  @override
  State<PageAddHbA1CResult> createState() => _PageAddHbA1CResultState();
}

class _PageAddHbA1CResultState extends State<PageAddHbA1CResult>
    with WidgetsBindingObserver {
  String? _aiResult;
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();

  List<dynamic> _files = [];
  late TextEditingController _controllerNote;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    _loadData();
    _controllerNote = TextEditingController(text: widget.data.note);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
    }
  }

  void _loadData() async {
    final data = widget.data;
    _files = data.files ?? [];

    bool shouldFetchNewData = (data.isFetchAnalysis ?? false) ||
        ((data.healthRecommendation?.isEmpty) ?? true);

    // For HbA1C analysis - similar to blood pressure
    String? aiResult;

    if (shouldFetchNewData) {
      try {
        print('🔄 Fetching HbA1C analysis...');
        print('📊 HbA1C Value: ${widget.data.hba1c}');
        print('🆔 ID: ${widget.data.id}');

        aiResult = await HbA1CClient().fetchHbA1CInputAnalysis(
          id: widget.data.id.isEmpty ? null : widget.data.id,
          hba1cValue: widget.data.hba1c.toString(),
          date: (widget.data.dateTime.millisecondsSinceEpoch ~/ 1000),
          note: widget.data.note,
        );

        print(
            '✅ API Response: ${aiResult != null && aiResult.isNotEmpty ? "Success" : "Empty/Null"}');

        // If API returns null or empty, provide fallback content
        if (aiResult == null || aiResult.isEmpty) {
          print('⚠️ Using fallback analysis due to empty API response');
          aiResult = _generateFallbackAnalysis();
        }
      } catch (e, s) {
        print('❌ API Error: $e');
        TrackingManager.recordError(e, s);
        // Provide fallback analysis when API fails
        aiResult = _generateFallbackAnalysis();
      }
    } else {
      print('📱 Using cached recommendation');
      aiResult = data.healthRecommendation;
    }

    _aiResult = aiResult ?? _generateFallbackAnalysis();
    if (mounted) {
      setState(() {});
    }
  }

  String _generateFallbackAnalysis() {
    final hba1c = widget.data.hba1c;
    final rangeLabel = widget.data.rangeType.title;
    final measurementDate = widget.data.dateTime;

    // Format measurement date
    final dateFormat = DateFormat('dd/MM/yyyy');
    final formattedDate = dateFormat.format(measurementDate);

    String analysis =
        "Chỉ số HbA1c ${hba1c.toStringAsFixed(1)}% ($rangeLabel) đo ngày $formattedDate. ";

    // Main advice based on HbA1c level
    if (hba1c <= 6.5) {
      analysis +=
          "Đây là một kết quả tuyệt vời! Chỉ số HbA1c của bạn nằm trong mức lý tưởng, cho thấy không có nguy cơ tiểu đường. Hãy duy trì lối sống lành mạnh hiện tại với chế độ ăn cân bằng và tập thể dục đều đặn.";
    } else if (hba1c <= 7.0) {
      analysis +=
          "Chỉ số này cho thấy việc kiểm soát đường huyết đang tốt, tuy nhiên có nguy cơ tiền tiểu đường thấp. Tiếp tục duy trì chế độ ăn uống lành mạnh và tập luyện thể dục đều đặn.";
    } else if (hba1c <= 8.0) {
      analysis +=
          "Chỉ số này đang ở mức cao, có nguy cơ tiểu đường. Cần cải thiện lối sống và chế độ ăn uống. Hãy tham khảo ý kiến bác sĩ về điều chỉnh thuốc và chế độ sinh hoạt để đạt mục tiêu tốt hơn.";
    } else {
      analysis +=
          "Chỉ số này đang ở mức rất cao, có nguy cơ tiểu đường type 2 nghiêm trọng. Cần được theo dõi và điều trị chặt chẽ. Vui lòng liên hệ ngay với bác sĩ điều trị để được tư vấn và điều trị kịp thời.";
    }

    return analysis;
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
      // Update HbA1C with final note and files if needed
      // You can implement similar to blood pressure update API

      // Mark user as not first time after completing HbA1C input
      await AppStorages.setHbA1COnboardingCompleted();

      // Complete smart goal
      HomeClient().completeSmartGoal(
          DateTime.now(), '', 1, ScheduleType.hba1c_recommend.typeIndex);

      // Notify observers FIRST to ensure home refreshes data
      Observable.instance.notifyObservers(
        [],
        notifyName: "hba1c_change_data",
        map: {'isNew': widget.data.isNew},
      );

      // Small delay to let home start refreshing
      await Future.delayed(Duration(milliseconds: 50));

      // Then navigate to HbA1c Dashboard
      Navigator.pushNamedAndRemoveUntil(
        context,
        NavigatorName.hba1c_dashboard,
        (route) => route.isFirst,
        arguments: {
          'currentValue': widget.data.hba1c,
          'currentLevel': widget.data.rangeType.title,
          'currentColor': widget.data.rangeType.color,
        },
      );
    } catch (e, s) {
      TrackingManager.recordError(e, s);
    } finally {
      BotToast.closeAllLoading();
    }
  }

  void _doShare() {
    // TODO: share functionality
  }

  void _doBack() {
    Observable.instance.notifyObservers(
      [],
      notifyName: "hba1c_change_data",
      map: {'isNew': widget.data.isNew},
    );
    Navigator.pop(context);
  }

  void _doGuide() async {
    // Navigate to HbA1C guide page
    Navigator.of(context).pushNamed(NavigatorName.hba1c_intro_2nd_page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  _appBarSection(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16).copyWith(
                        bottom: _isKeyboardVisible ? 68 : 0,
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                            bottom: _isKeyboardVisible ? 30 : 80),
                        child: _hba1cResultSection(),
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
      ),
    );
  }

  Widget _appBarSection() {
    String formattedDateTime =
        DateFormat('HH:mm - dd/MM/yyyy').format(widget.data.dateTime);
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        formattedDateTime,
        style: TextStyle(
            fontFamily: R.font.sfpro,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: R.color.white,
            letterSpacing: 0.2),
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
                  style: TextStyle(
                      fontFamily: R.font.sfpro,
                      color: R.color.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.46,
                      letterSpacing: 0.4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hba1cResultSection() {
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
                  hba1c: widget.data.hba1c,
                  rangeLabel: widget.data.rangeType.title,
                  rangeColor: widget.data.rangeType.color,
                  rangeType: widget.data.rangeType,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAIResult(),
        const SizedBox(height: 16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.ai_suggestion_glucose.tr(),
                style: TextStyle(
                  fontFamily: R.font.sfpro,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Image.asset(R.drawable.ic_info, width: 18, height: 18),
            ],
          ),
          const SizedBox(height: 8),
          if (_aiResult == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const AILoadingTextWidget(),
            )
          else ...[
            Text(
              _aiResult ?? '',
              style: TextStyle(
                fontFamily: R.font.sfpro,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: R.color.primaryGreyColor,
                height: 1.46,
              ),
            ),
            const SizedBox(height: 16),
            // AI Help button for HbA1C
            Container(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () {
                  // Navigate to AI health assistant
                  Navigator.pushNamed(
                      context, NavigatorName.conversation_chatbot_ai);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  backgroundColor: const Color(0xFFDCFFFC),
                  foregroundColor: const Color(0xFF008479),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Trò chuyện cùng Trợ lý Sống khỏe",
                      style: TextStyle(
                        fontFamily: R.font.sfpro,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF008479),
                        height: 1.46,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // const Icon(
                    //   Icons.arrow_forward,
                    //   color: Color(0xFF008479),
                    //   size: 18,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _noteSection() {
    return SectionAddNote(
      controllerNote: _controllerNote,
      maxMedia: 5,
      key: _sectionAddNoteKey,
      initialFiles: _files,
      noteTitle: R.string.ghi_chu.tr(),
      horizontalPadding: 12,
    );
  }

  Widget _bottomSection() {
    return ElevatedButton(
      onPressed: _doComplete,
      child: Text(
        R.string.completed.tr(),
        style: TextStyle(
            fontFamily: R.font.sfpro,
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: R.color.greenGradientBottom,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size(double.infinity, 48),
      ),
    );
  }
}

class _SegmentedCircularGauge extends StatelessWidget {
  final List<double> rangeValue;
  final double hba1c;
  final String rangeLabel;
  final int indexRange;
  final Color rangeColor;
  final HbA1CRangeType rangeType;

  const _SegmentedCircularGauge({
    required this.rangeValue,
    required this.hba1c,
    required this.rangeLabel,
    required this.indexRange,
    required this.rangeColor,
    required this.rangeType,
  });

  @override
  Widget build(BuildContext context) {
    double startAngle = 155;
    double endAngle = 385;

    // Scale list rangeValue
    List<double> scaleList = rangeValue.map((e) => e.toDouble()).toList();
    double minValue = scaleList.first;
    double maxValue = scaleList.last;

    // From minValue to maxValue, separate equally
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

    return Container(
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
            radiusFactor: 0.95,
            axisLineStyle: AxisLineStyle(
              thickness: 0,
            ),
            ranges: <GaugeRange>[
              // Full background range
              GaugeRange(
                startValue: minValue,
                endValue: renderMaxValue,
                color: Color(0xFFE6ECF1),
                startWidth: 30,
                endWidth: 30,
              ),
              // Active range on top
              if (indexRange < scaleListRendering.length - 1)
                GaugeRange(
                  startValue: scaleListRendering[indexRange],
                  endValue: scaleListRendering[indexRange + 1],
                  color: rangeColor,
                  startWidth: 30,
                  endWidth: 30,
                ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 175,
                      ),
                      child: Text(
                        rangeLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: R.font.sfpro,
                          fontSize: 34,
                          color: rangeColor,
                          fontWeight: FontWeight.w700,
                          height: 1.22,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        text: '${hba1c.toString()}',
                        style: TextStyle(
                          fontFamily: R.font.sfpro,
                          fontSize: 18,
                          color: Color(0xFF111515),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                        children: [
                          TextSpan(
                            text: ' %',
                            style: TextStyle(
                              fontFamily: R.font.sfpro,
                              fontSize: 18,
                              color: Color(0xFF636A6B),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.2,
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
