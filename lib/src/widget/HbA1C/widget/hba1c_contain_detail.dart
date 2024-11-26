import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_lastestSumary.dart';
import 'package:medical/src/widget/HbA1C/hba1c_detail_tabbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../widgets/network_image_widget.dart';

class HbA1CDetail extends StatefulWidget {
  HbA1CDetail({Key? key}) : super(key: key);
  @override
  HbA1CDetailState createState() => HbA1CDetailState();
}

class HbA1CDetailState extends State<HbA1CDetail>
    with AutomaticKeepAliveClientMixin<HbA1CDetail> {
  @override
  bool get wantKeepAlive => true;
  late BuildContext currentContext;

  int periodFilterType = 1;

  @override
  void initState() {
    periodFilterType =
        Hba1cDetailTabbarController.of(context)!.periodFilterType;
    super.initState();
  }

  reloadData(int periodFilter) {
    periodFilterType = periodFilter;
    BlocProvider.of<HbA1CBloc>(currentContext).add(FetchHbA1C(
        currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        periodFilterType: periodFilterType));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider<HbA1CBloc>(
        create: (context) => HbA1CBloc(),
        child: BlocBuilder<HbA1CBloc, HbA1CState>(
            builder: (BuildContext context, HbA1CState state) {
          currentContext = context;
          LastestSummaryModel? model;
          if (state is HbA1CInitial) {
            BlocProvider.of<HbA1CBloc>(context).add(FetchHbA1C(
                currentDateTime: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                periodFilterType: periodFilterType));
          }
          if (state is HbA1CError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is HbA1CLoading) {
            return SizedBox();
          }
          if (state is HbA1CLoaded) {
            model = state.lastestSummaryModel;
          }
          return model == null
              ? Container(height: 400)
              : Container(
                  child: Column(
                    children: [
                      Stack(children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 20, bottom: 24),
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(R.string.gan_nhat.tr(),
                                        style: TextStyle(
                                            color: R.color.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700)),
                                  ]),
                              SizedBox(height: 14),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        model.hbA1C == 0 || model.hbA1C == null
                                            ? Text('--',
                                                style: TextStyle(
                                                    color: R.color.textDark,
                                                    fontSize: 34,
                                                    fontWeight:
                                                        FontWeight.w700))
                                            : Text(
                                                model.hbA1C
                                                    .toString()
                                                    .split('.')
                                                    .join(','),
                                                style: TextStyle(
                                                    fontFamily: 'Viga',
                                                    color: toColor(
                                                        model.percentColor),
                                                    fontSize: 34,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                        Text('%',
                                            style: TextStyle(
                                                color: model.hbA1C == 0 ||
                                                        model.hbA1C == null
                                                    ? R.color.textDark
                                                    : toColor(
                                                        model.percentColor),
                                                fontSize: 24,
                                                fontWeight: FontWeight.w700)),
                                        SizedBox(width: 8),
                                        Text(
                                            model.differentPercentage == 0 ||
                                                    model.differentPercentage ==
                                                        null
                                                ? ''
                                                : (model.differentPercentage! >
                                                        0
                                                    ? '(+${model.differentPercentage}%)'
                                                    : '(${model.differentPercentage}%)'),
                                            style: TextStyle(
                                                color: R.color.primaryGreyColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w400)),
                                      ],
                                    ),
                                    model.hbA1C == 0 || model.hbA1C == null
                                        ? SizedBox()
                                        : Container(
                                            height: 32,
                                            padding: EdgeInsets.only(
                                                left: 14, right: 14),
                                            decoration: BoxDecoration(
                                                color: toColor(
                                                    model.backgroundColor),
                                                border: Border.all(
                                                    color: model.borderColor ==
                                                            'None'
                                                        ? R.color.transparent
                                                        : toColor(
                                                            model.borderColor),
                                                    width: model.borderColor ==
                                                            'None'
                                                        ? 0
                                                        : 1),
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(13),
                                                    topRight:
                                                        Radius.circular(13),
                                                    bottomLeft:
                                                        Radius.circular(13))),
                                            child: Center(
                                              child: Text(model.status!,
                                                  style: TextStyle(
                                                      color: toColor(
                                                          model.fontColor),
                                                      fontWeight:
                                                          FontWeight.w600)),
                                            ))
                                  ]),
                              // SizedBox(height: ư14),
                              // Stack(
                              //     alignment: AlignmentDirectional.bottomEnd,
                              //     children: [
                              //       Container(
                              //           padding: EdgeInsets.only(
                              //               top: 16, right: 16, left: 16),
                              //           decoration: BoxDecoration(
                              //             color: R.color.white,
                              //             borderRadius: BorderRadius.circular(16),
                              //           ),
                              //           child: Row(
                              //             mainAxisAlignment:
                              //                 MainAxisAlignment.spaceBetween,
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.end,
                              //             children: [
                              //               Expanded(
                              //                 child: Row(
                              //                   children: [
                              //                     Expanded(
                              //                       child: Column(
                              //                         crossAxisAlignment:
                              //                             CrossAxisAlignment
                              //                                 .start,
                              //                         // mainAxisAlignment:
                              //                         //     MainAxisAlignment.spaceBetween,
                              //                         children: [
                              //                           Text(R.string.detail.tr(),
                              //                               style: TextStyle(
                              //                                   color:
                              //                                       R.color.black,
                              //                                   fontSize: 16,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .w700)),
                              //                           SizedBox(height: 8),
                              //                           Text(model.description!,
                              //                               style: TextStyle(
                              //                                   color: R.color.textDark,
                              //                                   fontSize: 15,
                              //                                   fontWeight:
                              //                                       FontWeight
                              //                                           .w400)),
                              //                           SizedBox(height: 16)
                              //                         ],
                              //                       ),
                              //                     ),
                              //                   ],
                              //                 ),
                              //               ),
                              //               SizedBox(width: 115),
                              //             ],
                              //           )),
                              //       Padding(
                              //           padding: EdgeInsets.only(right: 16),
                              //           child: model.imageUrl == null
                              //               ? SizedBox()
                              //               : NetWorkImageWidget(imageUrl: model.imageUrl!.url!,
                              //                   fit: BoxFit.fill))
                              //     ]),
                            ]),
                          ),
                        ),
                      ]),
                    ],
                  ),
                );
        }));
  }
}
