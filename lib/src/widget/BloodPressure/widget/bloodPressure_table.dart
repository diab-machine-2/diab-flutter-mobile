import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/bloodPressure/bloodPressure_bloc.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:easy_localization/easy_localization.dart';

class BloodPressureTableController extends StatefulWidget {
  final String? title;
  final int? bloodPressureType;
  final int? periodFilterType;
  final bool? isPulseRate;
  BloodPressureTableController(
      {required this.title,
      required this.bloodPressureType,
      required this.periodFilterType,
      required this.isPulseRate});
  @override
  _BloodPressureTableControllerState createState() =>
      _BloodPressureTableControllerState();
}

class _BloodPressureTableControllerState
    extends State<BloodPressureTableController> {
  BuildContext? currentContext;

  int periodFilterType = 1;
  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 32) / 3;
    return BlocProvider<BloodPressureBloc>(
        create: (context) => BloodPressureBloc(),
        child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
            builder: (BuildContext context, BloodPressureState state) {
          currentContext = context;
          List<BloodPressureModel>? model;
          if (state is BloodPressureInitial) {
            BlocProvider.of<BloodPressureBloc>(context).add(
                FetchInputBloodPressure(
                    currentDateTime:
                        (DateTime.now().millisecondsSinceEpoch ~/ 1000)
                            .toString(),
                    periodFilterType: widget.periodFilterType.toString(),
                    bloodPressureType: widget.bloodPressureType.toString()));
          }
          if (state is BloodPressureError) {
            Message.showToastMessage(context, state.message);
          }
          if (state is BloodPressureLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is BloodPressureDataLoaded) {
            model = state.bloodPressureModel;
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
                        title: Text(
                            widget.isPulseRate == null
                                ? widget.title!
                                : widget.isPulseRate!
                                    ? R.string.heart_rate.tr()
                                    : R.string.huyet_ap.tr(),
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
                                  width: width + width / 4,
                                  child: Text(R.string.thoi_gian.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width,
                                  child: Text(R.string.khung_gio.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600))),
                              Container(
                                  width: width - width / 4,
                                  child: Center(
                                      child: Text(R.string.chi_so.tr(),
                                          style: TextStyle(
                                              color: R.color.black,
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
                                        height: 1, color: R.color.color0xffE5E5E5);
                                  },
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final time = model![index].date!;
                                    final timeFrame = model[index].timeFrame!;
                                    final systolic =
                                        model[index].systolic!.toInt();
                                    final diastolic =
                                        model[index].diastolic!.toInt();
                                    final pulseRate =
                                        model[index].pulseRate!.toInt();
                                    return _buildItem(
                                        context,
                                        index,
                                        time,
                                        timeFrame,
                                        systolic,
                                        diastolic,
                                        pulseRate,
                                        model[index].color);
                                  }),
                            ),
                    ],
                  )),
            ),
          );
        }));
  }

  Widget _buildItem(BuildContext context, int index, int time, String timeFrame,
      int systolic, int diastolic, int pulseRate, String? color) {
    final width = (MediaQuery.of(context).size.width - 32) / 3;
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
                          child: Text(
                              widget.isPulseRate == null || !widget.isPulseRate!
                                  ? '$systolic/$diastolic'
                                  : pulseRate.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: widget.isPulseRate == null ||
                                          !widget.isPulseRate!
                                      ? toColor(color)
                                      : R.color.black)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// }
