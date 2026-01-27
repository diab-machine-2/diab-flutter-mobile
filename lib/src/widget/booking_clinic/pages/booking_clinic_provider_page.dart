import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/helper/booking_clinic_helper.dart';
import 'package:medical/src/widget/booking_clinic/model/booking_clinic_provider_model.dart';
import 'package:medical/src/widget/booking_clinic/pages/empty_clinic_provider_page.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BookingClinicProvidersPage extends StatefulWidget {
  final int specialtyId;
  final String? examinationType;
  const BookingClinicProvidersPage({
    Key? key,
    required this.specialtyId,
    this.examinationType,
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
  Set<String> selectedTimeframes = {};
  Set<String> selectedServiceTypes = {};

  final ValueNotifier<bool> _showAllCities = ValueNotifier(false);
  final Set<CityModel> _selectedOtherCities = {};

  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<CityModel>> _filteredCities =
      ValueNotifier<List<CityModel>>([]);

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _initData();
    _searchController.addListener(_handleSearch);
    _initializeFilteredCities();
  }

  void _initializeFilteredCities() {
    final cities = getListCityModel();
    final defaultCities = getDefaultCities();
    _filteredCities.value =
        cities.where((city) => !defaultCities.contains(city)).toList();

    // Set default "All" selection
    selectedTypes.add('');
    selectedTimeframes.add('');
    selectedServiceTypes.add('');
  }

  void _handleSearch() {
    _searchQuery.value = _searchController.text;
    final query = _searchController.text.toLowerCase();
    final cities = getListCityModel();
    final defaultCities = getDefaultCities();

    _filteredCities.value = cities.where((city) {
      return !defaultCities.contains(city) &&
          (city.nameVi.toLowerCase().contains(query) ||
              city.nameEn.toLowerCase().contains(query));
    }).toList();
  }

  _initData() async {
    try {
      isLoading = true;
      final position = await AppSettings.getPositionPreferences();

      String lat = '';
      String lng = '';

      if (position != null && position.isNotEmpty) {
        final split = position.split(',');
        if (split.length == 2) {
          lat = split[0];
          lng = split[1];
        }
      }

      _cubit.initSearchBookingClinicListRequest(
        page: 1,
        specialtyId:
            widget.specialtyId == 0 ? '' : widget.specialtyId.toString(),
        lat: lat,
        lng: lng,
        name: widget.examinationType != null
            ? "${widget.examinationType}"
            : '',
      );

      final request = _cubit.searchBookingClinicListRequest;
      if (request == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // For normal booking flow, rely on global BlocConsumer in BookingClinicPage
      // to show BotToast loading. For examination flow, manage BotToast here
      // because the global listener is disabled when isExamination = true.
      final isExaminationFlow = widget.examinationType != null;
      if (isExaminationFlow) {
        BotToast.showLoading(allowClick: false);
      }

      await _cubit.searchBookingClinicList(
        request: request,
        isRefresh: true,
        showLoading: !isExaminationFlow,
      );
    } catch (e) {
      // Log error if needed
    } finally {
      setState(() {
        isLoading = false;
      });
      if (widget.examinationType != null) {
        BotToast.closeAllLoading();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQuery.dispose();
    _filteredCities.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        DsmesNavigationMixin.getNavigationKey().currentState?.pop(context);
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
          child: Drawer(
            backgroundColor: R.color.white,
            child: _buildDistrictFilter(),
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
              _buildFilterButton(),
            ],
            leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.arrow_back,
                color: R.color.white,
              ),
              onPressed: () {
                // Check if we're in edit mode (coming from confirm page)
                final route = ModalRoute.of(context)?.settings;
                final args = route?.arguments as Map<String, dynamic>?;
                final isEditing = args?['isEditing'] ?? false;
                final previousRoute = args?['previousRoute'] as String?;

                // If editing from confirm page, pop back to confirm
                if (isEditing &&
                    previousRoute == NavigatorName.dsmes_confirm_information) {
                  DsmesNavigationMixin.getNavigationKey().currentState?.pop();
                  return;
                }

                // For examination flow, close the whole booking container and
                // return to the activity tab (root navigator). For normal flow,
                // just pop within the DSMES navigator.
                if (widget.examinationType != null) {
                  Navigator.of(context, rootNavigator: true).pop();
                } else {
                  DsmesNavigationMixin.getNavigationKey()
                      .currentState
                      ?.pop(context);
                }
              },
            ),
          ),
        ),
        // _buildHeaderWidget(),

        Expanded(
          // For initial loading we rely on BotToast (triggered by searchBookingClinicList
          // with showLoading: true). To avoid duplicate indicators, keep the
          // content area empty while loading.
          child: isLoading
              ? Container()
              : _cubit.listBookingClinicProvider.isEmpty
                  ? BookingClinicEmptyWidget(
                      imagePath: R.drawable.bg_empty_clinic,
                      title: R.string.empty_clinic_content.tr(),
                      subtitle: "",
                    )
                  : SmartRefresher(
                      controller: _refreshController,
                      enablePullUp: _cubit.clinicProviderHasMore,
                      enablePullDown: false,
                      footer: _cubit.clinicProviderHasMore
                          ? ClassicFooter(
                              loadingText: "Đang tải",
                              canLoadingText:
                                  R.string.pull_up_to_load_more.tr(),
                            )
                          : null,
                      onLoading: () async {
                        await _cubit.searchBookingClinicList(
                            request: _cubit.searchBookingClinicListRequest!
                                .copyWith(
                                    page: _cubit.clinicProviderCurrentPage + 1),
                            showLoading: false);
                        _refreshController.loadComplete();
                        setState(() {});
                      },
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            children: [
                              ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount:
                                    _cubit.listBookingClinicProvider.length,
                                separatorBuilder: (context, index) => GapH(12),
                                itemBuilder: (context, index) {
                                  BookingClinicProvider data =
                                      _cubit.listBookingClinicProvider[index];
                                  return _buildClinicItem(data);
                                },
                              ),
                              GapH(16),
                            ],
                          ),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  _buildFilterButton() {
    return Builder(
      builder: (context) {
        final isFiltered = selectedDistricts.isNotEmpty ||
            (selectedTypes.length >= 1 && !selectedTypes.contains('')) ||
            (selectedTimeframes.length >= 1 &&
                !selectedTimeframes.contains('')) ||
            (selectedServiceTypes.length >= 1 &&
                !selectedServiceTypes.contains(''));

        return GestureDetector(
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12, right: 16),
                padding: EdgeInsets.fromLTRB(6, 8, 8, 8),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt_outlined,
                      size: 20,
                      color: R.color.greenGradientBottom,
                    ),
                    GapW(2),
                    Text(
                      R.string.loc.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                  ],
                ),
              ),
              if (isFiltered)
                Positioned(
                  top: 8,
                  right: 12,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: R.color.white,
                        width: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  _handleViewClinicDetailInfo(BookingClinicProvider data) async {
    final detailSuccess = await _cubit.getClinicDetail(id: data.id);
    final rateSuccess = await _cubit.getClinicRate(id: data.id);
    if (detailSuccess && rateSuccess) {
      DsmesNavigationMixin.getNavigationKey()
          .currentState
          ?.pushNamed(NavigatorName.dsmes_clinic_detail, arguments: {
        'clinicId': data.id,
        'bookingType': Const.BOOKING_TYPE_CLINIC
      });
    }
  }

  _buildClinicItem(BookingClinicProvider data) {
    return GestureDetector(
      onTap: () async {
        if (isProcessing['clinicDetail']!) return;
        isProcessing['clinicDetail'] = true;
        try {
          _handleViewClinicDetailInfo(data);
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(R.drawable.ic_map_marker,
                                width: 14, height: 14),
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
                                  _handleViewClinicDetailInfo(data);
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

                                // Show loading for examination flow
                                if (widget.examinationType != null) {
                                  BotToast.showLoading(allowClick: false);
                                }

                                try {
                                  final detailSuccess =
                                      await _cubit.getClinicDetail(
                                          id: data.id,
                                          isLoading:
                                              widget.examinationType == null);

                                  if (!detailSuccess ||
                                      _cubit.selectedClinic == null) {
                                    if (widget.examinationType != null) {
                                      BotToast.closeAllLoading();
                                    }
                                    return;
                                  }

                                  // Set examination data if it's an examination flow
                                  if (widget.examinationType != null) {
                                    _cubit.setExaminationData(
                                      isExamination: true,
                                      examinationType: widget.examinationType,
                                      examinationLocation: Const.EXAMINATION_LOCATION_CLINIC,
                                    );
                                  }

                                  // Check if we're in edit mode (coming from confirm page)
                                  final route =
                                      ModalRoute.of(context)?.settings;
                                  final args =
                                      route?.arguments as Map<String, dynamic>?;
                                  final isEditing = args?['isEditing'] ?? false;
                                  final previousRoute =
                                      args?['previousRoute'] as String?;

                                  // If editing from confirm page, pop back to confirm
                                  if (isEditing &&
                                      previousRoute ==
                                          NavigatorName
                                              .dsmes_confirm_information) {
                                    DsmesNavigationMixin.getNavigationKey()
                                        .currentState
                                        ?.pop();
                                    return;
                                  }

                                  _cubit.initCreateDsmesBookingRequest(
                                      locale: context.locale.languageCode,
                                      clearExamination:
                                          widget.examinationType == null);

                                  // Delay navigation slightly to ensure nested navigator is ready
                                  if (widget.examinationType != null) {
                                    await Future.delayed(
                                        Duration(milliseconds: 100));
                                  }

                                  // Navigate to datetime selection (same flow for both examination and normal booking)
                                  await DsmesNavigationMixin.getNavigationKey()
                                      .currentState
                                      ?.pushNamed(
                                          NavigatorName
                                              .dsmes_booking_select_date,
                                          arguments: {
                                        'serviceType': DsmesAppointmentMode
                                            .telemedicine
                                            .toString(),
                                        'action': 'create',
                                        'bookingType':
                                            Const.BOOKING_TYPE_CLINIC,
                                        'isMergedSchedule': false,
                                      });
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
                          ? R.color.greenGradientBottom
                          : R.color.transparent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Builder(
            builder: (context) {
              final isFiltered = selectedDistricts.isNotEmpty ||
                  (selectedTypes.length == 1 && !selectedTypes.contains('')) ||
                  (selectedTimeframes.length == 1 &&
                      !selectedTimeframes.contains('')) ||
                  (selectedServiceTypes.length == 1 &&
                      !selectedServiceTypes.contains(''));
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openEndDrawer();
                },
                child: Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: isFiltered ? EdgeInsets.only(right: 10) : null,
                        child: Text(
                          R.string.loc.tr(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: R.color.color0xff95682E,
                          ),
                        ),
                      ),
                    ),
                    if (isFiltered)
                      Positioned(
                        top: 2,
                        right: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildDistrictFilter() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showAllCities,
      builder: (context, showAll, _) {
        if (showAll) {
          return _buildAllCitiesDrawer();
        }
        return _buildDrawerContent();
      },
    );
  }

  Widget _buildDrawerContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      R.string.khu_vuc.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 5 / 1,
                      children: [
                        ...getDefaultCities().map((e) =>
                            _buildFilterItem(e.nameVi, e.slug, 'district')),
                        if (_selectedOtherCities.isNotEmpty)
                          ..._selectedOtherCities.map((city) =>
                              _buildFilterItem(
                                  city.nameVi, city.slug, 'district')),
                        InkWell(
                          onTap: () {
                            _syncSelectedCities();
                            _showAllCities.value = true;
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: R.color.color0xffF7F8F8,
                              border: Border.all(
                                color: R.color.transparent,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              R.string.more.tr(),
                              style: TextStyle(
                                color: R.color.color0xff111515,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GapH(24),
                    Text(
                      R.string.clinic_type.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 5 / 1,
                      children: [
                        ...Const.CLINIC_TYPES.map((type) {
                          return _buildFilterItem(
                              getClinicTypeDisplay(type), type, 'type');
                        }).toList(),
                        _buildFilterItem(R.string.all.tr(), '', 'type'),
                      ],
                    ),
                    GapH(24),
                    Text(
                      R.string.thoi_gian.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 5 / 1,
                      children: [
                        ...Const.CLINIC_TIMEFRAMES.map((timeframe) {
                          return _buildFilterItem(
                              getClinicTimeframeDisplay(timeframe),
                              timeframe,
                              'timeframe');
                        }).toList(),
                        _buildFilterItem(R.string.all.tr(), '', 'timeframe'),
                      ],
                    ),
                    GapH(24),
                    Text(
                      R.string.hinh_thuc.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 5 / 1,
                      children: [
                        ...DsmesAppointmentMode.values.map((serviceType) {
                          return _buildFilterItem(
                              getClinicServiceTypeDisplay(serviceType),
                              serviceType.toString(),
                              'serviceType');
                        }).toList(),
                        _buildFilterItem(R.string.all.tr(), '', 'serviceType'),
                      ],
                    ),
                    GapH(80),
                  ],
                ),
              ),
            ],
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

  void _syncSelectedCities() {
    // Clear the current selections
    _selectedOtherCities.clear();

    // Add cities that are in selectedDistricts
    if (selectedDistricts.isNotEmpty) {
      for (String slug in selectedDistricts) {
        final city = getListCityModel()
            .where(
              (city) => city.slug == slug,
            )
            .firstOrNull;
        if (city != null) {
          _selectedOtherCities.add(city);
        }
      }
    }
  }

  Widget _buildAllCitiesDrawer() {
    return Stack(
      children: [
        Column(
          children: [
            AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: R.color.color0xff111515),
                onPressed: () {
                  _showAllCities.value = false;
                  _searchController.clear();
                },
              ),
              backgroundColor: R.color.white,
              title: Text(
                R.string.khu_vuc.tr(),
                style: TextStyle(
                  color: R.color.color0xff111515,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              centerTitle: false,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              actions: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      // Clear existing district selections
                      selectedDistricts.clear();

                      // Add only currently selected cities
                      for (CityModel city in _selectedOtherCities) {
                        selectedDistricts.add(city.slug);
                      }
                    });

                    _showAllCities.value = false;
                    _searchController.clear();
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 16, 0),
                    child: Text(
                      R.string.apply.tr(),
                      style: TextStyle(
                        color: R.color.color0xff95682E,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: R.string.tim_khu_vuc.tr(),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: R.color.color0xffDFE4E4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: R.color.color0xffDFE4E4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: R.color.color0xffDFE4E4),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<CityModel>>(
                valueListenable: _filteredCities,
                builder: (context, cities, _) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 5 / 1,
                        children: cities.map((city) {
                          return _buildCityItem(city, 'district');
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCityItem(CityModel city, String filterType) {
    final isSelected = _selectedOtherCities.contains(city);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedOtherCities.remove(city);
          } else {
            _selectedOtherCities.add(city);
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: R.color.color0xffF7F8F8,
          border: Border.all(
            color:
                isSelected ? R.color.greenGradientBottom : R.color.transparent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          city.nameVi,
          style: TextStyle(
            color: isSelected
                ? R.color.greenGradientBottom
                : R.color.color0xff111515,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
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
                  selectedTimeframes.clear();
                  selectedServiceTypes.clear();
                  _selectedOtherCities.clear();

                  // Set default is choosing 'All'
                  selectedTypes.add('');
                  selectedTimeframes.add('');
                  selectedServiceTypes.add('');
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
                    R.string.clear_filter.tr(),
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
              onTap: () async {
                final districts =
                    selectedDistricts.where((item) => item.isNotEmpty).toList();
                final clinicTypes =
                    selectedTypes.where((item) => item.isNotEmpty).toList();
                final timeframes = selectedTimeframes
                    .where((item) => item.isNotEmpty)
                    .toList();
                final serviceTypes = selectedServiceTypes
                    .where((item) => item.isNotEmpty)
                    .toList();

                _cubit.updateSearchBookingClinicListRequestUrlKeyword(
                    urlKeywords: districts);

                _cubit.updateSearchBookingClinicListRequestClinicTypes(
                    clinicTypes: clinicTypes);

                _cubit.updateSearchBookingClinicListRequestTimeframes(
                    timeframes: timeframes);

                _cubit.updateSearchBookingClinicListRequestServiceTypes(
                    serviceTypes: serviceTypes);

                final request = _cubit.searchBookingClinicListRequest;
                if (request == null) {
                  return;
                }
                await _cubit.searchBookingClinicList(
                    request: request, isRefresh: true);
                setState(() {});
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
                    R.string.apply.tr(),
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
    Set<String> selectedValues = {};
    if (filterType == 'district') {
      selectedValues = selectedDistricts;
    } else if (filterType == 'type') {
      selectedValues = selectedTypes;
    } else if (filterType == 'timeframe') {
      selectedValues = selectedTimeframes;
    } else if (filterType == 'serviceType') {
      selectedValues = selectedServiceTypes;
    }

    bool isSelected = selectedValues.contains(value);

    return InkWell(
      onTap: () {
        setState(() {
          if (filterType == 'type') {
            if (value.isEmpty) {
              // When "All" is selected
              selectedTypes.clear();
              selectedValues.add(value);
            } else {
              if (isSelected) {
                selectedValues.remove(value);
              } else {
                selectedValues.add(value);
              }
              // Remove "All" option if any specific type is selected
              selectedTypes.remove('');
            }
          }

          if (filterType == 'timeframe') {
            if (value.isEmpty) {
              // When "All" is selected
              selectedTimeframes.clear();
              selectedValues.add(value);
            } else {
              if (isSelected) {
                selectedValues.remove(value);
              } else {
                selectedValues.add(value);
              }
              // Remove "All" option if any specific timeframe is selected
              selectedTimeframes.remove('');
            }
          }

          if (filterType == 'serviceType') {
            if (value.isEmpty) {
              // When "All" is selected
              selectedServiceTypes.clear();
              selectedValues.add(value);
            } else {
              if (isSelected) {
                selectedValues.remove(value);
              } else {
                selectedValues.add(value);
              }
              // Remove "All" option if any specific service type is selected
              selectedServiceTypes.remove('');
            }
          }

          if (filterType == 'district') {
            // Single selection for districts
            if (isSelected) {
              selectedValues.remove(value);
              _selectedOtherCities.removeWhere((city) => city.slug == value);
            } else {
              selectedValues.add(value);
            }
          }
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: R.color.color0xffF7F8F8,
          border: Border.all(
            color:
                isSelected ? R.color.greenGradientBottom : R.color.transparent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected
                ? R.color.greenGradientBottom
                : R.color.color0xff111515,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
