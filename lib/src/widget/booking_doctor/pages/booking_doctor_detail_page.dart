import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/dsmes_clinic_rating_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_doctor/model/booking_doctor_model.dart';
import 'package:medical/src/widget/booking_doctor/widgets/html_view_text_expandable.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widget/dsmes_appointment/widgets/dsmes_empty_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BookingDoctorDetailPage extends StatefulWidget {
  final int clinicId;
  final int doctorId;
  final String bookingType; // 'clinic' or 'center' or 'doctor'
  const BookingDoctorDetailPage({
    Key? key,
    required this.clinicId,
    required this.doctorId,
    this.bookingType = Const.BOOKING_TYPE_DOCTOR,
  }) : super(key: key);

  @override
  _BookingDoctorDetailPageState createState() =>
      _BookingDoctorDetailPageState();
}

class _BookingDoctorDetailPageState extends State<BookingDoctorDetailPage> {
  late DsmesAppointmentCubit _cubit;
  int _visibleComments = 3;
  bool _showingAll = false;
  Map<String, bool> isProcessing = {
    'doctorBooking': false,
  };

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
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
    return Stack(
      children: [
        Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    R.color.greenGradientTop02,
                    R.color.greenGradientBottom
                  ],
                  stops: [0.01, 0.99],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  R.string.center_information.tr(),
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      // fontFamily: 'sfpro',
                      color: R.color.white),
                ),
                actions: [],
                leadingIcon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                    Icons.arrow_back,
                    color: R.color.white,
                  ),
                  onPressed: () {
                    DsmesNavigationMixin.getNavigationKey()
                        .currentState
                        ?.pop(context);
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      _cubit.selectedDoctor != null
                          ? _buildDoctorItem(_cubit.selectedDoctor!)
                          : Center(
                              child: DsmesEmptyWidget(
                                imagePath: R.drawable.bg_empty_clinic,
                                title: R.string.not_exist_clinic.tr(),
                                titleColor: R.color.color0xff636A6B,
                                subtitle: "",
                              ),
                            ),
                      GapH(24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_cubit.selectedDoctor != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBookingDoctorActionButtons(),
          ),
      ],
    );
  }

  ServiceData? _getLowestPriceService(BookingDoctorModel data) {
    if (data.serviceList.categories.isEmpty) {
      print('DEBUG: No service categories found');
      return null;
    }

    // Get all services from all categories
    List<ServiceData> allServices = [];
    for (var category in data.serviceList.categories) {
      allServices.addAll(category.data);
    }

    if (allServices.isEmpty) {
      print('DEBUG: No services found in any category');
      return null;
    }

    // Filter out services with null or zero prices
    final servicesWithPrice = allServices
        .where((service) => service.fromPrice != null && service.fromPrice > 0)
        .toList();

    print('DEBUG: Services with valid prices: ${servicesWithPrice.length}');

    if (servicesWithPrice.isEmpty) {
      // If no services have prices, return the first service or null
      print('DEBUG: No services with valid prices, returning first service');
      return allServices.isNotEmpty ? allServices.first : null;
    }

    // Find the service with the lowest fromPrice
    final result = servicesWithPrice.reduce(
        (current, next) => current.fromPrice < next.fromPrice ? current : next);

    print(
        'DEBUG: Lowest price service: "${result.name}" - ${result.fromPrice}');
    return result;
  }

  _buildDoctorItem(BookingDoctorModel data) {
    final locale = context.locale.languageCode;
    final goodAtList = data.getGoodAtByLocale(locale);
    final educationList = data.education ?? [];

    final lowestPriceService = _getLowestPriceService(data);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 72,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                          "${Utils.getHostDocosanUrl()}${data.avatar}"),
                    )),
                GapW(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDoctorNameWithPrefix(data),
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
                          children: data.specialty.take(3).map((e) {
                            return Container(
                                height: 20,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: R.color.color0xffFAF0D2,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  e.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: R.color.color0xffA36E2A,
                                  ),
                                ));
                          }).toList(),
                        ),
                      ),
                      if (lowestPriceService != null) ...[
                        GapH(12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${Utils.formatMoney(lowestPriceService.fromPrice)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: R.color.greenGradientBottom,
                              ),
                            ),
                            GapW(12),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Color(0xFFBFC6C6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            GapW(12),
                            Text(
                              '30 ${R.string.minute.tr()}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: R.color.greenGradientBottom,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (data.experience != null && data.experience!.isNotEmpty)
              GapH(24),
            if (data.experience != null && data.experience!.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(R.drawable.ic_introduce),
                      ),
                      GapW(8),
                      Flexible(
                        child: Text(
                          R.string.introduce.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  GapH(8),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        Utils.getBoxShadowDropCard(),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    child: ExpandableHtmlWidget(
                      htmlContent: data.experience ?? '',
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
            GapH(24),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(R.drawable.ic_archivement),
                    ),
                    GapW(8),
                    Flexible(
                      child: Text(
                        R.string.doctor_good_at.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                GapH(8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      Utils.getBoxShadowDropCard(),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Text(
                    goodAtList.map((e) => e.name).join('  |  '),
                    style: TextStyle(
                      fontSize: 15,
                      color: R.color.color0xff111515,
                    ),
                  ),
                ),
              ],
            ),
            if (educationList.isNotEmpty) GapH(24),
            if (educationList.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(R.drawable.ic_education),
                      ),
                      GapW(8),
                      Flexible(
                        child: Text(
                          R.string.training.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        Utils.getBoxShadowDropCard(),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Column(
                      children: [
                        ...educationList.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.name,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                            color: R.color.color0xff111515),
                                      ),
                                      GapH(4),
                                      Text(
                                        e.value,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: R.color.color0xff636A6B,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            GapH(24),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(R.drawable.ic_language),
                    ),
                    GapW(8),
                    Flexible(
                      child: Text(
                        R.string.language.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                GapH(8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      Utils.getBoxShadowDropCard(),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Wrap(
                    spacing: 12, // Gap width between items
                    runSpacing: 8, // Gap between rows if items wrap
                    children: data.language.map((e) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            Utils.getLanguageFlag(e),
                            width: 20,
                            height: 20,
                            fit: BoxFit.scaleDown,
                          ),
                          GapW(8), // Gap between flag and text
                          Text(
                            Utils.getLanguageName(e),
                            style: TextStyle(
                              fontSize: 15,
                              color: R.color.color0xff111515,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: _cubit.listClinicReview.isNotEmpty,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GapH(24),
                  Row(
                    children: [
                      Text(
                        R.string.customer_rating.tr(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  GapH(12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        Utils.getBoxShadowDropCard(),
                      ],
                    ),
                    child: Column(
                      children: [
                        ..._cubit.listClinicReview
                            .take(_visibleComments)
                            .map((e) {
                          return Column(
                            children: [
                              _buildCommentItem(e),
                              if (e.id !=
                                  _cubit.listClinicReview
                                      .take(_visibleComments)
                                      .last
                                      .id)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14.0, horizontal: 12),
                                  child: Divider(
                                    color: R.color.color0xffDFE4E4,
                                  ),
                                )
                            ],
                          );
                        }).toList(),
                        if (_cubit.listClinicReview.length > 3)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (_showingAll) {
                                      _visibleComments = 3;
                                      _showingAll = false;
                                    } else {
                                      _visibleComments += 3;
                                      if (_visibleComments >=
                                          _cubit.listClinicReview.length) {
                                        _visibleComments =
                                            _cubit.listClinicReview.length;
                                        _showingAll = true;
                                      }
                                    }
                                  });
                                },
                                child: Text(
                                  _showingAll
                                      ? R.string.show_less.tr()
                                      : R.string.show_more.tr(),
                                  style: TextStyle(
                                    color: R.color.color0xff95682E,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GapH(16),
          ],
        ),
      ),
    );
  }

  _buildCommentItem(ClinicReview data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          child: Image.asset(R.drawable.ic_avatar),
        ),
        GapW(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    data.ratingName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GapW(4),
                  Row(
                    children: List.generate(
                      int.tryParse(data.rating) ?? 0,
                      (index) {
                        return Container(
                          height: 16,
                          width: 16,
                          margin: EdgeInsets.only(right: 4),
                          child: Image.asset(R.drawable.ic_star),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (data.suggestion.isNotEmpty) GapH(12),
              if (data.suggestion.isNotEmpty)
                Container(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: data.suggestion.map((e) {
                      return Container(
                          height: 20,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: R.color.color0xffEDEEEE,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            ClinicReview.getSuggestionText(
                                e, context.locale.languageCode),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: R.color.color0xff636A6B,
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              GapH(12),
              Text(
                data.comment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff141416,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildBookingDoctorActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          Utils.getBoxShadowDropButton(),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () async {
                if (isProcessing['doctorBooking']!) return;
                isProcessing['doctorBooking'] = true;
                try {
                  await _cubit.getClinicDetail(id: widget.clinicId);
                  if (_cubit.selectedClinic == null) return;
                  _cubit.initCreateDsmesBookingRequest(
                      locale: context.locale.languageCode);

                  _cubit.updateBookingDoctorInfoCreateRequest(
                      doctorId: _cubit.selectedDoctor!.id);

                  await DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.pushNamed(NavigatorName.dsmes_booking_select_date,
                          arguments: {
                        'serviceType':
                            DsmesAppointmentMode.telemedicine.toString(),
                        'action': 'create',
                        'bookingType': Const.BOOKING_TYPE_DOCTOR,
                      });
                } finally {
                  isProcessing['doctorBooking'] = false;
                }
              },
              child: Container(
                height: 44,
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                decoration: BoxDecoration(
                  color: R.color.mainColor,
                  borderRadius: BorderRadius.circular(200),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientMid,
                      R.color.greenGradientBottom,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.submit_booking.tr(),
                    style: TextStyle(
                      color: R.color.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDoctorNameWithPrefix(BookingDoctorModel data) {
    String prefix = 'BS';
    final graduate = data.graduateName; // Map<String, String>? after parsing
    if (graduate != null) {
      final currentLocale = context.locale.languageCode;
      if (currentLocale == 'vi' && (graduate['name_vi'] ?? '').isNotEmpty) {
        prefix = graduate['name_vi']!;
      } else if (currentLocale == 'en' &&
          (graduate['name_en'] ?? '').isNotEmpty) {
        prefix = graduate['name_en']!;
      } else if ((graduate['name_vi'] ?? '').isNotEmpty) {
        prefix = graduate['name_vi']!;
      } else if ((graduate['name_en'] ?? '').isNotEmpty) {
        prefix = graduate['name_en']!;
      }
    }

    final display = (data.displayName != null && data.displayName!.isNotEmpty)
        ? data.displayName!
        : data.name;
    return '$prefix $display';
  }
}
