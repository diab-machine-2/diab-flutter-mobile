import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/report_model.dart';
import '../../../../helper/helper.dart';
import '../models/report_data.dart';

class ReportListWidget extends StatelessWidget {
  const ReportListWidget({
    required this.title,
    this.reportList = const [],
    required this.onSelected,
  });

  final String title;
  final List<ReportModel> reportList;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        54;

    final double countHight = reportList.isEmpty ? 240 : reportList.length * 48.0 + 216;

    return SafeArea(
      child: Container(
        height: countHight > height ? height : countHight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                height: 3.86,
                width: 60,
                decoration: BoxDecoration(color: R.color.color0xffE5E5E5),
              ),
            ),
            const SizedBox(height: 27),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 24,
                      width: 24,
                      child: Image.asset(R.drawable.ic_close),
                    ),
                  ),
                ],
              ),
            ),
            if(reportList.isNotEmpty)
              const SizedBox(height: 8),
            Expanded(
              child: reportList.isEmpty ? Center(child: Container(padding: EdgeInsets.symmetric(horizontal: 20), child: Text(R.string.no_report.tr(), style: TextStyle(color: R.color.textDark, fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),),) : 
                SingleChildScrollView(
                  child: ListView.builder(
                  physics: countHight > height
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, bottom: 8, top: 10),
                  itemCount: reportList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildItem(
                        data: reportList[index],
                        isLast: index == reportList.length - 1,
                        onSelected: onSelected);
                  },
              ),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem({
    required ReportModel data,
    bool isLast = false,
    required Function(String) onSelected,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            color: R.color.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data.reportName ?? '',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: Text(
                            convertToUTC(data.createDatetime ?? 0, 'dd/MM/yyyy'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(width: 28),
                        InkWell(
                          onTap: () {
                            onSelected(data.virtualFilePath ?? '');
                          },
                          child: Image.asset(R.drawable.ic_show,
                              width: 24, height: 24),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 1, width: 373, color: R.color.color0xffD6D8E0)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
