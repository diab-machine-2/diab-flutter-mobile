import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class BookingCLinicSelectServicePage extends StatefulWidget {
  final DsmesClinicModel clinic;
  final String serviceType;
  final String action; // 'create' or 'reschedule'
  final String bookingType; // 'clinic' or 'center' or 'doctor'

  const BookingCLinicSelectServicePage({
    Key? key,
    required this.clinic,
    required this.serviceType,
    this.action = 'create',
    this.bookingType = Const.BOOKING_TYPE_CLINIC,
  }) : super(key: key);

  @override
  State<BookingCLinicSelectServicePage> createState() =>
      _BookingCLinicSelectServicePageState();
}

class _BookingCLinicSelectServicePageState
    extends State<BookingCLinicSelectServicePage> {
  late DsmesAppointmentCubit _cubit;
  final Set<int> selectedServices = {};
  static const int maxServices = 2;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<DsmesAppointmentCubit>();
    if (_cubit.createDsmesBookingRequest != null) {
      if (_cubit.createDsmesBookingRequest!.paymentInfo == null) return;

      selectedServices.addAll(_cubit
          .createDsmesBookingRequest!.paymentInfo!.services
          .map((service) => service.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final telemedicineCategories = widget.clinic.serviceList.categories
        .where((category) =>
            category.type == DsmesAppointmentMode.telemedicine.toString())
        .toList();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    backgroundColor: R.color.transparent,
                    title: Text(
                      R.string.chon_dich_vu.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.white,
                      ),
                    ),
                    leadingIcon: IconButton(
                      splashColor: R.color.transparent,
                      highlightColor: R.color.transparent,
                      icon: Icon(Icons.arrow_back, color: R.color.white),
                      onPressed: () {
                        DsmesNavigationMixin.getNavigationKey()
                            .currentState
                            ?.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: selectedServices.isEmpty
                          ? 90 // Just the continue button height + padding
                          : selectedServices.length == 1
                              ? 150 // Single service + title + button + padding
                              : 180, // Multiple services + title + button + padding
                    ),
                    decoration: BoxDecoration(
                        color: R.color.backgroundColorNew,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          Utils.getBoxShadowDropCard(),
                        ]),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: telemedicineCategories.length,
                      itemBuilder: (context, index) {
                        final category = telemedicineCategories[index];
                        return ClinicCategorySection(
                          category: category,
                          selectedServices: selectedServices,
                          onServiceSelected: _handleServiceSelection,
                          isFirst: index == 0,
                          isLast: index == telemedicineCategories.length - 1,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: selectedServices.isEmpty
                      ? null
                      : BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                  boxShadow: [
                    Utils.getBoxShadowDropButton(),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GapH(16),
                    // Add selected services display
                    if (selectedServices.isNotEmpty) ...[
                      Text(
                        R.string.selected_service.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      GapH(12),
                      ...selectedServices.map((serviceId) {
                        final service = widget.clinic.serviceList.categories
                            .expand((category) => category.data)
                            .firstWhere((service) => service.id == serviceId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: Text(
                                  service.name,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    Utils.formatMoney(service.fromPrice) ?? '',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      GapH(12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: _buildButton(R.string.tiep_tuc.tr(), () async {
                            if (_isProcessing) return;
                            setState(() => _isProcessing = true);

                            try {
                              widget.bookingType == Const.BOOKING_TYPE_CENTER
                                  ? _proceedToNextStep()
                                  : _proceedToNextStepBookingClinic();
                            } finally {
                              setState(() => _isProcessing = false);
                            }
                          },
                              isDisabled: selectedServices.isEmpty ||
                                  selectedServices.length > maxServices),
                        ),
                      ],
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

  Widget _buildButton(String text, VoidCallback onTap,
      {bool isDisabled = false}) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 44,
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: BoxDecoration(
          color: R.color.color0xffBFC6C6,
          borderRadius: BorderRadius.circular(200),
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
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isDisabled ? R.color.color0xffEDEEEE : R.color.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _handleServiceSelection(int serviceId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (selectedServices.length < maxServices) {
          selectedServices.add(serviceId);
        } else {
          BotToast.showCustomText(
            toastBuilder: (_) => Container(
              // width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
            duration: Duration(seconds: 2),
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

  void _proceedToNextStep() async {
    if (selectedServices.length >= 1 &&
        selectedServices.length <= maxServices) {
      List<ServiceItem> serviceItems = selectedServices
          .map((serviceId) =>
              ServiceItem(id: serviceId, quantity: 1 // Hardcoded quantity
                  ))
          .toList();
      _cubit.updateCreateDsmesBookingRequestServiceList(
        selectedServices: serviceItems,
      );

      final route = ModalRoute.of(context)?.settings;
      final args = route?.arguments as Map<String, dynamic>?;
      final isEditing = args?['isEditing'] ?? false;
      final isMergedSchedule = args?['isMergedSchedule'] ?? false;

      if (isEditing) {
        // First pop the current select_service page
        DsmesNavigationMixin.getNavigationKey().currentState?.pop();

        // Now pop until the original select_service
        DsmesNavigationMixin.getNavigationKey().currentState?.popUntil(
            (route) =>
                route.settings.name == NavigatorName.dsmes_select_service);

        // Replace with new select_service state
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushReplacementNamed(NavigatorName.dsmes_select_service,
                arguments: {
              'serviceType': widget.serviceType,
              'action': widget.action,
              'clinic': _cubit.selectedClinic,
            });

        // Push new select_date
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
          'isMergedSchedule': isMergedSchedule,
        });

        // Push confirm info
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
        });
      } else {
        await DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
          'serviceType': widget.serviceType,
          'action': 'create',
          'isMergedSchedule': isMergedSchedule,
        });
      }

      // await DsmesNavigationMixin.getNavigationKey().currentState
      //     ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
      //   'serviceType': widget.serviceType,
      //   'action': 'create',
      // });
    }
  }

  _proceedToNextStepBookingClinic() async {
    if (selectedServices.length >= 1 &&
        selectedServices.length <= maxServices) {
      List<ServiceItem> serviceItems = selectedServices
          .map((serviceId) =>
              ServiceItem(id: serviceId, quantity: 1 // Hardcoded quantity
                  ))
          .toList();
      _cubit.updateCreateDsmesBookingRequestServiceList(
        // paymentType: 'local_banking',
        selectedServices: serviceItems,
      );

      final route = ModalRoute.of(context)?.settings;
      final args = route?.arguments as Map<String, dynamic>?;
      final isEditing = args?['isEditing'] ?? false;

      if (isEditing) {
        // First pop the current select_service page
        DsmesNavigationMixin.getNavigationKey().currentState?.pop();

        // Now pop until the original select_service
        DsmesNavigationMixin.getNavigationKey().currentState?.popUntil(
            (route) =>
                route.settings.name == NavigatorName.clinic_select_service);

        // Replace with new select_service state
        DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushReplacementNamed(NavigatorName.clinic_select_service,
                arguments: {
              'clinic': _cubit.selectedClinic,
              'serviceType': DsmesAppointmentMode.telemedicine.toString(),
              'action': widget.action,
              'bookingType': widget.bookingType,
            });

        // Push confirm info
        await DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
          'bookingType': widget.bookingType,
        });
      } else {
        await DsmesNavigationMixin.getNavigationKey()
            .currentState
            ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
          'bookingType': widget.bookingType,
        });
      }

      // await DsmesNavigationMixin.getNavigationKey().currentState
      //     ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
      //   'serviceType': widget.serviceType,
      //   'action': 'create',
      // });
    }
  }
}

class ClinicCategorySection extends StatefulWidget {
  final ServiceCategory category;
  final Set<int> selectedServices;
  final Function(int, bool) onServiceSelected;
  final bool isFirst;
  final bool isLast;

  const ClinicCategorySection({
    Key? key,
    required this.category,
    required this.selectedServices,
    required this.onServiceSelected,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  State<ClinicCategorySection> createState() => _ClinicCategorySectionState();
}

class _ClinicCategorySectionState extends State<ClinicCategorySection> {
  bool isExpanded = true;
  @override
  Widget build(BuildContext context) {
    // final filteredServices = filterFreePriceServices(category);
    final services = widget.category.data;
    return Container(
      // padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
      margin: EdgeInsets.fromLTRB(12, 20, 12, 0),
      decoration: BoxDecoration(
        color: R.color.backgroundColorNew,
        borderRadius: BorderRadius.only(
          topLeft: widget.isFirst ? Radius.circular(12) : Radius.zero,
          topRight: widget.isFirst ? Radius.circular(12) : Radius.zero,
          bottomLeft: widget.isLast ? Radius.circular(12) : Radius.zero,
          bottomRight: widget.isLast ? Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff141416,
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: R.color.color0xff141416,
                ),
              ],
            ),
          ),
          if (services.isNotEmpty && isExpanded)
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return GestureDetector(
                    onTap: () => widget.onServiceSelected(service.id,
                        !widget.selectedServices.contains(service.id)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ServiceRow(
                          service: service,
                          isSelected:
                              widget.selectedServices.contains(service.id),
                          onSelected: (selected) =>
                              widget.onServiceSelected(service.id, selected),
                        ),
                        if (index == services.length - 1) GapH(20),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

List<ServiceData> filterFreePriceServices(ServiceCategory category) {
  return category.data
      .where((service) => service.fromPrice == 0 && service.toPrice == 0)
      .toList();
}

class ServiceRow extends StatelessWidget {
  final ServiceData service;
  final bool isSelected;
  final Function(bool) onSelected;

  const ServiceRow({
    Key? key,
    required this.service,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? R.color.greenGradientBottom : Colors.transparent,
              width: 1,
            ),
            boxShadow: [Utils.getBoxShadowDropCard()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff141416,
                ),
              ),
              if (service.description.isNotEmpty) GapH(12),
              if (service.description.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Text(
                        service.description?.replaceAll('<br />', ' ') ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: R.color.color0xff777E90,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () => _showServiceDetails(context),
                        child: Text(
                          R.string.more.tr(),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 13,
                            color: R.color.color0xff95682E,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              GapH(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Utils.formatMoney(service.fromPrice) ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: R.color.greenGradientBottom,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            top: 16,
            child: CustomPaint(
              size: Size(20, 20),
              painter: TrianglePainter(
                color: R.color.greenGradientBottom,
              ),
            ),
          ),
      ],
    );
  }

  void _showServiceDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      service.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: R.color.color0xff141416,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Utils.formatMoney(service.fromPrice) ?? '',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: R.color.greenGradientBottom,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          HtmlWidget(
                            service.description ?? '',
                            textStyle: TextStyle(
                              fontSize: 13,
                              color: R.color.color0xff636A6B,
                            ),
                          ),
                          GapH(80),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    onSelected(!isSelected);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    color: R.color.white,
                    child: Container(
                      alignment: Alignment.center,
                      height: 44,
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
                      child: Text(
                        R.string.chon_dich_vu.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: R.color.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final double radius;

  TrianglePainter({required this.color, this.radius = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - radius, 0)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
