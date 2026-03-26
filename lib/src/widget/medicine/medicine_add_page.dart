import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../../../res/R.dart';
import '../../modal/base/images.dart';
import '../../modal/medicine/dose_model.dart';
import '../../modal/medicine/image_note_model.dart';
import '../../modal/medicine/medicine_item_model.dart';
import '../../modal/medicine/medicine_tablet_model.dart';
import '../../utils/const.dart';
import '../../utils/navigator_name.dart';
import '../BloodSugar/widget/section_add_note.dart';
import 'widgets/dosage_input_bottom_sheet.dart';
import '../../modal/medicine/medicine_add_model.dart';

enum MedicineMode {
  create,   // thêm mới lần đầu vào đơn thuốc
  edit,     // chỉnh sửa thuốc có sẵn trong đơn thuốc
  addMore,  // thêm thuốc vào đơn thuốc
}

class MedicineAddPage extends StatefulWidget {
  const MedicineAddPage({
    super.key,
    this.medicineMode,
    this.medicineTablet,
    this.medicine,
    this.index,
    this.isFromReuse = false,
  });
  final MedicineMode? medicineMode;
  final MedicineTabletModel? medicineTablet;
  final MedicineItemModel? medicine;
  final int? index;
  /// True when editing a medicine coming from PrescriptionMode.reuse.
  /// In this case, we should treat the edited quantity as the original
  /// amount (not remain), same as create mode.
  final bool isFromReuse;

  @override
  State<MedicineAddPage> createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  late MedicineMode _medicineMode;
  late MedicineItemModel _selectedMedication;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();
  MedicineUnit _unit = MedicineUnit.pill; // viên, gói, ống, ml, khác
  double _amount = 0.0;
  DosageModel? _dosage;
  List<File?> _files = [];
  late bool _isFromReuse;

  final List<MedicineUnit> _medicineUnits = [
    MedicineUnit.pill,
    MedicineUnit.package,
    MedicineUnit.tube,
    MedicineUnit.ml,
    MedicineUnit.other
  ];

  final List<String> _weekDays = [
    R.string.chip_monday.tr(),
    R.string.chip_tuesday.tr(),
    R.string.chip_wednesday.tr(),
    R.string.chip_thursday.tr(),
    R.string.chip_friday.tr(),
    R.string.chip_saturday.tr(),
    R.string.chip_sunday.tr(),
  ];

  bool _submitBtnEnabled = false;

  bool isValid() {
    if ((_dosage?.quantityInMorning ?? 0) == 0 && (_dosage?.quantityInNoon ?? 0) == 0
        && (_dosage?.quantityInAfternoon ?? 0) == 0 && (_dosage?.quantityInNight ?? 0) == 0) return false;
    // if (_frequency == 2 && _customDay.isEmpty) return false;
    // if (_frequency == 3 && _breakDay <= 0) return false;

    return true;
  }

  @override
  void initState() {
    super.initState();

    _isFromReuse = widget.isFromReuse;

    if (widget.medicineMode == null) {
      _medicineMode = MedicineMode.create;
    } else {
      _medicineMode = widget.medicineMode!;
    }

    //Mode create
    _selectedMedication = MedicineItemModel(
      id: widget.medicineTablet?.id ?? widget.medicine?.id ?? '',
      medicationName: widget.medicineTablet?.name ?? widget.medicine?.medicationName ?? '',
    );
    _amount = widget.medicine?.remain ?? widget.medicine?.amount ?? 0.0;
    _quantityController.text = _amount == _amount.roundToDouble()
        ? _amount.toInt().toString()
        : _amount.toStringAsFixed(1);

    //Mode edit
    if (widget.medicine != null) {
      _selectedMedication = widget.medicine!;
      _nameController.text = _selectedMedication.medicationName ?? '';
      _noteController.text = _selectedMedication.note ?? '';
      _unit = MedicineUnit.fromString(_selectedMedication.unit);
      _amount = _selectedMedication.remain ?? _selectedMedication.amount ?? 0.0;

      final raw = (_selectedMedication.customDay ?? '').trim();
      final isValid = RegExp(r'^[0-9,]+$').hasMatch(raw);
      _dosage = DosageModel(
        momentName: _selectedMedication.moment == 1
            ? R.string.truoc_an.tr()
            : _selectedMedication.moment == 2
                ? R.string.sau_an.tr()
                : R.string.during_meal.tr(),
        // Store moment as 1,2,3 to match MedicineItemModel / BE
        moment: _selectedMedication.moment ?? 1,
        frequencyName: _selectedMedication.frequency == 1
            ? R.string.everyday.tr()
            : _selectedMedication.frequency == 2
                ? R.string.ngay_trong_tuan.tr()
                : R.string.every_other_day.tr(),
        // Store frequency as 1,2,3 to match MedicineItemModel / BE
        frequency: _selectedMedication.frequency ?? 1,
        quantityInMorning: _selectedMedication.morning ?? 0.0,
        quantityInNoon: _selectedMedication.midDay ?? 0.0,
        quantityInAfternoon: _selectedMedication.afternoon ?? 0.0,
        quantityInNight: _selectedMedication.night ?? 0.0,
        quantityForDaysInWeek: (_selectedMedication.remain ?? _selectedMedication.amount ?? 0.0),
        quantityForEveryOtherDay: (_selectedMedication.remain ?? _selectedMedication.amount ?? 0.0),
        selectedDaysInWeek: !isValid
            ? []
            : (_selectedMedication.customDay ?? '').split(',').map(int.parse).toList(),
        everyOtherDayNumber: (_selectedMedication.breakDay ?? 0).toInt(),
      );
      _submitBtnEnabled = true;

      final images = (_selectedMedication.imagesPatientMedications ?? [])
          .map((note) => ImagesModel(
        id: note.id,
        url: _buildFullUrl(note.id),
      ))
          .toList();
      if (images.isEmpty) {
        _selectedMedication.isExistImage = false;
      } else {
        _selectedMedication.isExistImage = true;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sectionAddNoteKey.currentState!.updateFilesAndNote(images, _selectedMedication.note ?? '');
      });
    }
  }

  /// Sync the currently edited quantity [_amount] back into the correct field
  /// on [_selectedMedication]:
  /// - If this medicine already has `remain` (coming from an existing prescription),
  ///   we are editing the remaining quantity, so update `remain`.
  /// - Otherwise (AI/analyze or creating new prescription), we are editing the
  ///   original quantity, so update `amount`.
  void _syncQuantityToMedication() {
    final bool hasRemain = !_isFromReuse &&
        (_selectedMedication.remain != null || widget.medicine?.remain != null);

    _selectedMedication = _selectedMedication.copyWith(
      amount: hasRemain ? null : _amount,
      remain: hasRemain ? _amount : null,
    );
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('medicineItem')) {
      final medicineItem = args['medicineItem'] as MedicineTabletModel?;
      if (medicineItem != null) {
        _nameController.text = medicineItem.name;
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _amount += 1.0;
      _quantityController.text = _amount == _amount.roundToDouble()
          ? _amount.toInt().toString()
          : _amount.toStringAsFixed(1);

      _syncQuantityToMedication();

      if (_submitBtnEnabled == false) {
        _submitBtnEnabled = isValid();
      }
    });
  }

  void _decrementQuantity() {
    if (_amount > 0) {
      setState(() {
        _amount -= 1.0;
        if (_amount < 0) _amount = 0.0;
        _quantityController.text = _amount == _amount.roundToDouble()
            ? _amount.toInt().toString()
            : _amount.toStringAsFixed(1);
        _syncQuantityToMedication();
        if (_amount == 0) {
          _submitBtnEnabled = isValid();
        }
      });
    }
  }

  void _showDosageBottomSheet(DosageModel? dosage) {
    // Sync current quantity into dosage so the bottom sheet shows and returns
    // the user's latest value (avoids overwriting _quantityController when
    // user changed quantity then opened sheet and picked weekDays/everyOtherDay).
    final currentAmount = _amount;
    final dosageToShow = dosage != null
        ? DosageModel(
            momentName: dosage.momentName,
            frequencyName: dosage.frequencyName,
            moment: dosage.moment,
            frequency: dosage.frequency,
            quantityInMorning: dosage.quantityInMorning,
            quantityInNoon: dosage.quantityInNoon,
            quantityInAfternoon: dosage.quantityInAfternoon,
            quantityInNight: dosage.quantityInNight,
            selectedDaysInWeek: dosage.selectedDaysInWeek,
            quantityForDaysInWeek: currentAmount,
            everyOtherDayNumber: dosage.everyOtherDayNumber,
            quantityForEveryOtherDay: currentAmount,
          )
        : null;

    final maxTotalQuantity = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? _amount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DosageInputBottomSheet(
        dosage: dosageToShow,
        maxTotalQuantity: maxTotalQuantity,
      ),
    ).then((newDosage) {
      if (newDosage != null && newDosage is DosageModel) {
        setState(() {
          _dosage = newDosage;

          // frequency: 1 = everyday, 2 = weekdays, 3 = every other day
          double q;
          if (newDosage.frequency == 2) {
            q = newDosage.quantityForDaysInWeek;
          } else if (newDosage.frequency == 3) {
            q = newDosage.quantityForEveryOtherDay;
          } else {
            // For "everyday", keep current amount unless explicitly provided elsewhere
            q = _amount;
          }

          if (q > 0) {
            _amount = q;
            _quantityController.text = _amount == _amount.roundToDouble()
                ? _amount.toInt().toString()
                : _amount.toStringAsFixed(1);
          }

          _submitBtnEnabled = isValid();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFEAF9F7),
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
              R.string.add_medicine.tr(),
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
                  colors: [R.color.greenGradientMid, R.color.greenGradientBottom])),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          width: double.infinity,
          color: Color(0xFFEAF9F7),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrescriptionCard(),
                _buildDescriptionCard(),
              ],
            ),
          ),
        ),
      ),
      // Submit button
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ElevatedButton(
            onPressed: () async {
              if (_submitBtnEnabled) {
                final bool hasRemain = !_isFromReuse &&
                    (_selectedMedication.remain != null || widget.medicine?.remain != null);

                // If this medicine already has a `remain` value (coming from a created
                // prescription) and we are in edit mode, confirm with the user that
                // changing quantity will reset usage status.
                if (hasRemain && _medicineMode == MedicineMode.edit) {
                  final bool proceed = await _showChangeQuantityConfirmDialog(context);
                  if (!proceed) {
                    // Cancel: just close dialog and do nothing else.
                    return;
                  }
                }

                _handleSubmit(context, hasRemain);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _submitBtnEnabled ? const Color(0xFF008D67) : const Color(0xFFBFC6C6),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: Text(
              R.string.confirm.tr(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.46,
                letterSpacing: 0.4,
                color: _submitBtnEnabled ? Colors.white : Color(0xFF5E6566),
              ),
            ),
          ),
        ),
      ), // end bottomNavigationBar
    );
  }

  void _handleSubmit(BuildContext context, bool hasRemain) {
    _selectedMedication = _selectedMedication.copyWith(
      amount: hasRemain ? null : _amount,
      remain: hasRemain ? _amount : null,
      note: _noteController.text,
      moment: _dosage?.moment,
      frequency: _dosage?.frequency,
      morning: _dosage?.quantityInMorning,
      midDay: _dosage?.quantityInNoon,
      afternoon: _dosage?.quantityInAfternoon,
      night: _dosage?.quantityInNight,
      customDay: _dosage?.selectedDaysInWeek.join(','),
      breakDay: _dosage?.everyOtherDayNumber.toDouble(),
      unit: _unit.getName(),
    );

    List<ImageNoteModel> oldPaths = <ImageNoteModel>[];
    Map<String, String> newPaths = {};
    if (_medicineMode == MedicineMode.create) {
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        if (file is PickedFile) {
          final fieldName = 'ImagesPatientMedication[${widget.index} ?? 0]';
          newPaths[fieldName] = file.path;
        }
      }
      _selectedMedication.uploadFiles = newPaths;

      Navigator.pushNamed(
        context,
        NavigatorName.prescription_add,
        arguments: {'medicineItem': _selectedMedication},
      );
    } else {
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        if (file is PickedFile) {
          final fieldName = 'ImagesPatientMedication[${widget.index ?? 0}]';
          newPaths[fieldName] = file.path;
        } else if (file is ImagesModel) {
          final id = (file.url ?? '').split('/').last.trim();
          oldPaths.add(
            ImageNoteModel(order: widget.index ?? 0, id: id),
          );
        }
      }
      _selectedMedication.uploadFiles = newPaths;

      Navigator.pop(context, _selectedMedication);
    }
  }

  // Prescription Card
  Widget _buildPrescriptionCard() {
    return Card(
        margin: const EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(R.string.medicine_name.tr()),
                const SizedBox(height: 8.0),
                // Tên thuốc
                _buildNameTextField(),
                const SizedBox(height: 20.0),
                _buildSectionTitle(R.string.medicine_unit.tr()),
                const SizedBox(height: 12.0),
                _buildMedicineUnitSelector(),
                const SizedBox(height: 20.0),
                const Divider(
                  color: Color(0xFFF4F5F6),
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                ),
                const SizedBox(height: 20.0),
                _buildQuantitySelector(),
                const SizedBox(height: 20.0),
                const Divider(
                  color: Color(0xFFF4F5F6),
                  thickness: 1,
                  indent: 12,
                  endIndent: 12,
                ),
                const SizedBox(height: 20.0),
                _buildDosageSection(),
              ],
            )
        )
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          height: 1.32,
          letterSpacing: 0.2,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111515),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildNameTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _nameController,
        readOnly: true,
        decoration: InputDecoration(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(
              width: 1,
              color: const Color(0xFFDADEDF),
              style: BorderStyle.solid
            )
          ),
        ),
        onChanged: (value) {
          // _prescription.prescriptionName = value;
        },
      ),
    );
  }

  // Medicine Unit
  Widget _buildMedicineUnitSelector() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _medicineUnits.length,
        itemBuilder: (context, index) {
          final unit = _medicineUnits[index];
          final isSelected = _unit == unit;

          return Padding(
            padding: (index == 0)
                ? const EdgeInsets.only(left: 12.0, right: 1.5)
                : (index == _medicineUnits.length - 1)
                ? const EdgeInsets.only(left: 1.5, right: 12.0)
                : const EdgeInsets.symmetric(horizontal: 1.5),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _unit = unit;
                });
              },
              child: SizedBox(
                width: 64,
                height: 40,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF008D67) : Color(0xFFF4F7F7),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    unit.getName(),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.46,
                      letterSpacing: 0.4,
                      color: isSelected ? Colors.white : Color(0xFF5E6566),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Quantity
  Widget _buildQuantitySelector() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            // Số thuốc hiện có
            child: _buildSectionTitle(R.string.current_medicine_quantity.tr())
          ),
          GestureDetector(
            onTap: _decrementQuantity,
            child: Container(
              width: 34,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFF4F7F7),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(4), right: Radius.zero),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                width: 10,
                height: 2,
                R.icons.ic_minus,
              ),
            ),
          ),
          Container(
            width: 60,
            height: 36,
            alignment: Alignment.center,
            child: TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.0',
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _amount = double.tryParse(value) ?? 0.0;
                  _syncQuantityToMedication();
                  if (_amount == 0 && _submitBtnEnabled == true) {
                    _submitBtnEnabled = false;
                  } else if (_amount > 0 && _submitBtnEnabled == false) {
                    _submitBtnEnabled = true;
                  }
                });
              },
            )
          ),
          GestureDetector(
            onTap: _incrementQuantity,
            child: Container(
              width: 34,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFF4F7F7),
                borderRadius: BorderRadius.horizontal(left: Radius.zero, right: Radius.circular(4)),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                R.icons.ic_plus,
                width: 14,
                height: 14,
              ),
            ),
          ),
          SizedBox(width: 12.0),
        ],
      )
    );
  }

  // Dosage - Liều dùng
  Widget _buildDosageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildSectionTitle(R.string.dosage.tr())),
            GestureDetector(
              onTap: () => _showDosageBottomSheet(_dosage),
              child: Center(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Color(0xFF008479),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 4),
                      Text(
                        R.string.input.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.46,
                          letterSpacing: 0.4,
                          color: Color(0xFF008479),
                        ),
                      ),
                      SvgPicture.asset(
                        R.icons.ic_chevron_right,
                        width: 9,
                        height: 18,
                        color: Color(0xff008479),
                        semanticsLabel: 'chevron_right',
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
        if (_dosage != null)
          ..._buildDosageContentItems([_dosage!], _unit)
        else
          Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Row(
                children: [
                  SvgPicture.asset(
                    R.icons.ic_information,
                    width: 14,
                    height: 14,
                    semanticsLabel: 'caution',
                  ),
                  SizedBox(width: 3),
                  Text(
                    R.string.please_input_dosage.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      height: 1.50,
                      letterSpacing: 0.2,
                      color: Color(0xFFAF0000),
                    ),
                  ),
                ]
            ),
          ),
        SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildDosageContentItems(List<DosageModel> dosages, MedicineUnit medicineUnit) {
    List<Widget> widgets = [];

    for (final dosage in dosages) {
      // if (dosage.frequency == 0) {
        widgets.addAll(
          _buildEveryDayDosage(
            dosage.momentName,
            dosage.quantityInMorning,
            dosage.quantityInNoon,
            dosage.quantityInAfternoon,
            dosage.quantityInNight,
            dosage.frequencyName,
            medicineUnit.getName(),
          )
        );
      // } else if (dosage.frequency == 1) {
      //   widgets.addAll(
      //     _buildDayInWeekDosage(
      //       dosage.momentName,
      //       dosage.selectedDaysInWeek,
      //       dosage.quantityForDaysInWeek,
      //       medicineUnit.getName(),
      //     )
      //   );
      // } else {
      //   // Cách ngày
      //   widgets.addAll(
      //     _buildEveryDayOtherDosage(
      //       dosage.momentName,
      //       dosage.everyOtherDayNumber,
      //       dosage.quantityForEveryOtherDay,
      //       medicineUnit.getName(),
      //     )
      //   );
      // }
    }
    return widgets;
  }

  List<Widget> _buildEveryDayDosage(
    String timeOfUse,
    double quantityInMorning,
    double quantityInNoon,
    double quantityInAfternoon,
    double quantityInNight,
    String frequencyName,
    String medicineUnit,
  ) {
    List<Widget> dosageWidgets = [];
    if (quantityInMorning > 0) {
      dosageWidgets.add(
          _buildDosageRowItemForEveryDay(
            R.icons.ic_morning,
            R.string.the_morning.tr(),
            timeOfUse,
            quantityInMorning,
            frequencyName,
            medicineUnit,
          )
      );
    }
    if (quantityInNoon > 0) {
      dosageWidgets.add(
          _buildDosageRowItemForEveryDay(
            R.icons.ic_noon,
            R.string.the_noon.tr(),
            timeOfUse,
            quantityInNoon,
            frequencyName,
            medicineUnit,
          )
      );
    }
    if (quantityInAfternoon > 0) {
      dosageWidgets.add(
          _buildDosageRowItemForEveryDay(
            R.icons.ic_afternoon,
            R.string.the_afternoon.tr(),
            timeOfUse,
            quantityInAfternoon,
            frequencyName,
            medicineUnit,
          )
      );
    }
    if (quantityInNight > 0) {
      dosageWidgets.add(
          _buildDosageRowItemForEveryDay(
            R.icons.ic_night,
            R.string.the_night.tr(),
            timeOfUse,
            quantityInNight,
            frequencyName,
            medicineUnit,
          )
      );
    }
    return dosageWidgets;
  }

  /**
   * @param timeOfDay: "Buổi sáng", "Buổi trưa", "Buổi chiều", "Tối"
   * @param timeOfUse: "Trước ăn", "Sau ăn", "Trong khi ăn"
   */
  Widget _buildDosageRowItemForEveryDay(
      String iconRes,
      String timeOfDay,
      String timeOfUse,
      double quantity,
      String frequencyName,
      String medicineUnit,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconRes,
              height: 24,
              width: 24,
              semanticsLabel: timeOfDay,
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeOfDay,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    height: 1.46,
                    letterSpacing: 0.4,
                    color: Color(0xFF111515),
                  ),
                ),
                SizedBox(height: 4),
                _buildDosageContent(timeOfUse, timeOfDay, quantity, frequencyName, medicineUnit)
              ],
            ),
          ]
      ),
    );
  }

  Widget _buildDosageContent(String timeOfUse, String timeFrequency, double quantity, String frequencyName, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          quantity == quantity.truncateToDouble() ? "${quantity.toInt()} $unit" : "$quantity $unit",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.46,
            letterSpacing: 0.4,
            color: Color(0xFF5E6566),
          ),
        ),
        SizedBox(width: 4),
        // circle grey dot
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFBFC6C6),
          ),
        ),
        SizedBox(width: 4),
        Text(
          timeOfUse,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.46,
            letterSpacing: 0.4,
            color: Color(0xFF5E6566),
          ),
        ),
        SizedBox(width: 4),
        // circle grey dot
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFBFC6C6),
          ),
        ),
        SizedBox(width: 4),
        Text(
          frequencyName,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            height: 1.46,
            letterSpacing: 0.4,
            color: Color(0xFF5E6566),
          ),
        ),
      ],
    );
  }

  // Description Card - Ghi chú
  Widget _buildDescriptionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SectionAddNote(
        // focusNode: _focusNode,
        controllerNote: _noteController,
        maxMedia: 5,
        maxLength: 50,
        key: _sectionAddNoteKey,
        initialFiles: _files,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 12,
      ),
    );
  }

  Future<bool> _showChangeQuantityConfirmDialog(BuildContext context) async {
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
                        Image.asset(R.drawable.ic_back_icon, width: 64, height: 64),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'change_medicine_quantity_title'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'change_medicine_quantity_message'.tr(),
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context, false);
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(200),
                                    color: R.color.grayBorder,
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.cancel.tr(),
                                      style: TextStyle(
                                        color: R.color.textDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context, true);
                                },
                                child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                    color: R.color.red,
                                    borderRadius: BorderRadius.circular(200),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        R.color.greenGradientTop,
                                        R.color.greenGradientBottom,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      R.string.text_continue.tr(),
                                      style: TextStyle(
                                        color: R.color.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }

}
