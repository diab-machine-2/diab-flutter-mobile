import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/bloc/emotion/emotion_bloc.dart';
import 'package:medical/bloc/glucose/glucose_bloc.dart';
import 'package:medical/modal/emotion/input_emotion_model.dart';
import 'package:medical/modal/glucose/glucose_input.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/base/custom_appbar.dart';
import 'package:medical/widget/helper/helper.dart';
import 'package:medical/widget/helper/show_message.dart';

class EmotionTableController extends StatefulWidget {
  final String title;
  final String emotionId;
  final int periodFilterType;
  EmotionTableController(
      {@required this.title,
      @required this.emotionId,
      @required this.periodFilterType});
  @override
  _EmotionTableControllerState createState() => _EmotionTableControllerState();
}

BuildContext currentContext;

int periodFilterType = 1;

class _EmotionTableControllerState extends State<EmotionTableController> {
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 45) / 3;
    return BlocProvider<EmotionBloc>(
        create: (context) => EmotionBloc(),
        child: BlocBuilder<EmotionBloc, EmotionState>(
            builder: (BuildContext context, EmotionState state) {
          currentContext = context;
          List<InputEmotionModel> model;
          if (state is EmotionInitial) {
            BlocProvider.of<EmotionBloc>(context).add(FetchInputEmotion(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: periodFilterType.toString(),
                emotionId: widget.emotionId,
                page: 1));
          }
          if (state is EmotionError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is EmotionLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is EmotionLoaded) {
            model = state.inputModel.inputs;
          }
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.white,
              body: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/background_splash.png'),
                    fit: BoxFit.cover,
                  )),
                  child: Column(
                    children: [
                      CustomAppBar(
                        // leading: SizedBox(),
                        leadingIcon: IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            icon: Icon(Icons.close, color: textDark),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        backgroundColor: Colors.transparent, //No more green
                        title: Text(widget.title,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: textDark)),
                      ),
                      Container(
                        color: Color(0xffB1DDDB),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: width + width / 4,
                                  child: Text('Thời gian',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width,
                                  child: Text('Khung giờ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width - width / 4,
                                  child: Center(
                                      child: Text('Cảm xúc',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600)))),
                            ],
                          ),
                        ),
                      ),
                      model == null
                          ? Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(bottom: 8),
                                  itemCount: model.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        height: 1, color: Color(0xffE5E5E5));
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final time = model[index].date;
                                    final timeFrame =
                                        model[index].timeFrameText;
                                    final icon =
                                        model[index].emotionIcon.url ?? '';

                                    return _buildItem(
                                        context, index, time, timeFrame, icon);
                                  }),
                            ),
                    ],
                  )),
            ),
          );
        }));
  }

  Widget _buildItem(BuildContext context, int index, int time, String timeFrame,
      String icon) {
    final width = (MediaQuery.of(context).size.width - 45) / 3;
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 16, bottom: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: width + width / 4,
                        child: Text(convertToUTC(time, 'HH:mm - dd/MM'),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        width: width,
                        child: Text(timeFrame,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        width: width - width / 4,
                        child: Center(
                            child: Image.network(icon, width: 30, height: 30)),
                      )
                    ],
                  ),
                ),
                // index != data.length - 1
                //     ? Container(height: 1, width: 380, color: Color(0xffD6D8E0))
                //     : SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// }
