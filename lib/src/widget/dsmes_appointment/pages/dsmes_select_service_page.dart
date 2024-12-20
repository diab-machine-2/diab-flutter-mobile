import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/model/dsmes_clinic_model.dart';
import 'package:medical/src/widget/dsmes_appointment/pages/dsmes_navigation_mixin.dart';

class DsmesSelectServicePage extends StatefulWidget {
  final DsmesClinicModel clinic;

  const DsmesSelectServicePage({Key? key, required this.clinic})
      : super(key: key);

  @override
  State<DsmesSelectServicePage> createState() => _DsmesSelectServicePageState();
}

class _DsmesSelectServicePageState extends State<DsmesSelectServicePage> {
  final Set<int> selectedServices = {};
  static const int maxServices = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: R.color.backgroundColorNew,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text(
                R.string.select_consulting_demand.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
              leadingIcon: IconButton(
                splashColor: R.color.transparent,
                highlightColor: R.color.transparent,
                icon: Icon(Icons.arrow_back, color: R.color.color0xff111515),
                onPressed: () {
                  DsmesNavigationMixin.navigationKey.currentState?.pop(context);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.clinic.serviceList.categories.length,
                itemBuilder: (context, index) {
                  final category = widget.clinic.serviceList.categories[index];
                  return CategorySection(
                    category: category,
                    selectedServices: selectedServices,
                    onServiceSelected: _handleServiceSelection,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: selectedServices.isEmpty ||
                        selectedServices.length > maxServices
                    ? null
                    : () => _proceedToNextStep(),
                child: Text(
                  'Continue (${selectedServices.length}/$maxServices selected)',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleServiceSelection(int serviceId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (selectedServices.length < maxServices) {
          selectedServices.add(serviceId);
        }
      } else {
        selectedServices.remove(serviceId);
      }
    });
  }

  void _proceedToNextStep() {
    if (selectedServices.length >= 1 &&
        selectedServices.length <= maxServices) {
      Navigator.pop(context, selectedServices.toList());
    }
  }
}

class CategorySection extends StatelessWidget {
  final ServiceCategory category;
  final Set<int> selectedServices;
  final Function(int, bool) onServiceSelected;

  const CategorySection({
    Key? key,
    required this.category,
    required this.selectedServices,
    required this.onServiceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff141416,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: category.data.length,
            itemBuilder: (context, index) {
              final service = category.data[index];
              return ServiceRow(
                service: service,
                isSelected: selectedServices.contains(service.id),
                onSelected: (selected) =>
                    onServiceSelected(service.id, selected),
              );
            },
          ),
        ],
      ),
    );
  }
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
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
          Checkbox(
            value: isSelected,
            onChanged: (value) => onSelected(value ?? false),
          ),
        ],
      ),
    );
  }
}
