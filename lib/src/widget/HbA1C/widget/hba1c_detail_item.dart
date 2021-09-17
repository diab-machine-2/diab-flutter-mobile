import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/HbA1C/HbA1C_bloc.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/theme/app_theme.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';

class HbA1CDetailItem extends StatefulWidget {
  final bool hasNote;
  HbA1CDetailItem(this.hasNote);

  @override
  _HbA1CDetailItemState createState() => _HbA1CDetailItemState();
}

class _HbA1CDetailItemState extends State<HbA1CDetailItem> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    // try {
    //   final result = await HbA1CClient().fetchInput();
    //   // print(result);
    // } catch (e) {
    //   // if (e is ErrorModel) {
    //   //   print(e.message);
    //   // }
    //   // print(e);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
