import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../res/R.dart';
import '../../../modal/medicine/prescription_schedule_model.dart';
import '../../../repo/medicine/medicine_client.dart';
import 'medicine_session_card.dart';

class MedicineSessionBottomSheet extends StatefulWidget {
  MedicineSessionBottomSheet(
      {super.key, required this.sessionList, required this.ids});
  final List<PrescriptionsBySessionModel> sessionList;
  final List<String> ids;

  @override
  State<MedicineSessionBottomSheet> createState() =>
      _MedicineSessionBottomSheetState();
}

class _MedicineSessionBottomSheetState
    extends State<MedicineSessionBottomSheet> {
  final _medicineClient = MedicineClient();
  final List<String> usedIds = <String>[];
  final List<String> unusedIds = <String>[];

  int _executeDayTimeFromSession(MedicineSession session) {
    switch (session) {
      case MedicineSession.MORNING:
        return 1;
      case MedicineSession.NOON:
        return 2;
      case MedicineSession.AFTERNOON:
        return 3;
      case MedicineSession.EVENING:
        return 4;
    }
  }

  List<int> _buildExecuteDayTimes() {
    return widget.sessionList
        .map((s) => _executeDayTimeFromSession(s.session))
        .toSet()
        .toList();
  }

  List<String> _buildPrescriptionIds() {
    final ids = <String>{};
    for (final session in widget.sessionList) {
      for (final prescription in session.prescriptions) {
        ids.add(prescription.prescriptionId);
      }
    }
    return ids.toList();
  }

  List<Map<String, dynamic>> _buildListPatientMedication() {
    final List<Map<String, dynamic>> result = [];

    for (final session in widget.sessionList) {
      for (final prescription in session.prescriptions) {
        for (final med in prescription.medications) {
          result.add({
            'PatientMedicationId': med.patientMedicationId,
            'Dosage': med.dosageValue,
          });
        }
      }
    }

    return result;
  }

  @override
  void initState() {
    usedIds.addAll(widget.ids);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.66, // mặc định mở ra 2/3 màn hình
      minChildSize: 0.4, // có thể kéo xuống còn 40% màn hình
      maxChildSize: 0.66, // tối đa cũng chỉ 2/3 màn hình
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: widget.sessionList.length,
                  itemBuilder: (_, index) {
                    final session = widget.sessionList[index];

                    return MedicineSessionCard(
                      session: session,
                      isExpanded: false,
                      onTap:
                          (prescriptionIndex, medicationIndex, isTaken) async {
                        final med = session.prescriptions[prescriptionIndex]
                            .medications[medicationIndex];
                        await _medicineClient.useMedicine(
                            id: med.id,
                            patientMedicationId: med.patientMedicationId,
                            dosage: med.dosageValue);
                      },
                    );
                  },
                ),
              ),
              _buildCheckAllButton(),
              // _buildUnCheckAllButton(),
              _buildCloseButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckAllButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          Navigator.pop(context);
          await _medicineClient.usedAllMedicinesToday(
            status: 0,
            listPatientMedication: _buildListPatientMedication(),
            prescriptionIds: _buildPrescriptionIds(),
            executeDayTimes: _buildExecuteDayTimes(),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: R.color.mainColor,
            borderRadius: BorderRadius.circular(200),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.centerRight,
              colors: [R.color.greenGradientTop, R.color.greenGradientBottom],
            ),
          ),
          child: Center(
            child: Text(
              R.string.used_all.tr(),
              style: TextStyle(
                  color: R.color.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnCheckAllButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 0, bottom: 16, left: 12, right: 12),
      child: InkWell(
        onTap: () async {
          Navigator.pop(context);
          await _medicineClient.usedAllMedicinesToday(
            status: 1,
            listPatientMedication: _buildListPatientMedication(),
            prescriptionIds: _buildPrescriptionIds(),
            executeDayTimes: _buildExecuteDayTimes(),
          );
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(200),
            border: Border.all(
              color: R.color.mainColor,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              R.string.unused_all.tr(),
              style: TextStyle(
                  color: R.color.mainColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 0, bottom: 16, left: 12, right: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(200),
            border: Border.all(
              color: R.color.mainColor,
              width: 1.0,
            ),
          ),
          child: Center(
            child: Text(
              R.string.close.tr(),
              style: TextStyle(
                  color: R.color.mainColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
