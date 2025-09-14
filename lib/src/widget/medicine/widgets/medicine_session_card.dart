
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../res/R.dart';
import '../../../modal/medicine/prescription_schedule_model.dart';

class MedicineSessionCard extends StatefulWidget {
  const MedicineSessionCard({super.key, required this.session, required this.isExpanded, required this.onTap});
  final PrescriptionsBySessionModel session;
  final bool isExpanded;
  final Function(int, int, bool) onTap;

  @override
  State<MedicineSessionCard> createState() => _MedicineSessionCardState();
}

class _MedicineSessionCardState extends State<MedicineSessionCard> {
  bool isExpanded = false;

  @override
  void initState() {
    isExpanded = widget.isExpanded;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildScheduleCard(
      widget.session,
      widget.onTap,
    );
  }

  Widget _buildScheduleCard(
      PrescriptionsBySessionModel session,
      Function(int, int, bool) onTap,
      ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            isExpanded = expanded;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          session.session.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.32,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
        trailing: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0.0, // 0.5 turn = 180°
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(
            R.icons.ic_chevron_up,
            width: 12,
            height: 6,
          ),
        ),
        backgroundColor: const Color(0xFF0FB4A5),
        collapsedBackgroundColor: const Color(0xFF0FB4A5),
        children: session.prescriptions.asMap().entries.map((entry) {
          final presIndex = entry.key;
          final pres = entry.value;
          final formattedTime =
              "${pres.time.hour.toString().padLeft(2, '0')}:${pres.time.minute.toString().padLeft(2, '0')}";

          return Container(
            color: Colors.white,
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 12, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên đơn thuốc + giờ
                  Container(
                    width: double.infinity,
                    height: 38,
                    color: Color(0xFFFFFDEF),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 253 / 375,
                          height: 22,
                          child: Text(
                            pres.prescriptionName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              height: 1.46,
                              color: Color(0xFF95682E),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1.46,
                            color: Color(0xFF95682E),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  ..._buildListOfMedicine(presIndex, pres.medications, onTap),

                  // Ghi chú (nếu có)
                  if (pres.note != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Ghi chú: ${pres.note}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildListOfMedicine(
      int prescriptionIndex,
      List<MedicationInSession> medicationList,
      Function(int, int, bool) onTap,
      ) {
    List<Widget> widgets = [];
    for (var i = 0; i < medicationList.length; i++) {
      final medication = medicationList[i];
      widgets.add(Padding(
        padding: i == 0 ? EdgeInsets.fromLTRB(0, 12, 0, 16) : EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: _buildMedicineItem(medication.medicineName, medication.dosage, medication.isTaken, () {
          onTap(prescriptionIndex, i, !medication.isTaken);
          setState(() {
            medication.isTaken = !medication.isTaken;
          });
        }),
      ));
      if (i != medicationList.length - 1) {
        widgets.add(Divider(color: Color(0xFFDADEDF)));
      }
    }
    return widgets;
  }

  Widget _buildMedicineItem(
      String title,
      String subtitle,
      bool isTaken,
      VoidCallback onTap,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    height: 1.46,
                    color: Color(0xFF111515),
                  )),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.5,
                  letterSpacing: 0.4,
                  color: Color(0xFF5E6566),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                isTaken ? R.icons.ic_medicine_used : R.icons.ic_medicine_unused,
                width: 32,
                height: 32,
              ),
              Text(
                isTaken ? R.string.used.tr() : R.string.not_used.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  height: 1.5,
                  letterSpacing: 0.4,
                  color: isTaken ? Color(0xFF008479) : Color(0xFFBFC6C6),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
