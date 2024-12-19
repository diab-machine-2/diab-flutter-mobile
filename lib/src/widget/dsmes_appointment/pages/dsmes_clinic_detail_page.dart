import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DsmesClinicDetailPage extends StatefulWidget {
  final int clinicId;
  const DsmesClinicDetailPage({
    Key? key,
    required this.clinicId,
  }) : super(key: key);

  @override
  _DsmesClinicDetailPageState createState() => _DsmesClinicDetailPageState();
}

class _DsmesClinicDetailPageState extends State<DsmesClinicDetailPage> {
  final RefreshController _controller = RefreshController();
  late DsmesAppointmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _cubit.getClinicDetail(id: widget.clinicId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: _buildPage(context),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            R.string.center_information.tr(),
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                // fontFamily: 'sfpro',
                color: R.color.textDark),
          ),
          actions: [],
          leadingIcon: IconButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            icon: Icon(
              Icons.arrow_back,
              color: R.color.textDark,
            ),
            onPressed: () {
              DsmesNavigationMixin.navigationKey.currentState?.pop(context);
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  _buildClinicItem(_cubit.selectedClinic!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildClinicItem(DsmesClinicModel data) {
    final locale = context.locale.languageCode;
    final goodAtList = data.getGoodAtByLocale(locale);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                    width: 72,
                    child: Image.network(
                        "${Utils.getHostDocosanUrl()}${data.avatar}")),
                GapW(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GapH(8),
                      Container(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: data.specialty.map((e) {
                            return Container(
                                height: 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: R.color.color0xffFAF0D2,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  e.info.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: R.color.color0xffA36E2A,
                                  ),
                                ));
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GapH(12),
            Container(
              height: 70,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(R.drawable.map_location_bg),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 6,
                    child: Text(
                      data.address,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      width: 111,
                      decoration: BoxDecoration(
                        color: R.color.color0xff00B83D,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(R.drawable.ic_map_direction),
                          ),
                          GapW(5),
                          Text(
                            R.string.view_map,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: R.color.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
