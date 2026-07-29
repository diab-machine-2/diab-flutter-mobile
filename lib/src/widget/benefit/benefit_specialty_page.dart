import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/firebase_remote_config.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/booking_clinic/model/clinic_specialty_model.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_state.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/benefit/benefit_navigator_scope.dart';

/// Specialty selection page for the Benefit booking flow.
///
/// [bookingType] should be either [Const.BENEFIT_BOOKING_AT_CLINIC] or
/// [Const.BENEFIT_BOOKING_TELEMEDICINE].
class BenefitSpecialtyPage extends StatefulWidget {
  final String bookingType;
  final String? specialtyName;
  final int? specialtyId;
  final int? clinicId;
  final String? itemId;
  final int? itemType;

  const BenefitSpecialtyPage({
    Key? key,
    required this.bookingType,
    this.specialtyName,
    this.specialtyId,
    this.clinicId,
    this.itemId,
    this.itemType,
  }) : super(key: key);

  @override
  _BenefitSpecialtyPageState createState() => _BenefitSpecialtyPageState();
}

class _BenefitSpecialtyPageState extends State<BenefitSpecialtyPage> {
  late DsmesAppointmentCubit _cubit;

  bool get _isTelemedicine =>
      widget.bookingType == Const.BENEFIT_BOOKING_TELEMEDICINE;

  bool get _isClinic =>
      widget.bookingType == Const.BENEFIT_BOOKING_AT_CLINIC;

  /// True when the caller already supplied enough info (specialty + clinic
  /// for at-clinic, or specialty for telemedicine) that [_initData] will try
  /// to auto-navigate straight to [NavigatorName.benefit_calendar] without
  /// the user picking anything here. While true (and resolution hasn't
  /// failed), the specialty grid is never rendered — avoids a visible flash
  /// of this screen before the auto-redirect completes.
  bool get _hasAutoResolveIntent =>
      (_isTelemedicine || (_isClinic && widget.clinicId != null)) &&
      (widget.specialtyId != null ||
          (widget.specialtyName?.trim().isNotEmpty ?? false));

  /// Flips true if auto-resolution can't complete (no specialty match,
  /// clinic search/detail failure, etc.) so the grid reveals itself as a
  /// manual fallback instead of leaving the user on a spinner forever.
  bool _autoResolveFailed = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    _initData();
  }

  Future<void> _initData() async {
    await _cubit.getCLinicSpecialtyList();
    if (!mounted) return;

    final ordered = _getOrderedSpecialties();
    ClinicSpecialty? matched;
    if (widget.specialtyId != null) {
      matched = ordered.firstWhereOrNull((s) => s.id == widget.specialtyId);
    }
    if (matched == null &&
        widget.specialtyName != null &&
        widget.specialtyName!.isNotEmpty) {
      final target = widget.specialtyName!.toLowerCase().trim();
      matched = ordered.firstWhereOrNull(
          (s) => s.name.toLowerCase().trim() == target);
    }
    if (matched == null) {
      if (_hasAutoResolveIntent) setState(() => _autoResolveFailed = true);
      return;
    }

    if (_isClinic && widget.clinicId != null) {
      _onSelectAtClinicPreselected(matched, widget.clinicId!);
    } else if (_isTelemedicine) {
      _onSelectTelemedicine(matched, isAutoResolve: true);
    } else {
      _onSelectSpecialty(matched);
    }
  }

  List<ClinicSpecialty> _getOrderedSpecialties() {
    var specialties = _cubit.listSpecialty;
    if (specialties.isEmpty) return [];

    // Filter out excluded specialties from Firebase Remote Config
    final excludeSlugs = <String>{};
    if (_isTelemedicine) {
      final raw = FirebaseRemoteSetting.instance.excludeSpecialtyTelemedicine;
      if (raw.isNotEmpty) {
        excludeSlugs.addAll(raw.split(','));
      }
    }
    if (_isClinic) {
      final raw = FirebaseRemoteSetting.instance.excludeSpecialtyClinic;
      if (raw.isNotEmpty) {
        excludeSlugs.addAll(raw.split(','));
      }
    }
    if (excludeSlugs.isNotEmpty) {
      specialties = specialties
          .where((s) => !excludeSlugs.contains(_nameToSlug(s.name)))
          .toList();
    }

    final slugOrder = FirebaseRemoteSetting.instance.specialtyOrder ?? '';
    if (slugOrder.isEmpty) return specialties;

    final slugs = slugOrder.split(',');
    final specialtyMap = {
      for (var s in specialties) _toBannerSlug(s.banner ?? ''): s
    };

    final ordered = <ClinicSpecialty>[];
    for (final slug in slugs) {
      if (specialtyMap.containsKey(slug)) {
        ordered.add(specialtyMap[slug]!);
      }
    }

    // Add any specialties not in the order list
    for (final s in specialties) {
      if (!ordered.contains(s)) {
        ordered.add(s);
      }
    }

    return ordered;
  }

  /// Converts the API banner path/slug to a canonical slug for ordering.
  /// E.g. "tien-dai-thao-duong" or "clinic_specialty/tien-dai-thao-duong.jpg"
  /// → "tien-dai-thao-duong"
  String _toBannerSlug(String banner) {
    final segments = banner.replaceAll('\\', '/').split('/');
    final fileName = segments.last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }

  /// Converts a Vietnamese specialty name to a canonical slug for exclusion matching.
  /// E.g. "Cơ xương khớp" → "co-xuong-khop", "Thừa cân/Béo phì" → "thua-can-beo-phi"
  String _nameToSlug(String name) {
    const withDiacritics =
        'àáạãảâấầậẫẩăắằặẵẳđèéẹẽẻêếềệễểìíịĩỉòóọõỏôốồộỗổơớờợỡởùúụũủưứừựữửýỳỵỹỷ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaadeeeeeeeeeeeeiiiiiooooooooooooooooooouuuuuuuuuuuyyyyy';

    return name
        .toLowerCase()
        .trim()
        .split('')
        .map((c) {
          final idx = withDiacritics.indexOf(c);
          return idx >= 0 ? withoutDiacritics[idx] : c;
        })
        .join()
        .replaceAll('/', '-')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  /// Maps a banner slug from the API to a local drawable asset path.
  String _getBannerAsset(String banner) {
    final slug = _toBannerSlug(banner);
    switch (slug) {
      case 'tien-dai-thao-duong':
        return R.drawable.banner_tien_dai_thao_duong;
      case 'dai-thao-duong':
        return R.drawable.banner_dai_thao_duong;
      case 'dinh-duong':
        return R.drawable.banner_dinh_duong;
      case 'tang-huyet-ap':
        return R.drawable.banner_tang_huyet_ap;
      case 'thua-can-beo-phi':
        return R.drawable.banner_thua_can_beo_phi;
      case 'dai-thao-duong-thai-ky':
        return R.drawable.banner_dai_thao_duong_thai_ky;
      case 'tim-mach':
        return R.drawable.banner_tim_mach;
      case 'roi-loan-chuyen-hoa':
        return R.drawable.banner_roi_loan_chuyen_hoa;
      case 'than-man-tinh':
        return R.drawable.banner_than_man_tinh;
      case 'tinh-than':
        return R.drawable.banner_tinh_than;
      default:
        return R.drawable.banner_benh_khac;
    }
  }

  void _onSelectSpecialty(ClinicSpecialty specialty) {
    if (_isTelemedicine) {
      _onSelectTelemedicine(specialty);
    } else {
      _onSelectAtClinic(specialty);
    }
  }

  Future<void> _onSelectAtClinic(ClinicSpecialty specialty) async {
    final clinicIds = specialty.clinic_ids.map((e) => e.toString()).toList();
    BenefitNavigatorScope.of(context).currentState?.pushNamed(
      NavigatorName.benefit_clinic_list,
      arguments: {
        'bookingType': widget.bookingType,
        'clinicIds': clinicIds,
        'specialtyName': specialty.name,
        'itemId': widget.itemId,
        'itemType': widget.itemType,
      },
    );
  }

  Future<void> _onSelectTelemedicine(
    ClinicSpecialty specialty, {
    bool isAutoResolve = false,
  }) async {
    final clinicIds = specialty.telemedicine_clinic_ids
        .map((e) => e.toString())
        .toList();

    // 1. Call search API with clinic_ids filter for telemedicine
    _cubit.initSearchBookingClinicListRequest(
      page: 1,
      specialtyId: '',
      kind: Const.BOOKING_TYPE_CLINIC,
      isFilterDistance: 0,
      clinicIds: clinicIds,
    );

    _cubit.searchBookingClinicListRequest =
        _cubit.searchBookingClinicListRequest?.copyWith(
      svAvailable: ['telemedicine'],
    );

    final request = _cubit.searchBookingClinicListRequest;
    if (request == null) return;

    BotToast.showLoading(allowClick: false);
    try {
      final clinics = await _cubit.searchBookingClinicList(
        request: request,
        isRefresh: true,
      );
      BotToast.closeAllLoading();

      if (clinics.isEmpty) {
        BotToast.showSimpleNotification(
            title: R.string.empty_clinic_content.tr());
        if (isAutoResolve && mounted) {
          setState(() => _autoResolveFailed = true);
        }
        return;
      }

      // 2. Auto-select the first clinic
      final firstClinic = clinics.first;
      final detailSuccess = await _cubit.getClinicDetail(
        id: firstClinic.id,
        isLoading: false,
      );
      if (!detailSuccess || _cubit.selectedClinic == null) {
        BotToast.showSimpleNotification(
            title: R.string.empty_clinic_content.tr());
        if (isAutoResolve && mounted) {
          setState(() => _autoResolveFailed = true);
        }
        return;
      }

      // 3. Init booking request and navigate to schedule
      _cubit.initCreateDsmesBookingRequest(
        locale: context.locale.languageCode,
        clearExamination: true,
      );

      final serviceType = DsmesAppointmentMode.telemedicine.toString();

      if (!mounted) return;
      final navigatorState = BenefitNavigatorScope.of(context).currentState;
      final args = {
        'serviceType': serviceType,
        'action': 'create',
        'bookingType': Const.BENEFIT_BOOKING_TELEMEDICINE,
        'specialtyName': specialty.name,
        'itemId': widget.itemId,
        'itemType': widget.itemType,
      };
      if (isAutoResolve) {
        navigatorState?.pushReplacementNamed(
          NavigatorName.benefit_calendar,
          arguments: args,
        );
      } else {
        navigatorState?.pushNamed(
          NavigatorName.benefit_calendar,
          arguments: args,
        );
      }
    } catch (_) {
      BotToast.closeAllLoading();
      if (isAutoResolve && mounted) {
        setState(() => _autoResolveFailed = true);
      }
    }
  }

  /// Auto-books the given [clinicId] for an at-clinic benefit item, skipping
  /// the manual clinic-list selection step — mirrors [_onSelectTelemedicine]'s
  /// auto-pick pattern but targets one specific clinic instead of the first
  /// search result.
  Future<void> _onSelectAtClinicPreselected(
    ClinicSpecialty specialty,
    int clinicId,
  ) async {
    final clinicIdStr = clinicId.toString();

    _cubit.initSearchBookingClinicListRequest(
      page: 1,
      specialtyId: '',
      kind: Const.BOOKING_TYPE_CLINIC,
      isFilterDistance: 0,
      clinicIds: [clinicIdStr],
    );

    final request = _cubit.searchBookingClinicListRequest;
    if (request == null) {
      if (mounted) setState(() => _autoResolveFailed = true);
      await _onSelectAtClinic(specialty);
      return;
    }

    BotToast.showLoading(allowClick: false);
    try {
      final clinics = await _cubit.searchBookingClinicList(
        request: request,
        isRefresh: true,
      );
      BotToast.closeAllLoading();

      final matchedClinic =
          clinics.firstWhereOrNull((c) => c.id.toString() == clinicIdStr) ??
              (clinics.isNotEmpty ? clinics.first : null);
      if (matchedClinic == null) {
        BotToast.showSimpleNotification(
            title: R.string.empty_clinic_content.tr());
        if (mounted) setState(() => _autoResolveFailed = true);
        await _onSelectAtClinic(specialty);
        return;
      }

      final detailSuccess = await _cubit.getClinicDetail(
        id: matchedClinic.id,
        isLoading: false,
      );
      if (!detailSuccess || _cubit.selectedClinic == null) {
        BotToast.showSimpleNotification(
            title: R.string.empty_clinic_content.tr());
        if (mounted) setState(() => _autoResolveFailed = true);
        return;
      }

      for (final cluster in _cubit.listClinicClusters) {
        if (cluster.clinicId == matchedClinic.id) {
          _cubit.selectedClinicBranches = cluster.branches;
          break;
        }
      }

      _cubit.initCreateDsmesBookingRequest(
        locale: context.locale.languageCode,
        clearExamination: true,
      );

      final serviceType = DsmesAppointmentMode.atClinic.toString();

      if (!mounted) return;
      BenefitNavigatorScope.of(context).currentState?.pushReplacementNamed(
        NavigatorName.benefit_calendar,
        arguments: {
          'serviceType': serviceType,
          'action': 'create',
          'bookingType': Const.BENEFIT_BOOKING_AT_CLINIC,
          'specialtyName': specialty.name,
          'itemId': widget.itemId,
          'itemType': widget.itemType,
        },
      );
    } catch (_) {
      BotToast.closeAllLoading();
      if (mounted) setState(() => _autoResolveFailed = true);
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
          child: Column(
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
                    R.string.chon_nhu_cau_kham.tr(),
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
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  ),
                ),
              ),
              Expanded(
                child: (_hasAutoResolveIntent && !_autoResolveFailed)
                    ? const Center(child: CircularProgressIndicator())
                    : BlocBuilder<DsmesAppointmentCubit,
                        DsmesAppointmentState>(
                        builder: (context, state) {
                          if (state is DsmesAppointmentLoading &&
                              _cubit.listSpecialty.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (_cubit.listSpecialty.isEmpty) {
                            return Center(
                              child: Text(
                                R.string.empty_clinic_content.tr(),
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          }

                          return _buildSpecialtyGrid();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialtyGrid() {
    final specialties = _getOrderedSpecialties();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final crossAxisCount = isTablet ? 3 : 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 170 / 238,
            ),
            itemCount: specialties.length,
            itemBuilder: (context, index) {
              final specialty = specialties[index];
              return _buildSpecialtyCard(specialty);
            },
          ),
        );
      },
    );
  }

  Widget _buildSpecialtyCard(ClinicSpecialty specialty) {
    final bannerAsset = _getBannerAsset(specialty.image ?? '');

    return GestureDetector(
      onTap: () => _onSelectSpecialty(specialty),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: "${Utils.getHostDocosanUrl()}${specialty.image}",
                errorWidget: (context, url, error) {
                  return Image.asset(
                    R.drawable.banner_tien_dai_thao_duong,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 111,
                padding: const EdgeInsets.fromLTRB(12, 16, 8, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      R.color.color0xffFAF0D2,
                      R.color.color0xffFAF0D2.withOpacity(0),
                    ],
                    stops: const [0.0, 1],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        specialty.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: R.color.color0xff111515,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: R.color.color0xff111515,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
