import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/medicine/medicine_item_model.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_success_page.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitMedicineScanResultPage extends StatefulWidget {
  final List<MedicineItemModel> medicines;
  final File capturedImage;

  const BenefitMedicineScanResultPage({
    Key? key,
    required this.medicines,
    required this.capturedImage,
  }) : super(key: key);

  @override
  State<BenefitMedicineScanResultPage> createState() =>
      _BenefitMedicineScanResultPageState();
}

class _BenefitMedicineScanResultPageState
    extends State<BenefitMedicineScanResultPage> {
  late Set<int> _selectedIndexes;
  final GlobalKey<SectionAddNoteState> _noteKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIndexes =
        Set.from(List.generate(widget.medicines.length, (i) => i));
  }

  List<MedicineItemModel> get _selectedMedicines =>
      _selectedIndexes.map((i) => widget.medicines[i]).toList();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BenefitServiceRequestCubit, BenefitServiceRequestState>(
      listener: (context, state) {
        if (state is BenefitServiceRequestLoading) {
          BotToast.showLoading(allowClick: false);
        } else {
          BotToast.closeAllLoading();
          if (state is BenefitServiceRequestSubmitSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const BenefitServiceRequestSuccessPage(
                    type: BenefitServiceType.medicine),
              ),
            );
          } else if (state is BenefitServiceRequestError) {
            BotToast.showSimpleNotification(title: state.message);
          }
        }
      },
      child: Scaffold(
        backgroundColor: R.color.backgroundColorNew,
        body: Column(
          children: [
            _buildAppBar(),
            _buildScanBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildMedicineList(),
                    GapH(12),
                    SectionAddNote(
                      key: _noteKey,
                      showCameraIcons: false,
                      initialFiles: [widget.capturedImage],
                      showDeleteIcon: false,
                    ),
                    GapH(80),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
          stops: const [0.01, 0.99],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          R.string.benefit_medicine.tr(),
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700, color: R.color.white),
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  Widget _buildScanBanner() {
    return Container(
      color: const Color(0xFFFFFAEB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  size: 16, color: Color(0xFF008479)),
              GapW(8),
              Text(
                R.string.benefit_scan_medicine_found.tr(
                    namedArgs: {'count': widget.medicines.length.toString()}),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF001917),
                ),
              ),
            ],
          ),
          GapH(4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              R.string.benefit_scan_check_hint.tr(),
              style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
    return Column(
      spacing: 12,
      children: [
        for (int i = 0; i < widget.medicines.length; i++)
          _buildMedicineItem(i, widget.medicines[i]),
      ],
    );
  }

  Widget _buildMedicineItem(int index, MedicineItemModel medicine) {
    final isSelected = _selectedIndexes.contains(index);
    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedIndexes.remove(index);
        } else {
          _selectedIndexes.add(index);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFEAF9F7) : Colors.white,
          shape: RoundedRectangleBorder(
            side: isSelected
                ? const BorderSide(width: 2, color: Color(0xFF0FB4A5))
                : BorderSide.none,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: SvgPicture.asset(R.icons.ic_benefit_medicine_item),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicationName ?? '',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF008479)
                          : const Color(0xFF111514),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.46,
                    ),
                  ),
                    const SizedBox(height: 12),
                    Text(
                      '${R.string.quantity.tr()}: ${medicine.amount?.toStringAsFixed(0) ?? ''} ${medicine.unit ?? ''}'.trim(),
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF008479)
                            : const Color(0xFF5D6465),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.46,
                        letterSpacing: 0.40,
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: R.color.greenGradientTop02,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final selected = _selectedIndexes.length;
    final total = widget.medicines.length;
    final isEnabled = selected > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: isEnabled ? _onSubmit : null,
          child: Container(
            height: 48,
            decoration: isEnabled
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(colors: [
                      R.color.greenGradientTop,
                      R.color.greenGradientMid,
                      R.color.greenGradientBottom,
                    ]),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(200),
                    color: R.color.color0xffC2C2C2,
                  ),
            child: Center(
              child: Text(
                R.string.benefit_send_medicine_request.tr(namedArgs: {
                  'selected': selected.toString(),
                  'total': total.toString()
                }),
                style: TextStyle(
                  color: isEnabled ? R.color.white : R.color.grey200,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    final note = _noteKey.currentState?.getNote().note ?? '';
    final gptParsedResult = jsonEncode({
      'metadata': {
        'totalItems': _selectedMedicines.length,
      },
      'items': _selectedMedicines.map((m) => {
        'name': m.medicationName ?? '',
        'unit': m.unit ?? '',
        'amount': m.amount?.toStringAsFixed(0) ?? '',
      }).toList(),
    });
    context.read<BenefitServiceRequestCubit>().submitMedicineRequest(
          selectedMedicines: _selectedMedicines,
          gptParsedResult: gptParsedResult,
          imageUrl: null,
          note: note,
        );
  }
}
