import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../res/R.dart';
import '../../utils/navigator_name.dart';
import 'widgets/stop_prescription_dialog.dart';

class PrescriptionListPage extends StatefulWidget {
  const PrescriptionListPage({super.key});

  @override
  State<PrescriptionListPage> createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int bottomIndex = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              R.string.prescription.tr(),
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
        bottom: PreferredSize(
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
        ),
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
              Column(
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
              Column(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
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
