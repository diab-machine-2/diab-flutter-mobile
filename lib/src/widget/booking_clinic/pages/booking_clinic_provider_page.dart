import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/model/booking_clinic_provider_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BookingClinicProvidersPage extends StatefulWidget {
  final int specialtyId;
  const BookingClinicProvidersPage({
    Key? key,
    required this.specialtyId,
  }) : super(key: key);

  @override
  _BookingClinicProvidersPageState createState() =>
      _BookingClinicProvidersPageState();
}

class _BookingClinicProvidersPageState
    extends State<BookingClinicProvidersPage> {
  late DsmesAppointmentCubit _cubit;
  Map<String, bool> isProcessing = {
    'clinicDetail': false,
    'viewInfo': false,
    'bookingClinic': false,
  };
  bool isLoading = false;
  final RefreshController _refreshController = RefreshController();
  int _selectedIndex = 0;

  Set<String> selectedDistricts = {};
  Set<String> selectedTypes = {};

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _initData();
  }

  _initData() async {
    isLoading = true;

    _cubit.initSearchBookingClinicListRequest(
        page: 1, specialtyId: widget.specialtyId.toString());

    final request = _cubit.searchBookingClinicListRequest;
    if (request == null) {
      return;
    }

    await _cubit.searchBookingClinicList(
        request: request, isRefresh: true, showLoading: true);
    setState(() {
      isLoading = false;
    });
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
        endDrawerEnableOpenDragGesture: false,
        body: Container(
          decoration: BoxDecoration(
            color: R.color.backgroundColorNew,
          ),
          child: _buildPage(context),
        ),
        endDrawer: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          color: R.color.white,
          child: Drawer(
            child: _buildDrawerContent(),
          ),
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
              R.string.chon_noi_kham.tr(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  // fontFamily: 'sfpro',
                  color: R.color.white),
            ),
            actions: [
              SizedBox.shrink(),
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
        _buildHeaderWidget(),
        Expanded(
          child: SmartRefresher(
            controller: _refreshController,
            enablePullUp: _cubit.clinicProviderHasMore,
            enablePullDown: false,
            footer: _cubit.clinicProviderHasMore
                ? ClassicFooter(
                    loadingText: "Đang tải",
                    canLoadingText: R.string.pull_up_to_load_more.tr(),
                  )
                : null,
            onLoading: () async {
              await _cubit.searchBookingClinicList(
                  request: _cubit.searchBookingClinicListRequest!
                      .copyWith(page: _cubit.clinicProviderCurrentPage + 1),
                  showLoading: false);
              _refreshController.loadComplete();
              setState(() {});
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _cubit.listBookingClinicProvider.length,
                      separatorBuilder: (context, index) => GapH(16),
                      itemBuilder: (context, index) {
                        BookingClinicProvider data =
                            _cubit.listBookingClinicProvider[index];
                        return _buildClinicItem(data);
                      },
                    ),
                    GapH(20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildClinicItem(BookingClinicProvider data) {
    return GestureDetector(
      onTap: () async {
        if (isProcessing['clinicDetail']!) return;
        isProcessing['clinicDetail'] = true;
        try {
          await _cubit.getClinicDetail(id: data.id);
          await _cubit.getClinicRate(id: data.id);
          DsmesNavigationMixin.navigationKey.currentState?.pushNamed(
              NavigatorName.dsmes_clinic_detail,
              arguments: {'clinicId': data.id, 'bookingType': 'clinic'});
        } finally {
          isProcessing['clinicDetail'] = false;
        }
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [Utils.getBoxShadowDropCard()],
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
                          data.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GapH(10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(R.drawable.ic_map_marker,
                                width: 12, height: 12),
                            GapW(5),
                            Flexible(
                              child: Text(
                                data.address ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: R.color.color0xff777E90,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              GapH(12),
              Container(
                width: double.infinity,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: data.specialty.take(3).map((e) {
                    return Container(
                        height: 21,
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              GapH(16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                if (isProcessing['viewInfo']!) return;
                                isProcessing['viewInfo'] = true;
                                try {
                                  await _cubit.getClinicDetail(id: data.id);
                                  await _cubit.getClinicRate(id: data.id);
                                  DsmesNavigationMixin
                                      .navigationKey.currentState
                                      ?.pushNamed(
                                          NavigatorName.dsmes_clinic_detail,
                                          arguments: {
                                        'clinicId': data.id,
                                        'bookingType': 'clinic'
                                      });
                                } finally {
                                  isProcessing['viewInfo'] = false;
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: R.color.color0xffE7FDFB,
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                child: Text(
                                  R.string.view_information.tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.greenGradientBottom,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GapW(12),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                if (isProcessing['bookingClinic']!) return;
                                isProcessing['bookingClinic'] = true;
                                try {
                                  // await _cubit.getClinicDetail(id: data.id);
                                  // if (_cubit.selectedClinic == null) return;
                                  // _cubit.initCreateDsmesBookingRequest(
                                  //     locale: context.locale.languageCode);
                                  // await DsmesNavigationMixin
                                  //     .navigationKey.currentState
                                  //     ?.pushNamed(
                                  //         NavigatorName
                                  //             .dsmes_booking_select_date,
                                  //         arguments: {
                                  //       'serviceType': widget.serviceType,
                                  //       'action': 'create',
                                  //     });
                                } finally {
                                  isProcessing['bookingClinic'] = false;
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      R.color.greenGradientTop02,
                                      R.color.greenGradientBottom
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  R.string.submit_booking.tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: R.color.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildHeaderWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      R.string.all.tr(),
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? R.color.greenGradientBottom
                            : R.color.color0xff111515,
                        fontSize: 15,
                        fontWeight: _selectedIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    Container(
                      height: 3,
                      width: 40,
                      color: _selectedIndex == 0
                          ? R.color.greenGradientBottom
                          : R.color.transparent,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      R.string.da_kham.tr(),
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? R.color.greenGradientBottom
                            : R.color.color0xff111515,
                        fontSize: 15,
                        fontWeight: _selectedIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    Container(
                      height: 3,
                      width: 60,
                      color: _selectedIndex == 1
                          ? Color(0xFF008479)
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: Text(
                R.string.loc.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff95682E,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDrawerContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Flexible(
            child: Column(
              children: [
                AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: R.color.color0xff111515,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  backgroundColor: R.color.white,
                  actions: [SizedBox.shrink()],
                  title: Text(
                    R.string.filter.tr(),
                    style: TextStyle(
                      color: R.color.color0xff111515,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                  titleSpacing: 0,
                  automaticallyImplyLeading: false,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'District',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 5 / 1,
                        children: [
                          _buildFilterItem(
                              'TP. Hồ Chí Minh', 'tp-ho-chi-minh', 'district'),
                          _buildFilterItem('Hà Nội', 'ha-noi', 'district'),
                          _buildFilterItem('Đà Nẵng', 'da-nang', 'district'),
                          _buildFilterItem('Khác', 'others', 'district'),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Clinic Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 5 / 1,
                        children: [
                          _buildFilterItem('Phòng khám', 'clinic', 'type'),
                          _buildFilterItem('Bệnh viện tư', 'hospital', 'type'),
                          _buildFilterItem(
                              'Bệnh viện công', 'public_hospital', 'type'),
                          _buildFilterItem('Tất cả', '', 'type'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildFilterButtons(),
        ),
      ],
    );
  }

  Widget _buildFilterButtons() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedDistricts.clear();
                  selectedTypes.clear();
                });
              },
              child: Container(
                height: 43,
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                    color: R.color.greenGradientBottom,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          GapW(12),
          Flexible(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                String districts = selectedDistricts.join(',');
                String types = selectedTypes.join(',');

                _cubit.searchBookingClinicListRequest = _cubit
                    .searchBookingClinicListRequest
                    ?.copyWith(urlKeyword: districts, type: types, page: '1');
                _initData();
                Navigator.pop(context);
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
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
                    'Apply',
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

  Widget _buildFilterItem(String displayText, String value, String filterType) {
    Set<String> selectedValues =
        filterType == 'district' ? selectedDistricts : selectedTypes;
    bool isSelected = selectedValues.contains(value);

    return InkWell(
      onTap: () {
        setState(() {
          if (filterType == 'type' && value.isEmpty) {
            selectedTypes.clear();
            selectedTypes.add(value);
          } else if (isSelected) {
            selectedValues.remove(value);
          } else {
            if (filterType == 'type' && selectedTypes.contains('')) {
              selectedTypes.clear();
            }
            selectedValues.add(value);
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xFF008479) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? Color(0xFF008479) : Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
