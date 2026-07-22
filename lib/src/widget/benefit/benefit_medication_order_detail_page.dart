import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/medication_order_response.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
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
                  _buildStatusCard(),
                  GapH(12),
                  if (order.isMedicine) ...[
                    _buildInfoSection(
                      R.string.benefit_order_prescription_name.tr(),
                      order.prescriptionName ?? '—',
                    ),
                    GapH(12),
                    _buildMedicineSection(),
                  ] else ...[
                    _buildInfoSection(
                      R.string.benefit_order_diagnose.tr(),
                      order.diagnose ?? '—',
                    ),
                    GapH(12),
                    _buildServicesSection(),
                  ],
                  if (order.note != null && order.note!.isNotEmpty) ...[
                    GapH(12),
                    _buildInfoSection(
                      R.string.benefit_order_note.tr(),
                      order.note!,
                    ),
                  ],
                  GapH(24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          R.string.benefit_order_detail_title.tr(),
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

  Widget _buildStatusCard() {
    final isMedicine = order.isMedicine;
    final iconBgColor =
        isMedicine ? const Color(0xFFE49F13) : const Color(0xFF01645A);
    final iconPath =
        isMedicine ? R.icons.ic_purchase_medicine : R.icons.ic_paraclinical;
    final typeLabel = isMedicine
        ? R.string.benefit_order_type_medicine.tr()
        : R.string.benefit_order_type_lab.tr();

    final dateStr = order.createDate != null
        ? DateFormat('dd/MM/yyyy').format(order.createDate!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: SvgPicture.asset(iconPath, width: 24, height: 24,
                  color: Colors.white),
            ),
          ),
          GapW(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: R.color.color0xff111515,
                  ),
                ),
                GapH(4),
                if (order.code != null)
                  Text(
                    '${R.string.benefit_order_code.tr()}: ${order.code}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF636A6B)),
                  ),
                GapH(2),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF636A6B)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F7F5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              R.string.benefit_already_requested.tr(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF008479),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF636A6B),
            ),
          ),
          GapH(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: R.color.color0xff111515,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSection() {
    final medicines = _parseMedicines();
    if (medicines.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              R.string.benefit_order_medicine_list.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111515),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: medicines.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF008479),
                      shape: BoxShape.circle,
                    ),
                  ),
                  GapW(10),
                  Expanded(
                    child: Text(
                      medicines[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GapH(8),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = order.parsedServices;
    if (services.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              R.string.benefit_order_services_list.tr(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111515),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: services.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF008479),
                      shape: BoxShape.circle,
                    ),
                  ),
                  GapW(10),
                  Expanded(
                    child: Text(
                      services[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: R.color.color0xff111515,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GapH(8),
        ],
      ),
    );
  }

  List<String> _parseMedicines() {
    if (order.gptParsedResult == null || order.gptParsedResult!.isEmpty) {
      if (order.medicationName != null && order.medicationName!.isNotEmpty) {
        return [order.medicationName!];
      }
      return [];
    }
    try {
      final raw = order.gptParsedResult!;
      final List<String> results = [];
      final regex = RegExp(r'"medication_name"\s*:\s*"([^"]+)"');
      for (final match in regex.allMatches(raw)) {
        final name = match.group(1);
        if (name != null && name.isNotEmpty) results.add(name);
      }
      if (results.isNotEmpty) return results;
    } catch (_) {}
    if (order.medicationName != null && order.medicationName!.isNotEmpty) {
      return [order.medicationName!];
    }
    return [];
  }
}
