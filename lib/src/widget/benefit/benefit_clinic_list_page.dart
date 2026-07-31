import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/helper/booking_clinic_helper.dart';
import 'package:medical/src/widget/booking_clinic/model/booking_clinic_provider_model.dart';
import 'package:medical/src/widget/booking_clinic/pages/empty_clinic_provider_page.dart';
import 'package:medical/src/widget/booking_doctor/widgets/rating_heart_widget.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/benefit/benefit_navigator_scope.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Shows clinic list for the Benefit flow.
///
/// [bookingType] is either [Const.BENEFIT_BOOKING_AT_CLINIC] or
/// [Const.BENEFIT_BOOKING_TELEMEDICINE].
/// [clinicIds] filters the clinics to show only those matching the selected specialty.
/// [specialtyName] is the name of the selected specialty.
class BenefitClinicListPage extends StatefulWidget {
  final String bookingType;
  final List<String> clinicIds;
  final String? specialtyName;
  final String? itemId;
  final int? itemType;

  const BenefitClinicListPage({
    Key? key,
    required this.bookingType,
    required this.clinicIds,
    this.specialtyName,
    this.itemId,
    this.itemType,
  }) : super(key: key);

  @override
  _BenefitClinicListPageState createState() => _BenefitClinicListPageState();
}

class _BenefitClinicListPageState extends State<BenefitClinicListPage> {
  late DsmesAppointmentCubit _cubit;

  final RefreshController _refreshController = RefreshController();

  Map<String, bool> isProcessing = {
    'clinicDetail': false,
    'viewInfo': false,
    'bookingClinic': false,
  };

  // Currently selected specialty id. Empty string = "Tất cả"
  String _selectedSpecialtyId = '';

  bool get _isTelemedicine =>
      widget.bookingType == Const.BENEFIT_BOOKING_TELEMEDICINE;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _initData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    // Load clinics with clinicIds filter if provided
    await _loadClinics(specialtyId: '', isRefresh: true);
  }

  Future<void> _loadClinics({
    required String specialtyId,
    bool isRefresh = false,
  }) async {
    try {
      // String lat = '';
      // String lng = '';

      // var position = await AppSettings.getPositionPreferences();
      // if (position == null || position.isEmpty) {
      //   final geolocation = await determinePosition();
      //   if (geolocation != null) {
      //     await AppSettings.saveLocationPreferences(geolocation);
      //     position = '${geolocation.latitude},${geolocation.longitude}';
      //   }
      // }

      // if (position != null && position.isNotEmpty) {
      //   final split = position.split(',');
      //   if (split.length == 2) {
      //     lat = split[0];
      //     lng = split[1];
      //   }
      // }

      _cubit.initSearchBookingClinicListRequest(
        page: 1,
        specialtyId: specialtyId,
        // lat: lat,
        // lng: lng,
        kind: Const.BOOKING_TYPE_CLINIC,
        isFilterDistance: 0,
        clinicIds: widget.clinicIds,
      );

      // For telemedicine, restrict to clinics that support it
      if (_isTelemedicine) {
        _cubit.searchBookingClinicListRequest =
            _cubit.searchBookingClinicListRequest?.copyWith(
          svAvailable: ['telemedicine'],
        );
      }

      final request = _cubit.searchBookingClinicListRequest;
      if (request == null) return;

      await _cubit.searchBookingClinicList(
        request: request,
        isRefresh: isRefresh,
      );
    } catch (_) {}
  }

  void _onSelectSpecialty(String specialtyId) {
    if (_selectedSpecialtyId == specialtyId) return;
    setState(() {
      _selectedSpecialtyId = specialtyId;
    });
    _loadClinics(specialtyId: specialtyId, isRefresh: true);
  }

  Future<void> _handleViewClinicDetailInfo(BookingClinicProvider data) async {
    final detailSuccess = await _cubit.getClinicDetail(id: data.id);
    final rateSuccess = await _cubit.getClinicRate(id: data.id);
    if (detailSuccess && rateSuccess) {
      BenefitNavigatorScope.of(context)
          .currentState
          ?.pushNamed(NavigatorName.dsmes_clinic_detail, arguments: {
        'clinicId': data.id,
        'bookingType': Const.BOOKING_TYPE_CLINIC,
      });
    }
  }

  Future<void> _handleBookingClinic(BookingClinicProvider data) async {
    if (isProcessing['bookingClinic'] == true) return;
    isProcessing['bookingClinic'] = true;
    BotToast.showLoading(allowClick: false);

    try {
      final detailSuccess =
          await _cubit.getClinicDetail(id: data.id, isLoading: false);
      if (!detailSuccess || _cubit.selectedClinic == null) return;

      // Store branches for this clinic from clusters
      for (final cluster in _cubit.listClinicClusters) {
        if (cluster.clinicId == data.id) {
          _cubit.selectedClinicBranches = cluster.branches;
          break;
        }
      }

      _cubit.initCreateDsmesBookingRequest(
        locale: context.locale.languageCode,
        clearExamination: true,
      );

      final serviceType = _isTelemedicine
          ? DsmesAppointmentMode.telemedicine.toString()
          : DsmesAppointmentMode.atClinic.toString();

      await BenefitNavigatorScope.of(context)
          .currentState
          ?.pushNamed(NavigatorName.benefit_calendar, arguments: {
        'serviceType': serviceType,
        'action': 'create',
        'bookingType': Const.BENEFIT_BOOKING_AT_CLINIC,
        'specialtyName': widget.specialtyName,
        'itemId': widget.itemId,
        'itemType': widget.itemType,
      });
    } finally {
      BotToast.closeAllLoading();
      isProcessing['bookingClinic'] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        BenefitNavigatorScope.popOrRoot(context);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(color: R.color.backgroundColorNew),
          child: _buildPage(context),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    final pageTitle = _isTelemedicine ? 'Khám từ xa' : 'Đặt khám';

    return Column(
      children: [
        // App bar
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
              pageTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: R.color.white,
              ),
            ),
            leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.arrow_back, color: R.color.white),
              onPressed: () => BenefitNavigatorScope.popOrRoot(context),
            ),
          ),
        ),

        // // Specialty chips
        // _buildSpecialtyChips(),

        // Clinic list
        Expanded(
          child: BlocBuilder<DsmesAppointmentCubit, DsmesAppointmentState>(
            builder: (context, state) {
              if (state is DsmesAppointmentLoading &&
                  _cubit.listBookingClinicProvider.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_cubit.listBookingClinicProvider.isEmpty) {
                return BookingClinicEmptyWidget(
                  imagePath: R.drawable.bg_empty_clinic,
                  title: R.string.empty_clinic_content.tr(),
                  subtitle: '',
                );
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullUp: _cubit.clinicProviderHasMore,
                enablePullDown: false,
                footer: _cubit.clinicProviderHasMore
                    ? ClassicFooter(
                        loadingText: 'Đang tải',
                        canLoadingText: R.string.pull_up_to_load_more.tr(),
                      )
                    : null,
                onLoading: () async {
                  await _cubit.searchBookingClinicList(
                    request: _cubit.searchBookingClinicListRequest!.copyWith(
                      page: _cubit.clinicProviderCurrentPage + 1,
                    ),
                    showLoading: false,
                  );
                  _refreshController.loadComplete();
                },
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _cubit.listBookingClinicProvider.length,
                  separatorBuilder: (_, __) => GapH(12),
                  itemBuilder: (_, index) {
                    final data = _cubit.listBookingClinicProvider[index];
                    return _buildClinicItem(data);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyChips() {
    return BlocBuilder<DsmesAppointmentCubit, DsmesAppointmentState>(
      builder: (context, state) {
        final specialties = _cubit.listSpecialty;
        if (specialties.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // "Tất cả" chip
                _buildChip(
                  label: R.string.all.tr(),
                  isSelected: _selectedSpecialtyId == '',
                  onTap: () => _onSelectSpecialty(''),
                ),
                ...specialties.map((specialty) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildChip(
                        label: specialty.shortended ?? specialty.name,
                        isSelected:
                            _selectedSpecialtyId == specialty.id.toString(),
                        onTap: () =>
                            _onSelectSpecialty(specialty.id.toString()),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? R.color.greenGradientBottom
              : const Color(0xffF4F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : R.color.color0xff636A6B,
          ),
        ),
      ),
    );
  }

  Widget _buildClinicItem(BookingClinicProvider data) {
    return GestureDetector(
      onTap: () async {
        if (isProcessing['clinicDetail'] == true) return;
        isProcessing['clinicDetail'] = true;
        try {
          await _handleViewClinicDetailInfo(data);
        } finally {
          isProcessing['clinicDetail'] = false;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [Utils.getBoxShadowDropCard()],
        ),
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
                    child: NetWorkImageWidget(
                      imageUrl: '${Utils.getHostDocosanUrl()}${data.avatar}',
                      fallbackImageUrl: R.drawable.ic_error_lesson_image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                GapW(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GapH(10),
                      Row(
                        children: [
                          RatingHeartWidget(
                            rating: data.star ?? 5.0,
                            heartSize: 16,
                            spacing: 2,
                            filledColor: R.color.color0xffB4802D,
                            emptyColor: const Color(0xFFE0E0E0),
                          ),
                          GapW(6),
                          Text(
                            '${(data.star ?? 5.0).toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: R.color.color0xff5E6566,
                            ),
                          ),
                          GapW(4),
                          Text(
                            '(${data.totalReview ?? 0})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: R.color.color0xff5E6566,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            GapH(16),
            // if (!_isTelemedicine && (data.address?.isNotEmpty ?? false)) ...[
            //   Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Icon(
            //         Icons.location_pin,
            //         size: 16,
            //         color: R.color.color0xff5E6566,
            //       ),
            //       GapW(5),
            //       Flexible(
            //         child: Text(
            //           data.address ?? '',
            //           maxLines: 2,
            //           overflow: TextOverflow.ellipsis,
            //           style: TextStyle(
            //             fontSize: 15,
            //             fontWeight: FontWeight.w400,
            //             color: R.color.color0xff5E6566,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            //   GapH(8),
            // ],
            if (data.specialty.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 16,
                    color: R.color.color0xff5E6566,
                  ),
                  GapW(5),
                  Flexible(
                    child: Text(
                      data.specialty.length <= 2
                          ? data.specialty.map((e) => e.name).join(' | ')
                          : '${data.specialty.take(2).map((e) => e.name).join(' | ')} | +${data.specialty.length - 2}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff5E6566,
                      ),
                    ),
                  ),
                ],
              ),
              GapH(16),
            ],
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _handleBookingClinic(data),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            R.color.greenGradientTop02,
                            R.color.greenGradientBottom,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(200),
                      ),
                      padding: const EdgeInsets.all(10),
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
          ],
        ),
      ),
    );
  }
}
