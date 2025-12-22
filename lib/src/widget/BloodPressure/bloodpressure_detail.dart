import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';

class BloodPressureDetail extends StatefulWidget {
  const BloodPressureDetail({super.key});

  @override
  State<BloodPressureDetail> createState() => _BloodPressureDetailState();
}

class _BloodPressureDetailState extends State<BloodPressureDetail> with Observer {
  int _periodFilterType = 1;
  String? _bloodPressureID;

  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
  }

  @override
  void dispose() {
    Observable.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void update(
      Observable observable, String? notifyName, Map<dynamic, dynamic>? map) {
    if (notifyName == 'BloodPressure_change_data') {
      // TODO: reload
      // overViewKey.currentState?.reloadData(periodFilterType);
      // detailKey.currentState?.reloadData(periodFilterType);
    }
  }

  void _doInputBloodPressure() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      appBar: AppBar(
        backgroundColor: R.color.glucose_bg_color,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
        ),
        title: Text(
          R.string.huyet_ap.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: R.color.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
              },
              child: Text(
                R.string.huong_dan.tr(),
                style: TextStyle(fontSize: 15, color: R.color.textDark),
              ),
            ),
          ),
        ],
      ),
      body: _buildLayout(),
    );
  }

  Widget _buildLayout() {
    return Container(
      child: Stack(
        children: [
          // Content
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildDateRangeFilter(),
                  const SizedBox(height: 12),
                  _buildDetailAndTrendingChart(),
                  const SizedBox(height: 12),
                  _buildTrendingAISuggestion(),
                  const SizedBox(height: 12),
                  _buildFrequencyChart(),
                  const SizedBox(height: 12),
                  _buildSuggestLessons(),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          // Sticky bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: 8 + MediaQuery.of(context).padding.bottom / 2,
                left: 16,
                right: 16,
                top: 12,
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: _doInputBloodPressure,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: R.color.accentColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        R.string.enter_blood_pressure.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return Container(
      child: Row(
        children: [],
      ),
    );
  }

  Widget _buildDetailAndTrendingChart() {
    return Container();
  }

  Widget _buildTrendingAISuggestion() {
    return Container();
  }

  Widget _buildFrequencyChart() {
    return Container();
  }

  Widget _buildSuggestLessons() {
    return Container();
  }
}
