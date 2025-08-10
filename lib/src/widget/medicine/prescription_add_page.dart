import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../res/R.dart';
import '../../modal/medicine/medicine_prescription_model.dart';
import '../../utils/navigator_name.dart';
import '../BloodSugar/widget/section_add_note.dart';

class PrescriptionAddPage extends StatefulWidget {
  const PrescriptionAddPage({super.key});

  @override
  State<PrescriptionAddPage> createState() => _PrescriptionAddPageState();
}

class _PrescriptionAddPageState extends State<PrescriptionAddPage> {
  final List<Medicine> medicines = [
    Medicine(
      name: 'Gliclazid (Glycinorm-80)',
      dosage: '80mg',
      quantity: 36,
      mealTime: 'Trước ăn',
      frequency: 'Mỗi ngày',
      time: 'Sáng',
      dose: 1,
    ),
    Medicine(
      name: 'Metformin (Metformin Stella 1000mg)',
      dosage: '1000 mg',
      quantity: 36,
      mealTime: 'Sau ăn',
      frequency: 'Mỗi ngày',
      time: 'Tối',
      dose: 1,
    ),
    Medicine(
      name: 'Fluvastatin (Autifan 40)',
      dosage: '40mg',
      quantity: 30,
      mealTime: 'Sau ăn',
      frequency: 'Mỗi ngày',
      time: 'Tối',
      dose: 1,
      note: 'uống lúc 20h',
    ),
  ];

  final TextEditingController _controllerNote = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();
  final List<dynamic> _files = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: R.color.backgroundColorNew,
      appBar: AppBar(
        leading: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.white),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                NavigatorName.tabbar,
                (route) => false,
              );
            }),
        title: Transform(
          transform: Matrix4.translationValues(-20, 0.0, 0.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              R.string.add_prescription.tr(),
              style: TextStyle(color: R.color.white, fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ),
        ),
        actions: [
          Center(
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(NavigatorName.medicine_tutorial),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  R.string.tutorial.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
        ],
        backgroundColor: R.color.transparent,
        //No more green
        elevation: 0.0,
        //Shadow gone
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [R.color.greenGradientMid, R.color.greenGradientBottom],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPrescription(),
          _buildMedicineList(),
          _buildNote(),
          _buildSetTimeButton(),
        ],
      ),
    );
  }

  Widget _buildPrescription() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAEB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  R.icons.ic_information,
                  width: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    R.string.prescription_warning.tr(),
                    style: TextStyle(
                        color: R.color.color0xff111515, fontSize: 13, fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              R.string.prescription_name.tr(),
              style: TextStyle(
                  color: R.color.color0xff111515, fontSize: 18, fontWeight: FontWeight.w700
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFDADEDF)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Bệnh đái tháo đường \nkhông phụ thuộc insuline',
              style: TextStyle(color: R.color.color0xff111515, fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              R.string.start_date.tr(),
              style: TextStyle(color: R.color.color0xff111515, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFFDADEDF)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '06/8/2025',
                  style: TextStyle(
                    color: R.color.color0xff111515, fontSize: 15, fontWeight: FontWeight.w400
                  ),
                ),
                SvgPicture.asset(R.icons.ic_calendar, width: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMedicineList() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(11),
          margin: EdgeInsets.only(top: 12, left: 12, right: 12),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              width: 1,
              color: R.color.color0xff008479,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16, color: R.color.color0xff008479),
                const SizedBox(width: 6),
                Text(
                  R.string.add_medicine.tr(),
                  style: TextStyle(
                      color: R.color.color0xff008479, fontSize: 15, fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: medicines.length,
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          itemBuilder: (context, index) {
            return MedicineCard(medicine: medicines[index]);
          },
        ),
      ],
    );
  }

  Widget _buildNote() {
    return Container(
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
      child: SectionAddNote(
        controllerNote: _controllerNote,
        maxMedia: 5,
        key: _sectionAddNoteKey,
        initialFiles: _files,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 12,
      ),
    );
  }

  Widget _buildSetTimeButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: GestureDetector(
        // onTap: () => _showPopupInputOptions(context),
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
              R.string.set_timer.tr(),
              style: TextStyle(color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class MedicineCard extends StatelessWidget {
  final Medicine medicine;

  const MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14016961),
            offset: const Offset(1, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(R.icons.ic_medicine, width: 38),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${medicine.name} ${medicine.dosage}",
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: R.color.color0xff111515
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "${medicine.quantity} Viên  •  ${medicine.mealTime}  •  ${medicine.frequency}",
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 52,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: R.color.backgroundColorNew,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          medicine.time,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400, color: R.color.color0xff5E6566
                          ),
                        ),
                        Text(
                          medicine.dose.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold, color: R.color.color0xff5E6566
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (medicine.note != null) ...[
                    SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: 'Ghi chú: ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: medicine.note),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(R.icons.ic_delete, width: 20),
                  onPressed: () {
                    // TODO: Xoá thuốc
                  },
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: SvgPicture.asset(R.icons.ic_edit, width: 20),
                    onPressed: () {
                      // TODO: Sửa thuốc
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
