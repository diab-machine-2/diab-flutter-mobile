import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/response/medication_order_response.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widgets/gap_widget.dart';

class BenefitMedicationOrderDetailPage extends StatelessWidget {
  final MedicationOrderItem order;

  const BenefitMedicationOrderDetailPage({Key? key, required this.order})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPartnerInformation(),
                  const GapH(12),
                  _buildMedicationContentSection(),
                  if (order.note != null && order.note!.isNotEmpty) ...[
                    const GapH(12),
                    _buildNoteSection(),
                  ],
                  const GapH(24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            R.color.greenGradientTop02,
            R.color.greenGradientBottom,
          ],
          stops: const [0.01, 0.99],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          R.string.benefit_order_detail_title.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: R.color.white,
          ),
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back,
            color: R.color.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          InkWell(
            onTap: () async {
              HomeSupportFunctions.showModalAddData(context);
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: const EdgeInsets.fromLTRB(0, 12, 16, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: R.color.color0xffCAFAF5,
                border: Border.all(
                  color: R.color.color0xff8FEBE0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    R.icons.ic_telephone,
                    width: 16,
                    height: 16,
                    color: R.color.greenGradientBottom,
                    fit: BoxFit.scaleDown,
                  ),
                  const GapW(8),
                  Text(
                    R.string.contact.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerInformation() {
    final nameStr = AppSettings.userInfo?.fullName ?? '—';
    final phoneStr = AppSettings.userInfo?.phoneNumber ?? '—';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                R.string.customer_information.tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: R.color.color0xff111515,
                ),
              ),
            ],
          ),
          const GapH(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.name.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff777E90,
                ),
              ),
              Text(
                nameStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: R.color.color0xff111515,
                ),
              ),
            ],
          ),
          const GapH(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                R.string.so_dien_thoai.tr(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff777E90,
                ),
              ),
              Text(
                phoneStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: R.color.color0xff111515,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationContentSection() {
    final isMedicine = order.isMedicine;
    final titleText = isMedicine
        ? R.string.benefit_order_medicine_list.tr()
        : R.string.benefit_order_services_list.tr();

    final headerSubTitle = order.prescriptionName ??
        order.diagnose ??
        R.string.benefit_fallback_diagnose.tr();

    final medList = _getMedicationItems();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x14032B27),
            blurRadius: 8,
            offset: Offset(1, 2),
            spreadRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                titleText,
                style: const TextStyle(
                  color: Color(0xFF111514),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.46,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFE6E8EC),
          ),
          const SizedBox(height: 10),
          Text(
            headerSubTitle,
            style: const TextStyle(
              color: Color(0xFF111515),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.46,
              letterSpacing: 0.40,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 1,
            color: const Color(0xFFE6E8EC),
          ),
          const SizedBox(height: 10),
          if (medList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '—',
                style: TextStyle(color: Color(0xFF636A6B), fontSize: 14),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: medList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final item = medList[index];
                final indexStr = (index + 1).toString().padLeft(2, '0');

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        indexStr,
                        style: const TextStyle(
                          color: Color(0xFF636A6B),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.46,
                          letterSpacing: 0.40,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: Color(0xFF111515),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.46,
                              letterSpacing: 0.40,
                            ),
                          ),
                          if (item.quantity.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  R.string.quantity_label.tr(),
                                  style: TextStyle(
                                    color: Color(0xFF636A6B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.46,
                                    letterSpacing: 0.40,
                                  ),
                                ),
                                Text(
                                  item.quantity,
                                  style: const TextStyle(
                                    color: Color(0xFF636A6B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    height: 1.46,
                                    letterSpacing: 0.40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  List<_MedItemData> _getMedicationItems() {
    if (order.isMedicine) {
      final meds = order.medications;
      if (meds.isNotEmpty) {
        return meds
            .map((m) => _MedItemData(name: m.name, quantity: m.quantity))
            .toList();
      }
      final parsedGpt = _parseGptMedicines();
      if (parsedGpt.isNotEmpty) {
        return parsedGpt;
      }
      if (order.medicationName != null && order.medicationName!.isNotEmpty) {
        return [
          _MedItemData(
            name: order.medicationName!,
            quantity: order.quantity ?? '',
          )
        ];
      }
    } else {
      final services = order.parsedServices;
      if (services.isNotEmpty) {
        return services.map((s) => _MedItemData(name: s, quantity: '')).toList();
      }
    }
    return [];
  }

  List<_MedItemData> _parseGptMedicines() {
    if (order.gptParsedResult == null || order.gptParsedResult!.isEmpty) {
      return [];
    }
    try {
      final raw = order.gptParsedResult!;
      final List<_MedItemData> results = [];
      final regex = RegExp(
          r'"medication_name"\s*:\s*"([^"]+)"(?:,\s*"quantity"\s*:\s*"([^"]+)")?');
      for (final match in regex.allMatches(raw)) {
        final name = match.group(1);
        final qty = match.group(2) ?? '';
        if (name != null && name.isNotEmpty) {
          results.add(_MedItemData(name: name, quantity: qty));
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            R.string.benefit_order_note.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
          const GapH(12),
          TextFormField(
            initialValue: order.note,
            minLines: 2,
            maxLines: null,
            readOnly: true,
            decoration: InputDecoration(
              counterText: null,
              fillColor: R.color.textDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: R.color.color0xffDFE4E4,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: R.color.color0xffDFE4E4,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: R.color.color0xffDFE4E4,
                  width: 1.0,
                ),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: TextStyle(
              fontSize: 14,
              color: R.color.color0xff111515,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedItemData {
  final String name;
  final String quantity;

  _MedItemData({required this.name, required this.quantity});
}
