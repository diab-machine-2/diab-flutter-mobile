import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_comparer.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/spacing_row.dart';

class BloodSugarTableCompareController extends StatefulWidget {
  final List<ComparerModel>? model;
  final int comparerType;
  final int periodFilterType;
  final String? title;
  BloodSugarTableCompareController({
    required this.model,
    required this.title,
    required this.comparerType,
    required this.periodFilterType,
  });
  @override
  _BloodSugarTableCompareControllerState createState() =>
      _BloodSugarTableCompareControllerState();
}

BuildContext? currentContext;

class _BloodSugarTableCompareControllerState
    extends State<BloodSugarTableCompareController> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 32) / 3;
    return BlocProvider<GlucoseBloc>(
        create: (context) => GlucoseBloc(),
        child: BlocBuilder<GlucoseBloc, GlucoseState>(
            builder: (BuildContext context, GlucoseState state) {
          currentContext = context;
          List<ComparerModel>? model;
          bool hasMore = true;
          int page = 1;
          if (state is GlucoseInitial) {
            _getData(context, page: 1);
          }
          if (state is GlucoseError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is GlucoseComparerLoaded) {
            model = state.listcomparer.reversed.toList();
            hasMore = state.hasMore ?? false;
            page = state.page ?? 1;
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
                    image: AssetImage(R.drawable.bg_splash),
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
                        title: Text(widget.title!,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: R.color.textDark)),
                      ),
                      Container(
                        color: R.color.color0xffB1DDDB,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  width: width - 10,
                                  child: Text(R.string.thoi_gian.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width + 10,
                                  child: Text(R.string.khung_gio.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width - 45,
                                  //alignment: Alignment.center,
                                  child: Center(
                                    child: Text(R.string.before_after.tr(),
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      model == null
                          ? Center(child: CircularProgressIndicator())
                          : Expanded(
                              child: SingleChildScrollView(
                                child: SpacingColumn(
                                  separator: Divider(
                                    height: 1,
                                    color: R.color.color0xffE5E5E5,
                                  ),
                                  children: model.map((item) {
                                    final time = item.date!;
                                    final preGlucose =
                                        item.preGlucose!.toInt().toString();
                                    final postGlucose =
                                        item.postGlucose!.toInt().toString();
                                    final preGlucoseColor =
                                        item.preGlucoseColor;
                                    final postGlucoseColor =
                                        item.postGlucoseColor;

                                    return _buildItem(
                                        context,
                                        time,
                                        preGlucose,
                                        postGlucose,
                                        preGlucoseColor,
                                        postGlucoseColor);
                                  }).toList()
                                    ..add(
                                      hasMore
                                          ? Container(
                                              padding: EdgeInsets.all(15),
                                              color: Colors.white,
                                              child: ButtonWidget(
                                                title: 'Xem thêm',
                                                onPressed: () => _getData(
                                                    context,
                                                    page: page),
                                              ),
                                            )
                                          : SizedBox(),
                                    ),
                                ),
                              ),
                            ),
                    ],
                  )),
            ),
          );
        }));
  }

  _getData(
    BuildContext context, {
    required int page,
  }) {
    BlocProvider.of<GlucoseBloc>(context).add(FetchComparerGlucose(
        currentDateTime:
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
        periodFilterType: widget.periodFilterType.toString(),
        page: 1,
        comparerType: widget.comparerType.toString()));
  }

  Widget _buildItem(BuildContext context, int time, String preGlucose,
      String postGlucose, String? preGlucoseColor, String? postGlucoseColor) {
    final width = (MediaQuery.of(context).size.width - 32) / 3;
    return Container(
      child: Column(
        children: [
          Container(
            color: R.color.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: width - 10,
                        child: Text(convertToUTC(time, 'HH:mm - dd/MM'),
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400)),
                      ),
                      Container(
                        width: width + 10,
                        child: Text(widget.title!,
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
