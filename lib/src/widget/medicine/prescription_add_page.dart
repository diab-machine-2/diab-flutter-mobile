import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/medicine/prescription_model.dart';
import '../../../res/R.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../modal/base/images.dart';
import '../../modal/medicine/image_note_model.dart';
import '../../modal/medicine/medicine_item_model.dart';
import '../../utils/const.dart';
import '../../utils/navigator_name.dart';
import '../../widgets/CalendarPicker/custom_date_picker2.dart';
import '../BloodSugar/widget/section_add_note.dart';
import '../helper/helper.dart';
import '../helper/show_message.dart';
import 'medicine_add_page.dart';
import 'widgets/medicine_card.dart';

enum PrescriptionMode {
  create, // Tạo đơn thuốc
  edit, // chỉnh sửa đơn thuốc
  reuse, // sử dụng lại đơn thuốc
}

class PrescriptionAddPage extends StatefulWidget {
  PrescriptionAddPage(
      {super.key,
      this.prescriptionMode,
      this.medicineItem,
      this.prescription,
      this.medicineItems});

  final PrescriptionMode? prescriptionMode;
  final MedicineItemModel? medicineItem;
  final List<MedicineItemModel>? medicineItems;
  final PrescriptionModel? prescription;

  @override
  State<PrescriptionAddPage> createState() => _PrescriptionAddPageState();
}

class _PrescriptionAddPageState extends State<PrescriptionAddPage> {
  late MedicineBloc _bloc;
  final List<MedicineItemModel> _medicines = [];

  final TextEditingController _controllerPrescriptionName =
      TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();
  final List<dynamic> _files = [];

  PrescriptionModel _prescription = PrescriptionModel();
  late PrescriptionMode _prescriptionMode;
  DateTime? selectedDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _bloc = MedicineBloc();
    final now = DateTime.now();
    // Chuẩn hoá selectedDate chỉ còn phần ngày (không giữ giờ/phút/giây)
    selectedDate = DateTime(now.year, now.month, now.day);
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
    if (prescription.startDate != null) {
      // Luôn chuẩn hoá startDate chỉ theo ngày
      final d = prescription.startDate!;
      selectedDate = DateTime(d.year, d.month, d.day);
    }

    final images = (prescription.imagesPrescription ?? [])
        .map((note) => ImagesModel(
              id: note.id,
              url: _buildFullUrl(note.id),
            ))
        .toList();
    if (images.isEmpty) {
      _prescription.isExistImage = false;
    } else {
      _prescription.isExistImage = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sectionAddNoteKey.currentState!
          .updateFilesAndNote(images, prescription.note ?? '');
    });

    if (prescription.patientMedications != null) {
      _medicines.addAll(prescription.patientMedications!);
      for (var medicine in _medicines) {
        if ((medicine.imagesPatientMedications ?? []).isEmpty) {
          medicine.isExistImage = false;
        } else {
          medicine.isExistImage = true;
        }
      }
    }
  }

  String _buildFullUrl(String id) {
    if (Const.ENVIRONMENT_DEFAULT == 'product') {
      return Uri.https(Const.DOMAIN, 'App/Image/$id').toString();
    } else if (Const.ENVIRONMENT_DEFAULT == 'staging') {
      return Uri.https(Const.DOMAIN_STAGING, 'App/Image/$id').toString();
    } else {
      return Uri.https(Const.DOMAIN_DEV, 'App/Image/$id').toString();
    }
  }

  Future<void> _addMedicine() async {
    final result = await Navigator.pushNamed(
      context,
      NavigatorName.medicine_search,
      arguments: {
        'mode': MedicineMode.addMore,
        'index': _medicines.length,
      },
    );
    if (result != null && result is MedicineItemModel) {
      setState(() {
        _medicines.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await _showConfirmDialog(context);
        return shouldLeave; // true = pop, false = stay
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: R.color.backgroundColorNew,
        appBar: AppBar(
          leading: IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(Icons.arrow_back, color: R.color.white),
              onPressed: () {
                _showConfirmDialog(context);
              }),
          title: Transform(
            transform: Matrix4.translationValues(-20, 0.0, 0.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                _prescriptionMode == PrescriptionMode.edit
                    ? R.string.edit_prescription.tr()
                    : R.string.add_prescription.tr(),
                style: TextStyle(
                    color: R.color.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
          actions: [
            Center(
              child: InkWell(
                onTap: () => Navigator.of(context)
                    .pushNamed(NavigatorName.medicine_tutorial),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    R.string.tutorial.tr(),
                    style: TextStyle(
                        color: R.color.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
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
      ),
    );
  }

  Future<bool> _showConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_back_icon,
                            width: 64, height: 64),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(R.string.ban_muon_quay_lai.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: R.color.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(R.string.confirm_to_back.tr(),
                              textAlign: TextAlign.center,
                              style: R.style.normalTextStyle),
                        ),
                        SizedBox(height: 16),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        height: 43,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            color: R.color.grayBorder),
                                        child: Center(
                                          child: Text(R.string.van_o_lai.tr(),
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        ))),
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          color: R.color.red,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                R.color.greenGradientTop,
                                                R.color.greenGradientBottom
                                              ])),
                                      child: Center(
                                        child: Text(R.string.confirm.tr(),
                                            style: TextStyle(
                                                color: R.color.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    )),
                              ),
                            ])
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                        icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  )
                ],
              ),
            );
          },
        ) ??
        false;
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
                        color: R.color.color0xff111515,
                        fontSize: 13,
                        fontWeight: FontWeight.w400),
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
                  color: R.color.color0xff111515,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
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
              style: TextStyle(
                  color: R.color.color0xff111515,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
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
                    convertDateTimeToUTC(
                        (selectedDate ?? DateTime.now()), 'dd/MM/yyyy'),
                    style: TextStyle(
                        color: R.color.color0xff111515,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
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
                    style: TextStyle(
                        color: R.color.color0xff008479,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
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
                // Create/Reuse: show amount (original quantity). Edit: show remain (left after use).
                showAmountInsteadOfRemain:
                    _prescriptionMode == PrescriptionMode.create ||
                        _prescriptionMode == PrescriptionMode.reuse,
                onEdit: () async {
                  //Chỉnh sửa thuốc
                  final result = await Navigator.pushNamed(
                    context,
                    NavigatorName.medicine_add,
                    arguments: {
                      'mode': MedicineMode.edit,
                      'medicine': _medicines[index],
                      'index': index,
                      'isReuse': _prescriptionMode == PrescriptionMode.reuse,
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
        maxLength: 50,
        key: _sectionAddNoteKey,
        initialFiles: _files,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 12,
      ),
    );
  }

  Widget _buildSetTimeButton() {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is CreatePrescriptionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tạo đơn thuốc thành công!')),
            );
            Navigator.pushReplacementNamed(context, NavigatorName.prescription);
          }
        },
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: GestureDetector(
            onTap: () {
              if (_isSubmitting) return;

              if (_controllerPrescriptionName.text.trim().isEmpty) {
                Message.showToastMessage(
                  context,
                  R.string.smart_goal_name_empty.tr(
                    args: [R.string.prescription_name.tr()],
                  ),
                );
                return;
              }

              setState(() {
                _isSubmitting = true;
              });

              final DateTime rawSelectedDate = selectedDate ?? DateTime.now();
              // Chuẩn hoá startDate thành ngày (00:00) để tránh lệch ngày do timezone
              // Lưu startDate theo mốc 00:00:00 UTC của ngày được chọn,
              // để khi xem timestamp sẽ đúng ngày (không bị lùi sang ngày hôm trước do múi giờ).
              final DateTime normalizedStartDate = DateTime.utc(
                rawSelectedDate.year,
                rawSelectedDate.month,
                rawSelectedDate.day,
              );

              _prescription = _prescription.copyWith(
                prescriptionName: _controllerPrescriptionName.text,
                note: _controllerNote.text,
                startDate: normalizedStartDate,
                patientMedications: _medicines,
                status: 0,
              );

              List<ImageNoteModel> oldPaths = <ImageNoteModel>[];
              Map<String, String> newPaths = {};

              final data = _sectionAddNoteKey.currentState!.getNote();
              int index = 0;

              for (var file in (data.files)) {
                if (file is PickedFile) {
                  final fieldName = 'ImagesPrescription';
                  newPaths[fieldName] = file.path;
                } else if (file is ImagesModel) {
                  final id = (file.url ?? '').split('/').last.trim();
                  oldPaths.add(
                    ImageNoteModel(order: index, id: id),
                  );
                }
                index++;
              }

              _prescription.patientMedications?.forEach((medicine) {
                if (medicine.uploadFiles != null)
                  newPaths.addAll(medicine.uploadFiles!);
              });

              _prescription = _prescription.copyWith(
                imagesPrescription: oldPaths,
              );

              // Khi sử dụng lại đơn thuốc, reset trường remain về null cho tất cả thuốc
              if (_prescriptionMode == PrescriptionMode.reuse &&
                  _prescription.patientMedications != null) {
                final updatedMeds = _prescription.patientMedications!
                    .map((m) => MedicineItemModel(
                          id: m.id,
                          medicationName: m.medicationName,
                          moment: m.moment,
                          frequency: m.frequency,
                          morning: m.morning,
                          afternoon: m.afternoon,
                          midDay: m.midDay,
                          night: m.night,
                          unit: m.unit,
                          amount: m.amount,
                          remain: null,
                          customDay: m.customDay,
                          breakDay: m.breakDay,
                          note: m.note,
                          imagesPatientMedications: m.imagesPatientMedications,
                          uploadFiles: m.uploadFiles,
                        ))
                    .toList();
                _prescription =
                    _prescription.copyWith(patientMedications: updatedMeds);
              }

              if (_prescriptionMode == PrescriptionMode.reuse) {
                _bloc.add(CreateNewPrescriptionEvent(_prescription, newPaths));
                // Keep loading until navigation happens via BlocListener
              } else {
                Navigator.pushNamed(context, NavigatorName.prescription_remind,
                    arguments: {
                      'prescription': _prescription,
                      'paths': newPaths,
                    }).whenComplete(() {
                  if (mounted) {
                    setState(() {
                      _isSubmitting = false;
                    });
                  }
                });
              }
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _isSubmitting ? R.color.grayBorder : R.color.mainColor,
                borderRadius: BorderRadius.circular(200),
                gradient: _isSubmitting
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.centerRight,
                        colors: [
                          R.color.greenGradientTop,
                          R.color.greenGradientBottom
                        ],
                      ),
              ),
              child: Center(
                child: _isSubmitting
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              R.color.greenGradientBottom),
                        ),
                      )
                    : Text(
                        _prescriptionMode == PrescriptionMode.reuse
                            ? R.string.reuse_prescription.tr()
                            : R.string.set_time.tr(),
                        style: TextStyle(
                            color: R.color.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    // CustomCalendarDatePicker2.showDatePicker(context,
    //   minTime: DateTime.now(),
    //   maxTime: DateTime.parse('3000-01-01 00:00:00.000Z'),
    //   showTitleActions: true,
    //   onChanged: (date) {}, onConfirm: (date) async {
    //     setState(() {
    //       selectedDate = date;
    //     });
    //   },
    //   currentTime: selectedDate == null ? DateTime.parse('1970-01-01 00:00:00.000Z') : selectedDate,
    //   locale: LocaleType.vi);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: today,
        lastDate: DateTime(2100),
        currentDate: DateTime.now(),
        selectedDayHighlightColor: const Color(0xFF009688),
        weekdayLabelTextStyle: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        dayTextStyle: const TextStyle(color: Colors.black87),
        selectedDayTextStyle: const TextStyle(color: Colors.white),
        todayTextStyle: const TextStyle(color: Colors.black87),
        disabledDayTextStyle: const TextStyle(color: Colors.grey),
        // calendarViewHeaderTextStyle: const TextStyle(
        //   fontSize: 18,
        //   fontWeight: FontWeight.bold,
        //   color: Colors.black87,
        // ),
        cancelButtonTextStyle: const TextStyle(color: Colors.black54),
        okButtonTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        okButton: Container(
          width: 100,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF009688),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Đồng ý', style: TextStyle(color: Colors.white)),
          ),
        ),
        cancelButton: Container(
          width: 100,
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Hủy',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
      // THÊM ĐÂY: Ràng buộc kích thước dialog để fix RenderBox
      dialogSize:
          const Size(340, 480), // Kích thước cố định, tránh infinite height
      borderRadius: BorderRadius.circular(16),
      value: [DateTime.now()],
      dialogBackgroundColor: Colors.white,
    );

    setState(() {
      if (values?.isNotEmpty == true && values!.first != null) {
        final picked = values.first!;
        // Luôn chuẩn hoá ngày được chọn về 00:00 để đồng nhất
        selectedDate = DateTime(picked.year, picked.month, picked.day);
      }
    });
  }
}
