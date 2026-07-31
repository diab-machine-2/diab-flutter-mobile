import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/clinic_result_scan_response.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_cubit.dart';
import 'package:medical/src/widget/benefit/benefit_service_request_success_page.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitLabTestScanResultPage extends StatefulWidget {
  final ClinicResultScanData? scanData;
  final File capturedImage;

  const BenefitLabTestScanResultPage({
    Key? key,
    required this.scanData,
    required this.capturedImage,
  }) : super(key: key);

  @override
  State<BenefitLabTestScanResultPage> createState() =>
      _BenefitLabTestScanResultPageState();
}

class _BenefitLabTestScanResultPageState
    extends State<BenefitLabTestScanResultPage> {
  late Set<int> _selectedIndexes;
  final GlobalKey<SectionAddNoteState> _noteKey = GlobalKey();

  List<String> get _services => widget.scanData?.services ?? [];

  @override
  void initState() {
    super.initState();
    _selectedIndexes =
        Set.from(List.generate(_services.length, (i) => i));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BenefitServiceRequestCubit, BenefitServiceRequestState>(
      listener: (context, state) {
        if (state is BenefitServiceRequestLoading) {
          BotToast.showLoading(allowClick: false);
        } else {
          BotToast.closeAllLoading();
          if (state is BenefitServiceRequestSubmitSuccess) {
            final fromBenefitBundle =
                context.read<BenefitServiceRequestCubit>().itemId != null;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BenefitServiceRequestSuccessPage(
                    type: BenefitServiceType.labTest,
                    fromBenefitBundle: fromBenefitBundle),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.scanData?.diagnose?.isNotEmpty == true) ...[
                      _buildDiagnoseCard(),
                      GapH(12),
                    ],
                    _buildServiceList(),
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
          R.string.paraclinical.tr(),
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
              SvgPicture.asset(
                R.icons.ic_benefit_request_success,
                width: 18,
                height: 18,
              ),
              GapW(8),
              Text(
                R.string.benefit_scan_lab_found
                    .tr(namedArgs: {'count': _services.length.toString()}),
                style: const TextStyle(
                  fontSize: 14,
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
              R.string.benefit_scan_lab_check_hint.tr(),
              style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnoseCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            R.string.benefit_scan_diagnose_lab_title.tr(),
            style: const TextStyle(
              color: Color(0xFF111515),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.32,
              letterSpacing: 0.04,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1.15, color: Color(0xFFDADEDF)),
                borderRadius: BorderRadius.circular(8.50),
              ),
            ),
            child: Text(
              widget.scanData!.diagnose!,
              style: const TextStyle(
                color: Color(0xFF111515),
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.46,
                letterSpacing: 0.40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return Column(
      spacing: 12,
      children: [
        for (int i = 0; i < _services.length; i++)
          _buildServiceItem(i, _services[i]),
      ],
    );
  }

  Widget _buildServiceItem(int index, String serviceName) {
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
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFF008479),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  R.icons.ic_benefit_lab_examination,
                  width: 20,
                  height: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF008479)
                          : const Color(0xFF111514),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.46,
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
    final total = _services.length;
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
                R.string.benefit_send_lab_request.tr(namedArgs: {
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
    if (_selectedIndexes.isEmpty) return;

    final note = _noteKey.currentState?.getNote().note ?? '';
    final selected = _selectedIndexes.map((i) => _services[i]).toList();
    final gptParsedResult = jsonEncode({
      'diagnose': widget.scanData?.diagnose ?? '',
      'services': selected,
    });
    context.read<BenefitServiceRequestCubit>().submitLabTestRequest(
          selectedServices: selected,
          diagnose: widget.scanData?.diagnose,
          gptParsedResult: gptParsedResult,
          imageUrl: null,
          note: note,
        );
  }
}
