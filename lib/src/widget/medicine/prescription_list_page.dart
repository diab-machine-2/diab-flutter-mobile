import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/src/modal/medicine/medicine_schedule_model.dart';
import 'package:medical/src/widget/medicine/widgets/calendar_slider.dart';
import 'package:medical/src/widget/medicine/widgets/empty_medicine_schedule.dart';

import '../../../res/R.dart';
import '../../utils/navigator_name.dart';
import 'widgets/stop_prescription_dialog.dart';

class PrescriptionListPage extends StatefulWidget {
  const PrescriptionListPage({super.key});

  @override
  State<PrescriptionListPage> createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> with SingleTickerProviderStateMixin {
  // Fake data
  Map<DateTime, List<PrescriptionBySessionModel>> _medicineScheduleMap = {};

  // List<PrescriptionBySessionModel> sessionList = [];
  List<bool> _sessionExpandedList = [];
  late TabController _tabController;
  int bottomIndex = 1;

  /*------CALENDAR SLIDER------*/
  // Store the currently selected date.
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    // Initialize with today's date.
    final currentDateTime = DateTime.now();
    _selectedDate = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);

    // TODO: fake data
    _medicineScheduleMap = {
      _selectedDate : [
        PrescriptionBySessionModel(
          id: "T0001",
          name: "Bệnh đái tháo đường không phụ thuộc insuline",
          session: MedicineSession.MORNING,
          time: DateTime(2025, 08, 21, 7, 30),
          medications: [
            MedicationInSession(
              medicineName: "Metformin (Metformin Stella 1000mg) 1000 mg",
              dosage: "1 viên - Sau ăn",
              isTaken: true,
            ),
            MedicationInSession(
              medicineName: "Fluvastatin (Autifan 40) 40mg",
              dosage: "1 viên - Sau ăn",
              isTaken: false,
            ),
          ],
          note: "Uống lúc 20h",
        ),
        PrescriptionBySessionModel(
          id: "T0001",
          name: "Bệnh đái tháo đường không phụ thuộc insuline",
          session: MedicineSession.EVENING,
          time: DateTime(2025, 08, 21, 19, 30),
          medications: [
            MedicationInSession(
              medicineName: "Metformin (Metformin Stella 1000mg) 1000 mg",
              dosage: "1 viên - Sau ăn",
              isTaken: true,
            ),
            MedicationInSession(
              medicineName: "Fluvastatin (Autifan 40) 40mg",
              dosage: "1 viên - Sau ăn",
              isTaken: false,
            ),
          ],
          note: "Uống lúc 20h",
        )
      ]
    };
    _tabController = TabController(length: 2, vsync: this);
    _sessionExpandedList = _medicineScheduleMap[_selectedDate]?.map((e) => false).toList() ?? [];
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
              bottomIndex == 0
                  ? R.string.schedule_use_medicine.tr()
                  : R.string.prescription.tr(),
              key: ValueKey(bottomIndex), // important for AnimatedSwitcher
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        actions: [
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              // Ripple Color
              splashColor: Colors.white.withOpacity(0.3),
              onTap: () async {
                // Time to show ripple
                await Future.delayed(const Duration(milliseconds: 250));
                Navigator.of(context).pushNamed(NavigatorName.medicine_tutorial);
              },
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
        bottom: bottomIndex == 1 ? PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              tabs: const [
                Tab(text: "Thuốc đang dùng"),
                Tab(text: "Thuốc đã hết"),
              ],
            ),
          ),
        ) : null,
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
      body: bottomIndex == 0 ? _buildBodyForScheduleTab() : _buildBodyForPrescriptionTab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        onPressed: () {},
        child: Image.asset(
          width: 44,
          height: 44,
          R.drawable.ic_add_prescription,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    bottomIndex = 0;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    SvgPicture.asset(
                      width: 24,
                      height: 24,
                      R.icons.ic_schedule_use_medicine,
                      color: bottomIndex == 0 ? Color(0xFF008479) : Color(0xFFBFC6C6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      R.string.schedule_use_medicine.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: bottomIndex == 0 ? Color(0xFF008479) : Color(0xFFBFC6C6),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    bottomIndex = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    SvgPicture.asset(
                      width: 24,
                      height: 24,
                      R.icons.ic_prescription,
                      color: bottomIndex == 1 ? Color(0xFF008479) : Color(0xFFBFC6C6),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      R.string.prescription.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: bottomIndex == 1 ? Color(0xFF008479) : Color(0xFFBFC6C6),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /*----------------------------LỊCH UỐNG THUỐC PAGE----------------------------*/
  Widget _buildBodyForScheduleTab() {
    final sessionList = _medicineScheduleMap[_selectedDate] ?? [];

    return ListView.builder(
      itemCount: max(sessionList.length + 1, 2),
      itemBuilder: (context, index) {
        if (index == 0) {
          return CalendarSlider(
            initialDate: _selectedDate,
            onDateSelected: (newSelectedDate) {
              setState(() {
                _selectedDate = newSelectedDate;
              });
            }
          );
        }

        if (sessionList.isEmpty) {
          return EmptyMedicineSchedule();
        }

        final sessionIndex = index - 1;
        final session = sessionList[sessionIndex];

        return _buildScheduleCard(
          session,
          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          sessionIndex,
          (medicationIndex, isTaken) {
            // toggle between "Chưa dùng" and "Đã dùng"
            final medication = sessionList[sessionIndex].medications[medicationIndex];

            // 2. Create a new, updated medication object
            final updatedMedication = MedicationInSession(
              medicineName: medication.medicineName,
              dosage: medication.dosage,
              isTaken: !medication.isTaken, // Toggle the value
            );

            // 3. Create a new list of medications for the session
            final updatedMedicationsList =
            List<MedicationInSession>.from(sessionList[sessionIndex].medications);
            updatedMedicationsList[medicationIndex] = updatedMedication;

            // 4. Create a new updated session object
            final updatedSession = PrescriptionBySessionModel(
              id: sessionList[sessionIndex].id,
              name: sessionList[sessionIndex].name,
              session: sessionList[sessionIndex].session,
              time: sessionList[sessionIndex].time,
              medications: updatedMedicationsList,
              note: sessionList[sessionIndex].note,
            );

            // 5. Create a new list of sessions by replacing the updated session
            final newSessionList = List<PrescriptionBySessionModel>.from(sessionList);
            newSessionList[sessionIndex] = updatedSession;

            setState(() {
              _medicineScheduleMap[_selectedDate] = newSessionList;
            });
          }
        );
      }
    );
  }

  Widget _buildScheduleCard(
      PrescriptionBySessionModel prescription,
      EdgeInsetsGeometry margin,
      int sessionIndex,
      Function(int, bool) onTap,
  ) {
    return Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: ExpansionTile(
        initiallyExpanded: _sessionExpandedList[sessionIndex],
        onExpansionChanged: (bool expanded) {
          setState(() {
            _sessionExpandedList[sessionIndex] = expanded;
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          prescription.session.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.32,
            letterSpacing: 0.2,
            color: Colors.white,
          ),
        ),
        trailing: AnimatedRotation(
          turns: _sessionExpandedList[sessionIndex] ? 0.5 : 0.0, // 0.5 turn = 180°
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(
            R.icons.ic_chevron_up,
            width: 12,
            height: 6,
          ),
        ),
        backgroundColor: const Color(0xFF0FB4A5),
        collapsedBackgroundColor: const Color(0xFF0FB4A5),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Disease Name
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 253/375,
                        height: 22,
                        child: Text(
                          prescription.name,
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
                        "${prescription.time.hour}:${prescription.time.minute}",
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
                ..._buildListOfMedicine(prescription.medications, onTap),
                // Note
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F7F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Ghi chú: ",
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFF5E6566),
                          ),
                        ),
                        TextSpan(
                          text: prescription.note,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.5,
                            letterSpacing: 0.4,
                            color: Color(0xFF5E6566),
                          ),
                        ),
                      ]
                    )
                  )
                ),
              ],
            ),
          )
        ]
      ),
    );
  }

  List<Widget> _buildListOfMedicine(
    List<MedicationInSession> medicationList,
    Function(int, bool) onTap,
  ) {
    List<Widget> widgets = [];
    for (var i = 0; i < medicationList.length; i++) {
      final medication = medicationList[i];
      widgets.add(
        Padding(
          padding: i == 0 ? EdgeInsets.fromLTRB(0, 12, 0, 16) : EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: _buildMedicineItem(
            medication.medicineName,
            medication.dosage,
            medication.isTaken,
            () {
              onTap(i, !medication.isTaken);
            }
          ),
        )
      );
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
        SizedBox(
          width: MediaQuery.of(context).size.width - 168,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.46,
                  color: Color(0xFF111515),
                )
              ),
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
        SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    isTaken ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                    color: isTaken ? Color(0xFF008479) : Color(0xFFBFC6C6),
                  ),
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
          ),
        )
      ],
    );
  }

  /*----------------------------ĐƠN THUỐC PAGE----------------------------*/
  Widget _buildBodyForPrescriptionTab() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUsingMedicine(),
        _buildStopMedicine(),
      ],
    );
  }

  Widget _buildUsingMedicine() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  "Bệnh đái tháo đường không...",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF95682E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "21/02/2025",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF95682E),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _medicineItem(
                  icon: Icons.medication,
                  name: "Gliclazid (Glycinorm-80)...",
                  quantity: "36 viên",
                ),
                _medicineItem(
                  icon: Icons.medication,
                  name: "Metformin (Metformin Ste...",
                  quantity: "36 viên",
                ),
                _medicineItem(
                  icon: Icons.medication,
                  name: "Fluvastatin (Autifan 40) 4...",
                  quantity: "30 viên",
                ),
                const SizedBox(height: 4),
                Divider(color: Color(0xFFDADEDF)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F7F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ghi chú: Tái khám sau 1 tháng sử dụng thuốc tại bệnh viện BBB",
                      ),
                      const SizedBox(height: 8),
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(8),
                      //   child: Image.network(
                      //     "https://via.placeholder.com/150",
                      //     height: 80,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Color(0xFFFFE9E9),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // bo tròn nhiều
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => StopPrescriptionDialog(
                              onConfirm: () {
                                Navigator.pop(context);
                                // Thực hiện logic ngưng thuốc
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Ngừng thuốc",
                          style: TextStyle(color: Color(0xFF830000), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // bo tròn nhiều
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            NavigatorName.prescription_add,
                            arguments: {
                              'mode': 1,
                              // 'prescription':
                            }
                          );
                        },
                        child: const Text(
                          "Chỉnh sửa",
                          style: TextStyle(color: Color(0xFF008479), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFDFFFE2),
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: Row(
        //     children: const [
        //       Icon(Icons.check_circle, color: Colors.green),
        //       SizedBox(width: 8),
        //       Expanded(child: Text("Tạo đơn thuốc thành công")),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildStopMedicine() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Expanded(
                child: Text(
                  "Bệnh đái tháo đường không...",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF95682E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "21/02/2025",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF95682E),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _medicineItem(
                  icon: Icons.medication,
                  name: "Gliclazid (Glycinorm-80)...",
                  quantity: "36 viên",
                ),
                _medicineItem(
                  icon: Icons.medication,
                  name: "Metformin (Metformin Ste...",
                  quantity: "36 viên",
                ),
                _medicineItem(
                  icon: Icons.medication,
                  name: "Fluvastatin (Autifan 40) 4...",
                  quantity: "30 viên",
                ),
                const SizedBox(height: 4),
                Divider(color: Color(0xFFDADEDF)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F7F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ghi chú: Tái khám sau 1 tháng sử dụng thuốc tại bệnh viện BBB",
                      ),
                      const SizedBox(height: 8),
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(8),
                      //   child: Image.network(
                      //     "https://via.placeholder.com/150",
                      //     height: 80,
                      //     fit: BoxFit.cover,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.teal,
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30), // bo tròn nhiều
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                              context,
                              NavigatorName.prescription_add,
                              arguments: {
                                'mode': 2,
                                // 'prescription':
                              }
                          );
                        },
                        child: const Text(
                          "Dùng lại đơn thuốc",
                          style: TextStyle(color: Color(0xFF008479), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFDFFFE2),
        //     borderRadius: BorderRadius.circular(8),
        //   ),
        //   child: Row(
        //     children: const [
        //       Icon(Icons.check_circle, color: Colors.green),
        //       SizedBox(width: 8),
        //       Expanded(child: Text("Tạo đơn thuốc thành công")),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _medicineItem({
    String? imageUrl,
    IconData? icon,
    required String name,
    required String quantity,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, width: 40, height: 40),
            )
          : Icon(icon ?? Icons.medication, color: Colors.teal, size: 32),
      title: Text(
        name,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(quantity),
    );
  }
}
