import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

enum ExamResultCategory {
  laboratoryTest(1),
  diagnosticImaging(2),
  functionalExploration(3),
  endoscopyAndBiopsy(4);

  const ExamResultCategory(this.value);
  final int value;

  String get svgIcon {
    switch (this) {
      case ExamResultCategory.laboratoryTest:
        return R.icons.ic_xet_nghiem;
      case ExamResultCategory.diagnosticImaging:
        return R.icons.ic_chan_doan_hinh_anh;
      case ExamResultCategory.functionalExploration:
        return R.icons.ic_tham_do_chuc_nang;
      case ExamResultCategory.endoscopyAndBiopsy:
        return R.icons.ic_noi_soi;
    }
  }

  String get title {
    switch (this) {
      case ExamResultCategory.laboratoryTest:
        return R.string.bcb_exam_category_laboratory_test.tr();
      case ExamResultCategory.diagnosticImaging:
        return R.string.bcb_exam_category_diagnostic_imaging.tr();
      case ExamResultCategory.functionalExploration:
        return R.string.bcb_exam_category_functional_exploration.tr();
      case ExamResultCategory.endoscopyAndBiopsy:
        return R.string.bcb_exam_category_endoscopy_biopsy.tr();
    }
  }

  static ExamResultCategory? fromType(int? type) {
    if (type == null) return null;
    for (final category in ExamResultCategory.values) {
      if (category.value == type) return category;
    }
    return null;
  }
}

class CampaignTestResultScreen extends StatefulWidget {
  const CampaignTestResultScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  State<CampaignTestResultScreen> createState() =>
      _CampaignTestResultScreenState();
}

class _CampaignTestResultScreenState extends State<CampaignTestResultScreen> {
  final BcbCampaignClient _client = BcbCampaignClient();
  bool _loading = true;
  final Set<int> _expandedTypes = <int>{};
  final List<BcbExamResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    if (widget.campaignId.trim().isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await _client.fetchExamResult(widget.campaignId);
      if (!mounted) return;
      setState(() {
        _results
          ..clear()
          ..addAll(data);
        _expandedTypes
          ..clear()
          ..addAll(_results.map((e) => e.type).whereType<int>());
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      BotToast.showText(text: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <int, List<BcbExamResultModel>>{};
    for (final item in _results) {
      final type = item.type ?? -1;
      grouped.putIfAbsent(type, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      appBar: AppBar(
        title: Text(R.string.bcb_exam_results_title.tr()),
        centerTitle: false,
        leadingWidth: 30,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              children: [
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context)
                        .textScaler
                        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          R.string.bcb_exam_results_list.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: R.color.color0xff27272A,
                          ),
                        ),
                      ),
                      Text(
                        '${_results.length} ${R.string.bcb_tai_lieu.tr()}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: R.color.color0xff6A7282,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ...ExamResultCategory.values.map((category) {
                  final items = grouped[category.value] ?? [];
                  final isExpanded = _expandedTypes.contains(category.value);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: R.color.backgroundColorNew,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedTypes.remove(category.value);
                              } else {
                                _expandedTypes.add(category.value);
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  category.svgIcon,
                                  width: 24,
                                  height: 24,
                                  color: R.color.greenGradientBottom,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      textScaler: MediaQuery.of(context)
                                          .textScaler
                                          .clamp(
                                              minScaleFactor: 1.0,
                                              maxScaleFactor: 1.3),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: category.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' (${items.length})',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: R.color.color0xff6A7282,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded)
                          ...items.map(
                            (item) => _ExamResultItem(
                              result: item,
                              onView: () {
                                Navigator.pushNamed(
                                  context,
                                  NavigatorName.campaign_test_result_detail,
                                  arguments: {'result': item},
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class _ExamResultItem extends StatelessWidget {
  const _ExamResultItem({required this.result, required this.onView});

  final BcbExamResultModel result;
  final VoidCallback onView;

  Future<void> _downloadFile() async {
    final fileUrl = result.fileUrl;
    if (fileUrl == null || fileUrl.trim().isEmpty) {
      BotToast.showText(text: R.string.bcb_result_file_not_found.tr());
      return;
    }
    final uri = Uri.tryParse(fileUrl);
    if (uri == null) {
      BotToast.showText(text: R.string.bcb_invalid_file_url.tr());
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      BotToast.showText(text: R.string.bcb_cannot_download_file.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadedAt = result.uploadedAt;
    final dateStr = uploadedAt == null
        ? R.string.not_updated_yet.tr()
        : DateFormat.yMd(context.locale.toString()).format(uploadedAt);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.10),
            offset: const Offset(0, 1),
            blurRadius: 2,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.10),
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: R.color.color0xffFEF2F2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              R.icons.ic_file_pdf,
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: MediaQuery.of(context)
                        .textScaler
                        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                  ),
                  child: Text(
                    result.additionalServices?.trim().isNotEmpty == true
                        ? result.additionalServices!
                        : R.string.bcb_exam_result_default_title.tr(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: R.color.color0xff6A7282),
                    const SizedBox(width: 4),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: MediaQuery.of(context)
                            .textScaler
                            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                      ),
                      child: Text(
                        dateStr,
                        style: TextStyle(
                            color: R.color.color0xff6A7282,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: onView,
                          icon: const Icon(Icons.remove_red_eye_outlined,
                              size: 18),
                          label: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: MediaQuery.of(context)
                                  .textScaler
                                  .clamp(
                                      minScaleFactor: 1.0, maxScaleFactor: 1.3),
                            ),
                            child: Text(
                              R.string.bcb_view_result.tr(),
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: R.color.greenGradientBottom,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: R.color.color0xffF3F4F6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton.filled(
                        onPressed: _downloadFile,
                        icon: const Icon(Icons.download_outlined, size: 26),
                        style: IconButton.styleFrom(
                          backgroundColor: R.color.color0xffF3F4F6,
                          foregroundColor: R.color.color0xff27272A,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: R.color.color0xffF3F4F6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton.filled(
                        onPressed: () {
                          BotToast.showText(
                            text:
                                R.string.bcb_share_feature_in_development.tr(),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: R.color.color0xffF3F4F6,
                          foregroundColor: R.color.color0xff27272A,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
