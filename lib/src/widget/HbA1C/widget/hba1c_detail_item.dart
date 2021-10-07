import 'package:flutter/material.dart';

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
