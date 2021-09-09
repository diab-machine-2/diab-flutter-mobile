import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/bloc/glucose/glucose_bloc.dart';
import 'package:medical/modal/glucose/glucose_comparer.dart';
import 'package:medical/theme/app_theme.dart';
import 'package:medical/widget/base/custom_appbar.dart';
import 'package:medical/widget/helper/helper.dart';

class BloodSugarTableCompareController extends StatefulWidget {
  final List<ComparerModel> model;
  final String title;
  BloodSugarTableCompareController({
    @required this.model,
    @required this.title,
  });
  @override
  _BloodSugarTableCompareControllerState createState() =>
      _BloodSugarTableCompareControllerState();
}

BuildContext currentContext;

int periodFilterType = 1;

class _BloodSugarTableCompareControllerState
    extends State<BloodSugarTableCompareController> {
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 32) / 3;
    return BlocProvider<GlucoseBloc>(
        create: (context) => GlucoseBloc(),
        child: BlocBuilder<GlucoseBloc, GlucoseState>(
            builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          List<ComparerModel> model;
          if (state is GlucoseInitial) {
            model = widget.model;
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
                                  width: width - 10,
                                  child: Text('Thời gian',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width + 10,
                                  child: Text('Khung giờ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width - 45,
                                  //alignment: Alignment.center,
                                  child: Center(
                                    child: Text('Trước/Sau',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      widget.model == null
                          ? Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.only(bottom: 8),
                                  itemCount: widget.model.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        height: 1, color: Color(0xffE5E5E5));
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final time = widget.model[index].date;
                                    final preGlucose = widget
                                        .model[index].preGlucose
                                        .toInt()
                                        .toString();
                                    final postGlucose = widget
                                        .model[index].postGlucose
                                        .toInt()
                                        .toString();
                                    final preGlucoseColor =
                                        widget.model[index].preGlucoseColor;
                                    final postGlucoseColor =
                                        widget.model[index].postGlucoseColor;

                                    return _buildItem(
                                        context,
                                        index,
                                        time,
                                        preGlucose,
                                        postGlucose,
                                        preGlucoseColor,
                                        postGlucoseColor);
                                  }),
                            ),
                    ],
                  )),
            ),
          );
        }));
  }

  Widget _buildItem(
      BuildContext context,
      int index,
      int time,
      String preGlucose,
      String postGlucose,
      String preGlucoseColor,
      String postGlucoseColor) {
    final width = (MediaQuery.of(context).size.width - 32) / 3;
    return Container(
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: width - 10,
                        // color: Colors.yellow,
                        child: Text(convertToUTC(time, 'HH:mm - dd/MM'),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        width: width + 10,
                        // color: Colors.blue,
                        child: Text(widget.title,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        width: width - 45,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$preGlucose',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: toColor(preGlucoseColor))),
                            Text('/',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: toColor(preGlucoseColor))),
                            Text('$postGlucose',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: toColor(postGlucoseColor))),
                          ],
                        ),
                      ),
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
