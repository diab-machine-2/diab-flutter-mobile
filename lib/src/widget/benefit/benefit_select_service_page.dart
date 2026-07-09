import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';

/// Service selection screen for the Benefit booking flow.
///
/// Shown when the selected clinic exposes more than one service.
/// On "Tiếp tục" the cubit request is updated with the chosen service(s) and
/// the flow continues to [NavigatorName.benefit_confirm_information] which
/// BenefitPage routes to [BenefitConfirmPage].
class BenefitSelectServicePage extends StatefulWidget {
  final String serviceType;
  final String action;
  final int? appointmentId;
  final String bookingType;
  final String? specialtyName;
  final String? branchName;
  final String? branchAddress;
  final int? branchId;

  const BenefitSelectServicePage({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
    required this.bookingType,
    this.specialtyName,
    this.branchName,
    this.branchAddress,
    this.branchId,
  }) : super(key: key);

  @override
  State<BenefitSelectServicePage> createState() =>
      _BenefitSelectServicePageState();
}

class _BenefitSelectServicePageState extends State<BenefitSelectServicePage> {
  late DsmesAppointmentCubit _cubit;
  final Set<int> selectedServices = {};
  static const int maxServices = 2;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    if (_cubit.createDsmesBookingRequest?.paymentInfo != null) {
      selectedServices.addAll(_cubit
          .createDsmesBookingRequest!.paymentInfo!.services
          .map((s) => s.id));
    }
  }

  List<ServiceData> get _allServices =>
      _cubit.selectedClinic?.serviceList.categories
          .expand((c) => c.data)
          .toList() ??
      [];

  double get _bottomPanelHeight {
    if (selectedServices.isEmpty) return 76;
    return 76 + 24 + 12 + (selectedServices.length * 28.0) + 12;
  }

  @override
  Widget build(BuildContext context) {
    final clinic = _cubit.selectedClinic;
    if (clinic == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    top: 0,
                    bottom: _bottomPanelHeight + 12,
                  ),
                  itemCount: clinic.serviceList.categories.length,
                  itemBuilder: (context, index) {
                    final category = clinic.serviceList.categories[index];
                    if (category.data.isEmpty) return const SizedBox.shrink();
                    return _BenefitCategorySection(
                      category: category,
                      selectedServices: selectedServices,
                      onServiceSelected: _handleServiceSelection,
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
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
      child: CustomAppBar(
        backgroundColor: R.color.transparent,
        title: Text(
          R.string.select_consulting_demand.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: R.color.white,
            letterSpacing: 0.04,
          ),
        ),
        leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () => DsmesNavigationMixin.getNavigationKey()
              .currentState
              ?.pop(context),
        ),
      ),
    );
  }

  // ── Bottom panel ──────────────────────────────────────────────────────────

  Widget _buildBottomPanel() {
    final isDisabled =
        selectedServices.isEmpty || selectedServices.length > maxServices;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        color: R.color.color0xffF7F8F8,
        borderRadius: selectedServices.isEmpty
            ? null
            : const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
        boxShadow: [
          BoxShadow(
            color: R.color.cardShadowColor,
            blurRadius: 8,
            offset: const Offset(2, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedServices.isNotEmpty) ...[
            GapH(8),
            Text(
              R.string.selected_service.tr(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: R.color.color0xff111515,
              ),
            ),
            GapH(10),
            ...selectedServices.map((serviceId) {
              final service = _allServices.firstWhere(
                (s) => s.id == serviceId,
                orElse: () => _allServices.first,
              );
              final priceLabel = service.value.isNotEmpty
                  ? service.value
                  : _formatPrice(service.fromPrice);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        service.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff111515,
                          letterSpacing: 0.40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      priceLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff111515,
                        letterSpacing: 0.40,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            GapH(12),
          ],
          GestureDetector(
            onTap: isDisabled || _isProcessing
                ? null
                : () async {
                    setState(() => _isProcessing = true);
                    try {
                      await _proceedToConfirm();
                    } finally {
                      setState(() => _isProcessing = false);
                    }
                  },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                gradient: isDisabled
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [
                          R.color.greenGradientTop,
                          R.color.greenGradientMid,
                          R.color.greenGradientBottom,
                        ],
                      ),
                color: isDisabled ? R.color.color0xffBFC6C6 : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  R.string.tiep_tuc.tr(),
                  style: TextStyle(
                    color: isDisabled
                        ? R.color.color0xffEDEEEE
                        : R.color.color0xffF7F8F8,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logic ─────────────────────────────────────────────────────────────────

  void _handleServiceSelection(int serviceId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (selectedServices.length < maxServices) {
          selectedServices.add(serviceId);
        } else {
          BotToast.showCustomText(
            toastBuilder: (_) => Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: R.color.color0xff111515.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                R.string.max_selected_demand_warning.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            align: Alignment.center,
            duration: const Duration(seconds: 2),
            clickClose: true,
            crossPage: true,
            onlyOne: true,
          );
        }
      } else {
        selectedServices.remove(serviceId);
      }
    });
  }

  Future<void> _proceedToConfirm() async {
    if (selectedServices.isEmpty || selectedServices.length > maxServices)
      return;

    final clinic = _cubit.selectedClinic;
    final saleServiceList = clinic?.saleServiceList;

    if (saleServiceList != null) {
      // ── Voucher flow: build saleServices from matched sale items ──
      final saleItems = <ServiceItem>[];
      String? voucherCode;

      for (final serviceId in selectedServices) {
        final saleItem = saleServiceList.findByServiceId(serviceId);
        if (saleItem != null) {
          saleItems.add(ServiceItem(id: saleItem.serviceItemId, quantity: 1));
          voucherCode ??= saleItem.voucherCode;
        } else {
          // Service not in sale list — send as regular service
          saleItems.add(ServiceItem(id: serviceId, quantity: 1));
        }
      }

      _cubit.createDsmesBookingRequest =
          _cubit.createDsmesBookingRequest?.copyWith(
        paymentInfo: PaymentInfo(
          paymentType: 'local_banking',
          services: [],
          saleServices: saleItems,
        ),
        voucherCode: voucherCode,
      );
    } else {
      // ── Normal flow: regular services ──
      final serviceItems =
          selectedServices.map((id) => ServiceItem(id: id, quantity: 1)).toList();

      _cubit.updateCreateDsmesBookingRequestServiceList(
          selectedServices: serviceItems);
    }

    await DsmesNavigationMixin.getNavigationKey().currentState?.pushNamed(
      NavigatorName.benefit_confirm_information,
      arguments: {
        'serviceType': widget.serviceType,
        'action': widget.action,
        'appointmentId': widget.appointmentId,
        'bookingType': widget.bookingType,
        'specialtyName': widget.specialtyName,
        'branchName': widget.branchName,
        'branchAddress': widget.branchAddress,
        'branchId': widget.branchId,
      },
    );
  }

  static String _formatPrice(int price) {
    if (price == 0) return 'Miễn phí';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(price).replaceAll(',', '.')}đ';
  }
}

// ─── Category section (collapsible) ──────────────────────────────────────────

class _BenefitCategorySection extends StatefulWidget {
  final ServiceCategory category;
  final Set<int> selectedServices;
  final Function(int, bool) onServiceSelected;

  const _BenefitCategorySection({
    Key? key,
    required this.category,
    required this.selectedServices,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  State<_BenefitCategorySection> createState() =>
      _BenefitCategorySectionState();
}

class _BenefitCategorySectionState extends State<_BenefitCategorySection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true; // expanded by default
  late final AnimationController _animCtrl;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0, // starts expanded
    );
    _rotateAnim = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Category header (tap to collapse/expand) ──────────────────
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff141416,
                      letterSpacing: 0.04,
                      height: 1.32,
                    ),
                  ),
                ),
                RotationTransition(
                  turns: _rotateAnim,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: R.color.color0xff636A6B,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Animated service cards list ────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: widget.category.data.map((service) {
              final isSelected = widget.selectedServices.contains(service.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BenefitServiceCard(
                  service: service,
                  isSelected: isSelected,
                  onTap: () =>
                      widget.onServiceSelected(service.id, !isSelected),
                ),
              );
            }).toList(),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _BenefitServiceCard extends StatefulWidget {
  final ServiceData service;
  final bool isSelected;
  final VoidCallback onTap;

  const _BenefitServiceCard({
    Key? key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_BenefitServiceCard> createState() => _BenefitServiceCardState();
}

class _BenefitServiceCardState extends State<_BenefitServiceCard> {
  bool _descExpanded = false;

  bool get _isFree =>
      widget.service.priceType == 'free' ||
      (widget.service.fromPrice == 0 && widget.service.toPrice == 0);

  String get _priceLabel {
    if (widget.service.value.isNotEmpty) return widget.service.value;
    if (_isFree) return 'Miễn phí';
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(widget.service.fromPrice).replaceAll(',', '.')}đ';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.19, 0.00),
            end: const Alignment(1.03, 1.10),
            colors: widget.isSelected
                ? [R.color.white, R.color.color0xffDCFFFC]
                : [R.color.white, R.color.white],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: widget.isSelected
                ? BorderSide(color: R.color.greenGradientTop02, width: 1.5)
                : BorderSide.none,
          ),
          shadows: [
            BoxShadow(
              color: R.color.serviceCardShadow,
              blurRadius: 6.70,
              offset: const Offset(3, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // ── Card content ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service name (leave space for corner triangle)
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        widget.service.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.isSelected
                              ? R.color.greenGradientBottom
                              : R.color.color0xff141416,
                          height: 1.46,
                        ),
                      ),
                    ),

                    // Description (HTML)
                    if (widget.service.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      AnimatedCrossFade(
                        firstChild: _HtmlDescription(
                          html: widget.service.description,
                          maxLines: 2,
                        ),
                        secondChild: _HtmlDescription(
                          html: widget.service.description,
                        ),
                        crossFadeState: _descExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _descExpanded = !_descExpanded),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _descExpanded ? 'Ẩn bớt' : 'Xem thêm',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: R.color.color0xffBFC6C6,
                              letterSpacing: 0.20,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Price
                    const SizedBox(height: 10),
                    Text(
                      _priceLabel,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientTop02,
                        fontFamily: 'Roboto',
                        height: 1.46,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Selected corner triangle ─────────────────────────────
              if (widget.isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: CustomPaint(
                    size: const Size(28, 28),
                    painter: _CornerTrianglePainter(color: R.color.mainColor),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HTML description with optional line clamp ────────────────────────────────

class _HtmlDescription extends StatelessWidget {
  final String html;
  final int? maxLines;

  const _HtmlDescription({Key? key, required this.html, this.maxLines})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widget = Html(
      data: html,
      style: {
        'body': Style(
          fontSize: FontSize(13),
          fontWeight: FontWeight.w400,
          color: R.color.color0xff141416,
          padding: HtmlPaddings.zero,
          margin: Margins.zero,
          lineHeight: LineHeight(1.50),
          letterSpacing: 0.40,
          maxLines: maxLines,
          textOverflow: maxLines != null ? TextOverflow.ellipsis : null,
        ),
        'p': Style(padding: HtmlPaddings.zero, margin: Margins.zero),
        'div': Style(padding: HtmlPaddings.zero, margin: Margins.zero),
        'span': Style(padding: HtmlPaddings.zero, margin: Margins.zero),
      },
    );
    return widget;
  }
}

// ─── Corner triangle painter ──────────────────────────────────────────────────

class _CornerTrianglePainter extends CustomPainter {
  final Color color;
  const _CornerTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerTrianglePainter old) => old.color != color;
}
