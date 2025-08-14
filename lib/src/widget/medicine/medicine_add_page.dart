import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../res/R.dart';
import '../../modal/medicine/medicine_item_model.dart';
import '../../utils/navigator_name.dart';
import 'dosage_input_bottom_sheet.dart';
import 'medicine_add_model.dart';

class MedicineAddPage extends StatefulWidget {
  const MedicineAddPage({super.key, this.medicineItem});
  final MedicineItemModel? medicineItem;

  @override
  State<MedicineAddPage> createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  late DraftPrescription _draftPrescription;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  void _checkSubmitBtnEnabled() {
    setState(() {
      _submitBtnEnabled = _draftPrescription.name.isNotEmpty &&
          _draftPrescription.quantity > 0 &&
          _draftPrescription.dosages.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _draftPrescription = DraftPrescription();

    _quantityController.text = _draftPrescription.quantity.toStringAsFixed(0);
    _descriptionController.text = _draftPrescription.description;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('medicineItem')) {
      final medicineItem = args['medicineItem'] as MedicineItemModel?;
      if (medicineItem != null) {
        _nameController.text = medicineItem.name;
        _draftPrescription.name = medicineItem.name;
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _draftPrescription.quantity++;
      _quantityController.text = _draftPrescription.quantity.toStringAsFixed(0);
    });
    _checkSubmitBtnEnabled();
  }

  void _decrementQuantity() {
    if (_draftPrescription.quantity > 0) {
      setState(() {
        _draftPrescription.quantity--;
        _quantityController.text =
            _draftPrescription.quantity.toStringAsFixed(0);
      });
      _checkSubmitBtnEnabled();
    }
  }

  void _showDosageBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DosageInputBottomSheet(),
    ).then((newDosage) {
      if (newDosage != null && newDosage is Dosage) {
        setState(() {
          final List<Dosage> newList = List.from(_draftPrescription.dosages);
          newList.add(newDosage);
          _draftPrescription.dosages = newList;
        });
        _checkSubmitBtnEnabled();
      }
    });
  }

  Future<void> _checkPermissionAndPickImage() async {
    final permissionStatus = await Permission.photos.request();
    final cameraStatus = await Permission.camera.request();

    if (permissionStatus.isGranted && cameraStatus.isGranted) {
      _pickImage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions are required to access photos and camera.')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final List<String> newPhotos = List.from(_draftPrescription.photos);
        newPhotos.add(image.path);
        setState(() {
          _draftPrescription.photos = newPhotos;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  /// Removes an image from the list at a given index.
  void _removeImage(int index) {
    setState(() {
      _draftPrescription.photos.removeAt(index);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: R.color.white,
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
      body: Container(
          width: double.infinity,
          color: Color(0xFFEAF9F7),
          child: Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrescriptionCard(),
                  _buildDescriptionCard(),
                ],
              ),
            ),
          )
      ),
      // Submit button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: () {
            if (_submitBtnEnabled) {
              Navigator.pushNamed(context, NavigatorName.prescription_add);
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
      ), // end bottomNavigationBar
    );
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
          _draftPrescription.name = value;
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
          final isSelected = _draftPrescription.medicineUnit == unit;

          return Padding(
            padding: (index == 0)
                ? const EdgeInsets.only(left: 12.0, right: 1.5)
                : (index == _medicineUnits.length - 1)
                ? const EdgeInsets.only(left: 1.5, right: 12.0)
                : const EdgeInsets.symmetric(horizontal: 1.5),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _draftPrescription.medicineUnit = unit;
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
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0.0',
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _draftPrescription.quantity = double.tryParse(value) ?? 0.0;
                });
                _checkSubmitBtnEnabled();
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
              onTap: _showDosageBottomSheet,
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
        if (_draftPrescription.dosages.isNotEmpty)
          ..._buildDosageContentItems(_draftPrescription.dosages, _draftPrescription.medicineUnit)
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

  List<Widget> _buildDosageContentItems(List<Dosage> dosages, MedicineUnit medicineUnit) {
    List<Widget> widgets = [];

    for (final dosage in dosages) {
      if (dosage.frequency == R.string.everyday.tr()) {
        widgets.addAll(
          _buildEveryDayDosage(
            dosage.timeOfUse,
            dosage.quantityInMorning,
            dosage.quantityInNoon,
            dosage.quantityInAfternoon,
            dosage.quantityInNight,
            medicineUnit.getName(),
          )
        );
      } else if (dosage.frequency == R.string.ngay_trong_tuan.tr()) {
        widgets.addAll(
          _buildDayInWeekDosage(
            dosage.timeOfUse,
            dosage.selectedDaysInWeek,
            dosage.quantityForDaysInWeek,
            medicineUnit.getName(),
          )
        );
      } else {
        // Cách ngày
        widgets.addAll(
          _buildEveryDayOtherDosage(
            dosage.timeOfUse,
            dosage.everyOtherDayNumber,
            dosage.quantityForEveryOtherDay,
            medicineUnit.getName(),
          )
        );
      }
    }
    return widgets;
  }

  List<Widget> _buildEveryDayDosage(
    String timeOfUse,
    double quantityInMorning,
    double quantityInNoon,
    double quantityInAfternoon,
    double quantityInNight,
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
            medicineUnit,
          )
      );
    }
    if (quantityInNight > 0) {
      dosageWidgets.add(
          _buildDosageRowItemForEveryDay(
            R.icons.ic_night,
            R.string.the_evening.tr(),
            timeOfUse,
            quantityInNight,
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
                _buildDosageContent(timeOfUse, timeOfDay, quantity, medicineUnit)
              ],
            ),
          ]
      ),
    );
  }

  List<Widget> _buildDayInWeekDosage(String timeOfUse, List<int> daysInWeek, double quantity, String unit) {
    List<Widget> widgets = [];
    for (int day in daysInWeek) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Text(
            _weekDays[day],
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              height: 1.46,
              letterSpacing: 0.4,
              color: Color(0xFF111515),
            ),
          )
        )
      );
      widgets.add(
        SizedBox(height: 4)
      );
      widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            child: _buildDosageContent(timeOfUse, R.string.ngay_trong_tuan.tr(), quantity, unit)
          )
      );
    }
    return widgets;
  }

  Widget _buildDosageContent(String timeOfUse, String timeFrequency, double quantity, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
          timeFrequency,
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
          quantity == quantity.truncateToDouble() ? "${quantity.toInt()} $unit" : "$quantity $unit",
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

  List<Widget> _buildEveryDayOtherDosage(String timeOfUse, int everyOtherDayNumber, double quantity, String medicineUnit) {
    List<Widget> widgets = [];
    widgets.add(
        Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Text(
              'Cách $everyOtherDayNumber ngày',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
                height: 1.46,
                letterSpacing: 0.4,
                color: Color(0xFF111515),
              ),
            )
        )
    );
    widgets.add(SizedBox(height: 4));
    widgets.add(
        Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: _buildDosageContent(timeOfUse, R.string.every_other_day.tr(), quantity, medicineUnit),
        )
    );
    return widgets;
  }

  // Description Card - Ghi chú
  Widget _buildDescriptionCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title "Ghi chú"
            Text(
              R.string.ghi_chu.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                height: 1.32,
                letterSpacing: 0.2,
                color: Color(0xFF111515),
              ),
            ),
            const SizedBox(height: 12),
            // Text input and Image icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      hintText: 'Nhập ghi chú',
                      filled: false,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    maxLines: null,
                    minLines: 1,
                    maxLength: 50,
                    buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      height: 1.46,
                      letterSpacing: 0.4,
                      color: Color(0xFF777E90),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _draftPrescription.description = value;
                      });
                    },
                  ),
                ),
                // Select Image Image Button
                GestureDetector(
                  onTap: () {
                    if (_draftPrescription.photos.isEmpty) {
                      _checkPermissionAndPickImage();
                    }
                  },
                  child: SvgPicture.asset(
                    R.icons.ic_camera,
                    height: 24,
                    width: 24,
                    color: _draftPrescription.photos.isEmpty ? Color(0xFF008479) : Color(0xFFBFC6C6),
                    semanticsLabel: 'Take Photo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Horizontal line
            const Divider(
              color: Color(0xFFF4F5F6),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 8),
            // current characters/max characters
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_draftPrescription.description.length}/50',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  letterSpacing: 0.2,
                  color: Color(0xFFBFC6C6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Attach images
            GridView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                // childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _draftPrescription.photos.length,
              itemBuilder: (context, index) {
                final imagePath = _draftPrescription.photos[index];
                return SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 4, 0),
                          child: Image.file(
                            File(imagePath),
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                          )
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              // border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            padding: const EdgeInsets.all(7.29),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 9.41,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
