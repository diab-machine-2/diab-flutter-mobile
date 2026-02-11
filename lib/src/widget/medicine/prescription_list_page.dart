import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/src/modal/medicine/prescription_schedule_model.dart';
import 'package:medical/src/widget/medicine/widgets/calendar_slider.dart';
import 'package:medical/src/widget/medicine/widgets/empty_medicine_schedule.dart';
import 'package:medical/src/widget/medicine/widgets/note_and_images_panel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../res/R.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../modal/medicine/daily_medicine_model.dart';
import '../../modal/medicine/prescription_model.dart';
import '../../service/medicine_service.dart';
import '../../utils/const.dart';
import '../../utils/navigator_name.dart';
import '../helper/helper.dart';
import 'prescription_add_page.dart';
import 'widgets/input_options_bottom_sheet.dart';
import 'widgets/medicine_list.dart';
import 'widgets/medicine_session_card.dart';
import 'widgets/stop_prescription_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class PrescriptionListPage extends StatefulWidget {
  const PrescriptionListPage({super.key});

  @override
  State<PrescriptionListPage> createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> with SingleTickerProviderStateMixin {
  late MedicineBloc _bloc;
  List<PrescriptionsBySessionModel> _sessionList = <PrescriptionsBySessionModel>[];

  late TabController _tabController;
  int bottomIndex = 1;

  final GlobalKey _firstMedicineKey = GlobalKey();
  bool _shouldShowTutorial = false;

  /*------CALENDAR SLIDER------*/
  // Store the currently selected date.
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    // Initialize with today's date.
    final currentDateTime = DateTime.now();
    _selectedDate = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day, 7);
    _tabController = TabController(length: 2, vsync: this);
    _bloc = MedicineBloc()..add(FetchPrescriptionsEvent());
    // ..add(FetchMedicineScheduleEvent(
    //   (DateTime.now().millisecondsSinceEpoch / 1000).round(),
    // ));
    _loadTutorialFlag();
  }

  Future<void> _loadTutorialFlag() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(Const.shouldTutorial) ?? false;
    setState(() => _shouldShowTutorial = !shown);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<MedicineBloc, MedicineState>(
        listener: (context, state) {
          if (state is FetchPrescriptionsSuccess && state.prescriptionsResult.isEmpty) {
            Navigator.of(context).pushReplacementNamed(NavigatorName.medicine);
          }
          if (state is StopPrescriptionSuccess) {
            _bloc.add(FetchPrescriptionsEvent());
          }
        },
        child: BlocBuilder<MedicineBloc, MedicineState>(builder: (context, state) {
          // if (state is MedicineLoading) {
          //   return const Center(child: CircularProgressIndicator());
          // }
          if (state is FetchPrescriptionsSuccess && state.prescriptionsResult.isEmpty) {
            return const SizedBox.shrink();
          }

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
                    bottomIndex == 0 ? R.string.schedule_use_medicine.tr() : R.string.prescription.tr(),
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
              bottom: bottomIndex == 1
                  ? PreferredSize(
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
                    )
                  : null,
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
            body: bottomIndex == 0 ? _buildBodyForScheduleTab(context, state) : _buildBodyForPrescriptionTab(state),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () {
                InputOptionsBottomSheet.show(
                  context,
                  onCameraTap: () {
                    Navigator.of(context).pushNamed(NavigatorName.prescription_capture);
                  },
                  onHandTap: () {
                    Navigator.of(context).pushNamed(NavigatorName.medicine_search);
                  },
                );
              },
              child: Image.asset(
                width: 44,
                height: 44,
                R.drawable.ic_add_prescription,
              ),
            ),
            bottomNavigationBar: _buildBottomAppBar(),
          );
        }),
      ),
    );
  }

  BottomAppBar _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                _bloc.add(FetchMedicineScheduleEvent(
                  (DateTime.now().millisecondsSinceEpoch / 1000).round(),
                ));
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
                _bloc.add(FetchPrescriptionsEvent());
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
    );
  }

  /*----------------------------LỊCH UỐNG THUỐC PAGE----------------------------*/
  Widget _buildBodyForScheduleTab(BuildContext context, MedicineState state) {
    if (state is MedicineLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FetchMedicineScheduleSuccess) {
      _sessionList = PrescriptionsBySessionModel.fromDailyList(state.medicineScheduleResult.daily);

      // Sắp xếp lại thứ tự buổi: Sáng -> Trưa -> Chiều -> Tối
      _sessionList.sort((a, b) => a.session.index.compareTo(b.session.index));
    }

    // Xác định buổi cần được mở mặc định
    final int defaultExpandedIndex = _getDefaultExpandedSessionIndex();

    return ListView.builder(
      itemCount: max(_sessionList.length + 1, 2),
      itemBuilder: (_, index) {
        if (index == 0) {
          return CalendarSlider(
              initialDate: _selectedDate,
              onDateSelected: (newSelectedDate) {
                _selectedDate = newSelectedDate;
                _bloc.add(
                  FetchMedicineScheduleEvent(
                    (_selectedDate.millisecondsSinceEpoch / 1000).round(),
                  ),
                );
              });
        }

        if (_sessionList.isEmpty) {
          return EmptyMedicineSchedule();
        }

        final sessionIndex = index - 1;
        final session = _sessionList[sessionIndex];

        return MedicineSessionCard(
          session: session,
          isExpanded: sessionIndex == defaultExpandedIndex,
          onTap: (prescriptionIndex, medicationIndex, isTaken) {
            _bloc.add(UseMedicineEvent(session.prescriptions[prescriptionIndex].medications[medicationIndex].id));
          },
          firstMedicineKey: _shouldShowTutorial ? _firstMedicineKey : null,
        );
      },
    );
  }

  /// Builds [DateTime] for the given date and timeSchedule string ("HH:mm:ss").
  DateTime _dateTimeFromSelectedDateAndSchedule(DateTime date, String timeSchedule) {
    final parts = (timeSchedule).split(':');
    final h = parts.isNotEmpty ? (int.tryParse(parts[0]) ?? 0) : 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final s = parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0;
    return DateTime(date.year, date.month, date.day, h, m, s);
  }

  /// Tìm buổi cần được mở mặc định:
  /// - Ưu tiên buổi có thời gian gần nhất với hiện tại (có thể là quá khứ hoặc tương lai),
  ///   dùng [_selectedDate] + timeSchedule và so sánh theo |now - time|.
  /// - Nếu không có, chọn buổi có thuốc "Chưa dùng" gần nhất theo thời gian.
  int _getDefaultExpandedSessionIndex() {
    if (_sessionList.isEmpty) return -1;

    final now = DateTime.now();
    final selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    int? closestSessionIndex;
    Duration? closestDiff;

    // 1. Tìm buổi có thời gian gần nhất với hiện tại (theo trị tuyệt đối của chênh lệch thời gian)
    for (int i = 0; i < _sessionList.length; i++) {
      final session = _sessionList[i];
      for (final pres in session.prescriptions) {
        final presDateTime = _dateTimeFromSelectedDateAndSchedule(selectedDate, pres.timeSchedule);
        final diffAbs = presDateTime.difference(now).abs();
        if (closestDiff == null || diffAbs < closestDiff) {
          closestDiff = diffAbs;
          closestSessionIndex = i;
        }
      }
    }

    if (closestSessionIndex != null) {
      return closestSessionIndex;
    }

    // 2. Nếu không còn lịch hẹn trong tương lai,
    //    chọn buổi có thuốc "Chưa dùng" gần nhất theo thời gian (nhỏ nhất).
    int? closestUntakenSessionIndex;
    DateTime? closestUntakenTime;

    for (int i = 0; i < _sessionList.length; i++) {
      final session = _sessionList[i];
      for (final pres in session.prescriptions) {
        final hasUntaken = pres.medications.any((m) => !m.isTaken);
        if (!hasUntaken) continue;

        final presDateTime = _dateTimeFromSelectedDateAndSchedule(selectedDate, pres.timeSchedule);
        if (closestUntakenTime == null || presDateTime.isBefore(closestUntakenTime)) {
          closestUntakenTime = presDateTime;
          closestUntakenSessionIndex = i;
        }
      }
    }

    return closestUntakenSessionIndex ?? -1;
  }

  /*----------------------------ĐƠN THUỐC PAGE----------------------------*/
  Widget _buildBodyForPrescriptionTab(MedicineState state) {
    if (state is MedicineLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FetchPrescriptionsSuccess) {
      final prescriptionsIsUsing = state.prescriptionsResult.where((prescription) => prescription.status == 0).toList();
      final prescriptionsIsStop = state.prescriptionsResult.where((prescription) => prescription.status == 1).toList();
      return TabBarView(
        controller: _tabController,
        children: [
          _buildPrescriptions(prescriptionsIsUsing, true),
          _buildPrescriptions(prescriptionsIsStop, false),
        ],
      );
    }

    return Container();
  }

  Widget _buildPrescriptions(List<PrescriptionModel> prescriptions, bool isUsing) {
    if (prescriptions.isEmpty) {
      return Container();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return _buildPrescription(context, prescription, isUsing);
      },
    );
  }

  Widget _buildPrescription(BuildContext context, PrescriptionModel prescription, bool isUsing) {
    return Column(
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
            children: [
              Expanded(
                child: Text(
                  prescription.prescriptionName ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF95682E),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                convertDateTimeToUTC((prescription.startDate ?? DateTime.now()), 'dd/MM/yyyy'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF95682E),
                ),
              ),
            ],
          ),
        ),

        //Danh sách thuốc
        if ((prescription.patientMedications?.length ?? 0) > 0)
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
                  children: [
                    MedicineList(medications: prescription.patientMedications!),
                    const SizedBox(height: 4),
                    Divider(color: Color(0xFFDADEDF)),
                    const SizedBox(height: 8),
                    NoteAndImagesPanel(note: prescription.note, images: prescription.imagesPrescription),
                    const SizedBox(height: 8),
                    isUsing
                        ? Row(
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
                                          _bloc.add(StopPrescriptionEvent(prescription.id ?? ''));
                                          // _bloc.add(FetchPrescriptionsEvent());
                                        },
                                      ),
                                    );
                                  },
                                  child: Text(
                                    R.string.stop_medicine.tr(),
                                    style:
                                        TextStyle(color: Color(0xFF830000), fontWeight: FontWeight.bold, fontSize: 15),
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
                                  onPressed: () async {
                                    await Navigator.pushNamed(context, NavigatorName.prescription_add, arguments: {
                                      'mode': PrescriptionMode.edit,
                                      'prescription': prescription,
                                    });
                                    MedicineScheduleService().refreshTodaySchedules();
                                    // MedicineScheduleService().showTestNotification();
                                  },
                                  child: Text(
                                    R.string.chinh_sua.tr(),
                                    style:
                                        TextStyle(color: Color(0xFF008479), fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
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
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      NavigatorName.prescription_add,
                                      arguments: {
                                        'mode': PrescriptionMode.reuse,
                                        'prescription': prescription,
                                      },
                                    );

                                    if (result == true) {
                                      // Gọi lại fetch khi MedicineAddPage trả về success
                                      _bloc.add(FetchPrescriptionsEvent());
                                    }
                                  },
                                  child: Text(
                                    R.string.reuse_prescription.tr(),
                                    style:
                                        TextStyle(color: Color(0xFF008479), fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                )),
          ),
      ],
    );
  }
}
