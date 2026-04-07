import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/medicine/medicine_bloc.dart';
import '../../utils/navigator_name.dart';

class MedicineCheckPage extends StatefulWidget {
  const MedicineCheckPage({super.key});

  @override
  State<MedicineCheckPage> createState() => _MedicineCheckPageState();
}

class _MedicineCheckPageState extends State<MedicineCheckPage> {

  @override
  void initState() {
    super.initState();
    checkHasPrescriptions();
  }

  void checkHasPrescriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final hasPrescription = prefs.getBool('hasPrescription') ?? true;
    if (hasPrescription) {
      await Navigator.pushReplacementNamed(context, NavigatorName.prescription);
    } else {
      await Navigator.pushReplacementNamed(context, NavigatorName.medicine);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
