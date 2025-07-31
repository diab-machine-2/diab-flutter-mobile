import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../res/R.dart';
import '../../modal/medicine/medicine_item_model.dart';
import '../../utils/navigator_name.dart';

class MedicineAddPage extends StatefulWidget {
  const MedicineAddPage({super.key, this.medicineItem});
  final MedicineItemModel? medicineItem;

  @override
  State<MedicineAddPage> createState() => _MedicineAddPageState();
}

class _MedicineAddPageState extends State<MedicineAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _buildMedicineInfo(),
        ),
      ],
    );
  }

  Widget _buildMedicineInfo() {
    return SingleChildScrollView(
      child: Column(
        children: [

        ],
      ),
    );
  }
}
