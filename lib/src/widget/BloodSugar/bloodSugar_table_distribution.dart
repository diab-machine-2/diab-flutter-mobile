import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class BloodSugarDistribuitonTableController extends StatefulWidget {
  final String title;
  final int timeFrameType;
  final int periodFilterType;
  final int glucoseDistributionType;
  BloodSugarDistribuitonTableController(
      {@required this.title,
      @required this.timeFrameType,
      @required this.periodFilterType,
      @required this.glucoseDistributionType});
  @override
  _BloodSugarDistribuitonTableControllerState createState() =>
      _BloodSugarDistribuitonTableControllerState();
}

BuildContext currentContext;

int periodFilterType = 1;

class _BloodSugarDistribuitonTableControllerState
    extends State<BloodSugarDistribuitonTableController> {
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 45) / 3;
    return BlocProvider<GlucoseBloc>(
        create: (context) => GlucoseBloc(),
        child: BlocBuilder<GlucoseBloc, GlucoseState>(
            builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          List<InputGlucoseModel> model;
          if (state is GlucoseInitial) {
            BlocProvider.of<GlucoseBloc>(context).add(FetchInputGlucose(
                currentDateTime:
                    (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
                periodFilterType: widget.periodFilterType.toString(),
                glucoseDistributionType:
                    widget.glucoseDistributionType.toString()));
          }
          if (state is GlucoseError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is GlucoseLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is GlucoseAlllLoaded) {
            model = state.inputGlucoseModel;
          }
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: R.color.white,
              body: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(R.drawable.background_splash),
                    fit: BoxFit.cover,
                  )),
                  child: Column(
                    children: [
                      CustomAppBar(
                        // leading: SizedBox(),
                        leadingIcon: IconButton(
                            splashColor: R.color.transparent,
                            highlightColor: R.color.transparent,
                            icon: Icon(Icons.close, color: R.color.textDark),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        backgroundColor: R.color.transparent, //No more green
                        title: Text(
                            'Nhóm đường huyết ' + widget.title.toLowerCase(),
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: R.color.textDark)),
                      ),
                      model == null
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Expanded(
                              child: ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(bottom: 8),
                                  itemCount: model.length + 1,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        height: 1, color: R.color.color0xffE5E5E5);
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index == 0) {
                                      return Container(
                                        color: R.color.color0xffB1DDDB,
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: width + width / 4,
                                                child: Text('Thời gian',
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                              Container(
                                                width: width,
                                                child: Text('Khung giờ',
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                              Container(
                                                width: width - width / 4,
                                                child: Center(
                                                  child: Text('Chỉ số',
                                                      style: TextStyle(
                                                          color: R.color.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      final time = model[index - 1].createDate;
                                      final timeFrame =
                                          model[index - 1].timeFrame;
                                      final glucose =
                                          roundNumber(model[index - 1].glucose);
                                      final color =
                                          model[index - 1].backgroundColor;
                                      return _buildItem(context, time,
                                          timeFrame, glucose, color);
                                    }
                                  }),
                            ),
                    ],
                  )),
            ),
          );
        }));
  }

  Widget _buildItem(BuildContext context, int time, String timeFrame,
      String glucose, String color) {
    final width = (MediaQuery.of(context).size.width - 45) / 3;
    return Container(
      child: Column(
        children: [
          Container(
            color: R.color.white,
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
                        child: Text(
                            toWeek(time) +
                                '' +
                                convertToUTC(time, '-dd/MM/yyyy'),
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
                          child: Text(glucose,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: toColor(color))),
                        ),
                      )
                    ],
                  ),
                ),
                // index != data.length - 1
                //     ? Container(height: 1, width: 380, color: R.color.color0xffD6D8E0)
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
