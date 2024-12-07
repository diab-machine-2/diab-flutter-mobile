import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class AddBloodSugarResult extends StatefulWidget {
  const AddBloodSugarResult({super.key, required this.dateTime});
  final DateTime dateTime;

  @override
  State<AddBloodSugarResult> createState() => _AddBloodSugarResultState();
}

class _AddBloodSugarResultState extends State<AddBloodSugarResult> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(R.drawable.bg_splash),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _appBarSection(),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _glucoseResultSection(),
            ),
            Expanded(child: SizedBox()),
            Padding(
              padding: EdgeInsets.only(
                bottom: 8 + MediaQuery.of(context).padding.bottom / 2,
                left: 16,
                right: 16,
              ),
              child: _bottomSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBarSection() {
    String formattedDateTime = DateFormat('HH:mm - dd/MM/yyyy').format(widget.dateTime);
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text(
        formattedDateTime,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: R.color.textDark),
      ),
      leadingIcon: IconButton(
        splashColor: R.color.transparent,
        highlightColor: R.color.transparent,
        icon: Icon(Icons.arrow_back, color: R.color.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        GestureDetector(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Image.asset(R.drawable.ic_help_outlined, width: 24, height: 24),
          ),
        ),
      ],
    );
  }

  Widget _glucoseResultSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // TODO: chart
          Container(
            height: 200,
            width: 250,
            child: _SegmentedCircularGauge(),
          ),

          const SizedBox(height: 24),
          // button add note
          _buildNoteOrAddNoteSection(),

          const SizedBox(height: 24),
          // result
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Gợi ý từ Trợ lý Sống khỏe',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: R.color.textDark,
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {},
                child: Image.asset(R.drawable.ic_speak_text, width: 24, height: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mức đường huyết sau ăn của bạn lúc 12h hôm nay là 280 mg/dL, cao hơn mức bình thường. Đổi với người mắc bệnh đái tháo đường, mức đường huyết sau ăn thường nên ở dưới 180 mg/dL để đảm bảo kiểm soát tốt bệnh và ngẫn ngừa các biến chứng.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: R.color.primaryGreyColor,
              height: 16 / 12,
            ),
          ),

          const SizedBox(height: 16),
          // elevated button, ic_zalo and text, full width
          ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(R.drawable.ic_social_zalo, width: 24, height: 24),
                const SizedBox(width: 4),
                Text(
                  'Chat với Chuyên gia sức khoẻ',
                  style: TextStyle(
                    color: R.color.mainColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: R.color.color0xffE1FAF8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteOrAddNoteSection() {
    // TODO: show note if have
    return ElevatedButton(
      onPressed: () {
        // TODO: show dialog add note
      },
      child: Text(
        R.string.them_ghi_chu.tr(),
        style: TextStyle(color: R.color.dark, fontSize: 13, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: R.color.color0xffF2F6F9,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        fixedSize: const Size(128, 32),
        elevation: 0,
      ),
    );
  }

  Widget _bottomSection() {
    // two elevated button, one is primary, one is secondary, full width
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: share
            },
            child: Text(R.string.share.tr(), style: TextStyle(color: R.color.textDark)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // TODO: save
            },
            child: Text(R.string.completed.tr(), style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: R.color.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedCircularGauge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SfRadialGauge(
          backgroundColor: Colors.white,
          axes: <RadialAxis>[
            RadialAxis(
              startAngle: 135,
              endAngle: 405,
              minimum: 0,
              maximum: 200,
              showLabels: false,
              showTicks: false,
              axisLineStyle: AxisLineStyle(
                thickness: 0,
                thicknessUnit: GaugeSizeUnit.logicalPixel,
                cornerStyle: CornerStyle.bothFlat,
              ),
              ranges: <GaugeRange>[
                // Segment 1
                GaugeRange(
                  startValue: 0,
                  endValue: 39,
                  color: Colors.grey.shade200,
                  startWidth: 10,
                  endWidth: 10,
                ),
                // Segment 2
                GaugeRange(
                  startValue: 41,
                  endValue: 79,
                  color: Colors.grey.shade200,
                  startWidth: 10,
                  endWidth: 10,
                ),
                // Segment 3
                GaugeRange(
                  startValue: 81,
                  endValue: 119,
                  color: Colors.grey.shade200,
                  startWidth: 10,
                  endWidth: 10,
                ),
                // Segment 4
                GaugeRange(
                  startValue: 121,
                  endValue: 159,
                  color: Colors.red,
                  startWidth: 10,
                  endWidth: 10,
                ),
                // Segment 5
                GaugeRange(
                  startValue: 161,
                  endValue: 200,
                  color: Colors.grey.shade200,
                  startWidth: 10,
                  endWidth: 10,
                ),
              ],
              pointers: <GaugePointer>[
                MarkerPointer(
                  value: 140, // Current value
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
                        'Trước ăn',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cao',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '135 mg/dL',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  positionFactor: 0.1,
                  angle: 90,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
