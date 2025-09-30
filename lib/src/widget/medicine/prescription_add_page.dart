import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/src/modal/medicine/prescription_model.dart';
import '../../../res/R.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../modal/medicine/medicine_item_model.dart';
import '../../utils/navigator_name.dart';
import '../../widgets/CalendarPicker/custom_date_picker2.dart';
import '../BloodSugar/widget/section_add_note.dart';
import '../helper/helper.dart';
import 'medicine_add_page.dart';
import 'widgets/medicine_card.dart';

enum PrescriptionMode {
  create, // Tạo đơn thuốc
  edit, // chỉnh sửa đơn thuốc
  reuse, // sử dụng lại đơn thuốc
}

class PrescriptionAddPage extends StatefulWidget {
  PrescriptionAddPage({super.key, this.prescriptionMode, this.medicineItem, this.prescription, this.medicineItems});

  final PrescriptionMode? prescriptionMode;
  final MedicineItemModel? medicineItem;
  final List<MedicineItemModel>? medicineItems;
  final PrescriptionModel? prescription;

  @override
  State<PrescriptionAddPage> createState() => _PrescriptionAddPageState();
}

class _PrescriptionAddPageState extends State<PrescriptionAddPage> {
  final List<MedicineItemModel> _medicines = [];

  final TextEditingController _controllerPrescriptionName = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();
  final List<dynamic> _files = [];

  PrescriptionModel _prescription = PrescriptionModel();
  late PrescriptionMode _prescriptionMode;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    if (widget.prescriptionMode == null) {
      _prescriptionMode = PrescriptionMode.create;
    } else {
      _prescriptionMode = widget.prescriptionMode!;
    }

    if (widget.medicineItem != null) _medicines.add(widget.medicineItem!);
    if (widget.medicineItems != null) _medicines.addAll(widget.medicineItems!);
    if (widget.prescription != null) initPrescription(widget.prescription!);
  }

  void initPrescription(PrescriptionModel prescription) {
    _prescription = prescription;
    _controllerPrescriptionName.text = prescription.prescriptionName ?? '';
    _controllerNote.text = prescription.note ?? '';

    if (prescription.patientMedications != null) {
      _medicines.addAll(prescription.patientMedications!);
    }
  }

  Future<void> _addMedicine() async {
    final result = await Navigator.pushNamed(
      context,
      NavigatorName.medicine_search,
      arguments: {
        'mode': MedicineMode.addMore,
      },
    );
    if (result != null && result is MedicineItemModel) {
      setState(() {
        _medicines.add(result);
      });
    }
  }

  Future<void> _editMedicine(int index) async {
    final MedicineItemModel? result = await Navigator.pushNamed(context, NavigatorName.medicine_add, arguments: {
      'medicineItem': _medicines[index],
      'mode': MedicineMode.edit,
    });
    if (result != null) {
      setState(() {
        _medicines[index] = result; // cập nhật thuốc đã sửa
      });
    }
  }

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
              Navigator.of(context).pop();
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
                    style: TextStyle(color: R.color.color0xff111515, fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              R.string.prescription_name.tr(),
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
            child: TextField(
              autofocus: true,
              controller: _controllerPrescriptionName,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: R.string.prescription_name.tr(),
                counterText: '',
              ),
              style: TextStyle(
                color: R.color.grey_2,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              onChanged: (text) {},
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
          InkWell(
            onTap: () {
              _showDatePicker(context);
            },
            child: Container(
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
                    convertDateTimeToUTC((selectedDate ?? DateTime.now()), 'dd/MM/yyyy'),
                    style: TextStyle(color: R.color.color0xff111515, fontSize: 15, fontWeight: FontWeight.w400),
                  ),
                  SvgPicture.asset(R.icons.ic_calendar, width: 20),
                ],
              ),
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
        InkWell(
          onTap: _addMedicine,
          child: Container(
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
                    style: TextStyle(color: R.color.color0xff008479, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _medicines.length,
          padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
          itemBuilder: (context, index) {
            return MedicineCard(
                medicine: _medicines[index],
                onEdit: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    NavigatorName.medicine_add,
                    arguments: {
                      'mode': MedicineMode.edit,
                      'medicine': _medicines[index],
                    },
                  );
                  if (result is MedicineItemModel) {
                    setState(() {
                      _medicines[index] = result; // update lại item đã sửa
                    });
                  }
                },
                onDelete: () {
                  setState(() {
                    _medicines.removeAt(index);
                  });
                });
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
        onTap: () {
          if (_controllerPrescriptionName.text.isEmpty) return;

          _prescription = _prescription.copyWith(
            prescriptionName: _controllerPrescriptionName.text,
            note: _controllerNote.text,
            startDate: selectedDate,
            patientMedications: _medicines,
            status: 0,
          );

          if (_prescriptionMode == PrescriptionMode.reuse) {
            Navigator.pop(context, true);
            context.read<MedicineBloc>().add(CreateNewPrescriptionEvent(_prescription));
          } else {
            Navigator.pushNamed(context, NavigatorName.prescription_remind, arguments: {'prescription': _prescription});
          }
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
              _prescriptionMode == PrescriptionMode.reuse ? R.string.reuse_prescription.tr() : R.string.set_time.tr(),
              style: TextStyle(color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    CustomCalendarDatePicker2.showDatePicker(context,
        minTime: DateTime.now(),
        maxTime: DateTime.parse('3000-01-01 00:00:00.000Z'),
        showTitleActions: true,
        onChanged: (date) {}, onConfirm: (date) async {
      setState(() {
        selectedDate = date;
      });
    },
        currentTime: selectedDate == null ? DateTime.parse('1970-01-01 00:00:00.000Z') : selectedDate,
        locale: LocaleType.vi);
  }
}
