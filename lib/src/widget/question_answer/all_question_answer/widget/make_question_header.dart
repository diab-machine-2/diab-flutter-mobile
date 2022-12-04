import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';

class MakeQuestionHeader extends StatefulWidget {
  final VoidCallback callback;

  MakeQuestionHeader({
    Key? key,
    required this.callback,
  }) : super(key: key);
  @override
  _MakeQuestionHeaderState createState() => _MakeQuestionHeaderState();
}

class _MakeQuestionHeaderState extends State<MakeQuestionHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await TrackingManager.analytics.logEvent(
          name: 'cta_button_clicked',
          parameters: {
            "screen_name": 'qna_home',
            'component_name': 'cta_qna_add_question',
          },
        );
        widget.callback();
      },
      child: Container(
        height: 78,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                height: 66,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  color: R.color.white,
                  elevation: 2,
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 32),
                        Text(
                          R.string.ask_doctor.tr(),
                          style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                        Image.asset(R.drawable.ic_right,
                            width: 16,
                            height: 16,
                            color: R.color.greenGradientBottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 5,
              child: Image.asset(R.drawable.ic_doctor, width: 66, height: 66),
            ),
          ],
        ),
      ),
    );
  }
}
