import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/create_dsmes_booking_request.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_appointment_model.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class DsmesSelectServicePage extends StatefulWidget {
  final DsmesClinicModel clinic;
  final String serviceType;
  final String action; // 'create' or 'reschedule'

  const DsmesSelectServicePage({
    Key? key,
    required this.clinic,
    required this.serviceType,
    this.action = 'create',
  }) : super(key: key);

  @override
  State<DsmesSelectServicePage> createState() => _DsmesSelectServicePageState();
}

class _DsmesSelectServicePageState extends State<DsmesSelectServicePage> {
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
                      R.string.select_consulting_demand.tr(),
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
                        DsmesNavigationMixin.getNavigationKey().currentState
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
                        return CategorySection(
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
                        R.string.selected_demand.tr(),
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
                          child: Text(service.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              )),
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
                              _proceedToNextStep();
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
          selectedServices: serviceItems);

      final route = ModalRoute.of(context)?.settings;
      final args = route?.arguments as Map<String, dynamic>?;
      final isEditing = args?['isEditing'] ?? false;
      final isMergedSchedule = args?['isMergedSchedule'] ?? false;

      if (isEditing) {
        // First pop the current select_service page
        DsmesNavigationMixin.getNavigationKey().currentState?.pop();

        // Now pop until the original select_service
        DsmesNavigationMixin.getNavigationKey().currentState?.popUntil((route) =>
            route.settings.name == NavigatorName.dsmes_select_service);

        // Replace with new select_service state
        DsmesNavigationMixin.getNavigationKey().currentState?.pushReplacementNamed(
            NavigatorName.dsmes_select_service,
            arguments: {
              'serviceType': widget.serviceType,
              'action': widget.action,
              'clinic': _cubit.selectedClinic,
            });

        // Push new select_date
        DsmesNavigationMixin.getNavigationKey().currentState
            ?.pushNamed(NavigatorName.dsmes_booking_select_date, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
          'isMergedSchedule': isMergedSchedule,
        });

        // Push confirm info
        DsmesNavigationMixin.getNavigationKey().currentState
            ?.pushNamed(NavigatorName.dsmes_confirm_information, arguments: {
          'serviceType': widget.serviceType,
          'action': widget.action,
        });
      } else {
        await DsmesNavigationMixin.getNavigationKey().currentState
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
}

class CategorySection extends StatelessWidget {
  final ServiceCategory category;
  final Set<int> selectedServices;
  final Function(int, bool) onServiceSelected;
  final bool isFirst;
  final bool isLast;

  const CategorySection({
    Key? key,
    required this.category,
    required this.selectedServices,
    required this.onServiceSelected,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredServices = filterFreePriceServices(category);
    return Visibility(
      visible: filteredServices.isNotEmpty,
      child: Container(
        // padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
        margin: EdgeInsets.fromLTRB(12, 20, 12, 0),
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? Radius.circular(12) : Radius.zero,
            topRight: isFirst ? Radius.circular(12) : Radius.zero,
            bottomLeft: isLast ? Radius.circular(12) : Radius.zero,
            bottomRight: isLast ? Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  getIconPathFromSlug(category.slug),
                  width: 30,
                  height: 24,
                ),
                GapW(8),
                Flexible(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff141416,
                    ),
                  ),
                ),
              ],
            ),
            GapH(16),
            if (filteredServices.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [Utils.getBoxShadowDropCard()],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredServices.length,
                  itemBuilder: (context, index) {
                    final service = filteredServices[index];
                    return GestureDetector(
                      onTap: () => onServiceSelected(
                          service.id, !selectedServices.contains(service.id)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ServiceRow(
                            service: service,
                            isSelected: selectedServices.contains(service.id),
                            onSelected: (selected) =>
                                onServiceSelected(service.id, selected),
                          ),
                          index != filteredServices.length - 1
                              ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                  child: Divider(
                                    color: R.color.color0xffDFE4E4,
                                    height: 1,
                                  ),
                                )
                              : Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 12, 0, 12),
                                  child: Divider(
                                    color: R.color.color0xffDFE4E4,
                                    height: 1,
                                  ),
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

List<ServiceData> filterFreePriceServices(ServiceCategory category) {
  return category.data
      .where((service) => service.fromPrice == 0 && service.toPrice == 0)
      .toList();
}

String getIconPathFromSlug(String slug) {
  Map<String, String> iconPaths = {
    'benh-ly': R.drawable.ic_benh_ly,
    'dinh-duong-bua-an-can-bang': R.drawable.ic_dinh_duong_bua_an_can_bang,
    'theo-doi-chi-so': R.drawable.ic_theo_doi_chi_so,
    'van-dong-va-tinh-than': R.drawable.ic_van_dong_va_tinh_than,
    'khac': R.drawable.ic_khac,
  };

  return iconPaths[slug] ?? R.drawable.ic_khac;
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            service.name,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? R.color.greenGradientBottom
                  : R.color.color0xff111515,
            ),
          ),
        ),
        Container(
          width: 24,
          height: 24,
          margin: EdgeInsets.only(left: 16),
          child: Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            value: isSelected,
            onChanged: (value) => onSelected(value ?? false),
          ),
        ),
      ],
    );
  }
}
