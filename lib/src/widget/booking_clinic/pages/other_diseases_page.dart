import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class OtherDiseasesPage extends StatefulWidget {
  final List<ClinicSpecialty> specialties;
  const OtherDiseasesPage({
    Key? key,
    required this.specialties,
  }) : super(key: key);

  @override
  _OtherDiseasesPageState createState() => _OtherDiseasesPageState();
}

class _OtherDiseasesPageState extends State<OtherDiseasesPage> {
  late DsmesAppointmentCubit _cubit;

  Map<String, bool> isProcessing = {
    'clinicDetail': false,
    'onlineConsult': false,
    'clinicConsult': false,
  };

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('[POP] offline clinics pop');
        DsmesNavigationMixin.navigationKey.currentState?.pop(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: R.color.backgroundColorNew,
          ),
          child: _buildPage(context),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
              stops: [0.01, 0.99],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: CustomAppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              R.string.benh_khac.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  // fontFamily: 'sfpro',
                  color: R.color.white),
            ),
            actions: [
              // GestureDetector(
              //   onTap: () async {
              //     DsmesNavigationMixin.navigationKey.currentState
              //         ?.pushNamed(NavigatorName.dsmes_booking_history);
              //   },
              //   child: Container(
              //     width: 90,
              //     height: 33,
              //     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              //     margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(8),
              //       color: R.color.color0xffECFFFD,
              //       border: Border.all(
              //         color: R.color.color0xffA4E3DD,
              //       ),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         SvgPicture.asset(
              //           R.icons.ic_clock,
              //           width: 16,
              //           height: 16,
              //           color: R.color.color0xff239A90,
              //           fit: BoxFit.scaleDown,
              //         ),
              //         GapW(4),
              //         Text(
              //           R.string.consulting_history.tr(),
              //           style: TextStyle(
              //             fontSize: 14,
              //             // fontFamily: 'sfpro',
              //             fontWeight: FontWeight.w700,
              //             color: R.color.color0xff239A90,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
            leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.arrow_back,
                color: R.color.white,
              ),
              onPressed: () {
                DsmesNavigationMixin.navigationKey.currentState?.pop(context);
              },
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: _cubit.listSpecialty.length,
              itemBuilder: (context, index) {
                final specialty = _cubit.listSpecialty[index];
                return GestureDetector(
                  onTap: () {
                    _cubit.clearClinicProviders();
                    DsmesNavigationMixin.navigationKey.currentState?.pushNamed(
                        NavigatorName.clinic_providers,
                        arguments: {'specialtyId': specialty.id});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: R.color.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 6.7,
                          offset: Offset(3, 8),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          // padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: R.color.color0xffE7FDFB,
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              specialty.image == null
                                  ? R.drawable.ic_user_doctor
                                  : "${Utils.getHostDocosanUrl()}${specialty.image}",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        GapH(8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            specialty.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: R.color.color0xff111515,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )),
        ),
      ],
    );
  }
}
