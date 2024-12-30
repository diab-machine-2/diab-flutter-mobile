import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/glucose/glucose_bloc.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/widget/BloodSugar/bloodSugar_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widgets/spacing_row.dart';

class BloodGlucoseItem extends StatefulWidget {
  const BloodGlucoseItem({
    Key? key,
  }) : super(key: key);

  @override
  State<BloodGlucoseItem> createState() => BloodGlucoseItemState();
}

class BloodGlucoseItemState extends State<BloodGlucoseItem>
    with AutomaticKeepAliveClientMixin<BloodGlucoseItem> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;
  int periodFilterType = 3;
  int trendTypeIndex = 1;

  @override
  void initState() {
    // TODO:
    periodFilterType =
        BloodSugarDetailTabbarController.of(context)?.periodFilterType ?? 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<GlucoseBloc>(
      create: (context) => GlucoseBloc(),
      child: BlocBuilder<GlucoseBloc, GlucoseState>(
          builder: (BuildContext context, GlucoseState state) {
        InputGlucoseModel? element;
        currentContext = context;

        if (state is GlucoseInitial) {
          BlocProvider.of<GlucoseBloc>(context).add(FetchInputGlucose(
            currentDateTime:
                (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
            periodFilterType: periodFilterType.toString(),
            page: 1,
            size: '1',
          ));
        }
        if (state is GlucoseAlllLoaded) {
          element = state.inputGlucoseModel.isNotEmpty
              ? state.inputGlucoseModel.first
              : null;
        }
        if (element == null) return SizedBox();
        return Padding(
          padding: EdgeInsets.all(15),
          child: SpacingColumn(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(R.string.gan_nhat.tr(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: R.color.white,
                  ),
                  child: SpacingColumn(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                    element.glucose!.round() ==
                                            element.glucose
                                        ? element.glucose!.round().toString()
                                        : element.glucose.toString(),
                                    style: TextStyle(
                                        fontFamily: 'Viga',
                                        color:
                                            toColor(element.backgroundColor),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400)),
                                SizedBox(width: 8),
                                Text(element.unit,
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                            Container(
                                height: 32,
                                padding: EdgeInsets.only(
                                    left: 18, right: 18, top: 8, bottom: 8),
                                decoration: BoxDecoration(
                                    color: element.backgroundColor == 'None'
                                        ? R.color.white
                                        : toColor(element.backgroundColor),
                                    border: Border.all(
                                        color: element.borderColor == 'None'
                                            ? R.color.transparent
                                            : toColor(element.borderColor),
                                        width: element.borderColor == 'None'
                                            ? 0
                                            : 1),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(13),
                                        topRight: Radius.circular(13),
                                        bottomLeft: Radius.circular(13))),
                                child: Center(
                                  child: Text(element.type!,
                                      style: TextStyle(
                                          color: element.fontColor == 'None'
                                              ? R.color.white
                                              : toColor(element.fontColor),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                ))
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Text(
                              convertToUTC(element.createDate!, 'HH:mm'),
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(', ${element.timeFrame}',
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                          ],
                        ),
                        element.reason != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  Container(
                                      height: 1,
                                      color: R.color.color0xffEEEFF3),
                                  SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${R.string.ly_do.tr()}: ',
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                      Expanded(
                                        child: Text(element.reason!,
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : SizedBox(),
                        if (element.note != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                text: R.string.ghi_chu.tr() + ' ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: R.color.black,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${element.note}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ])),
            ],
          ),
        );
      }),
    );
  }

  void reloadData(int periodFilter) {
    BlocProvider.of<GlucoseBloc>(currentContext).add(FetchInputGlucose(
      currentDateTime:
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString(),
      periodFilterType: periodFilter.toString(),
      page: 1,
      size: '1',
    ));
  }
}
