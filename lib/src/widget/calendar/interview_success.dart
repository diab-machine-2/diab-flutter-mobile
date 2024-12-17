import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widgets/CalendarPicker/custom_date_picker.dart';

class InterviewSuccessController extends StatefulWidget {
  @override
  _InterviewSuccessControllerState createState() =>
      _InterviewSuccessControllerState();
}

class _InterviewSuccessControllerState
    extends State<InterviewSuccessController> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    // BotToast.showLoading();
    // BotToast.closeAllLoading();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: R.color.backgroundColorNew,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomAppBar(
                backgroundColor: R.color.transparent,
                title: Text("Phỏng vấn đầu vào",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: R.color.textDark)),
                leadingIcon: IconButton(
                    splashColor: R.color.transparent,
                    highlightColor: R.color.transparent,
                    icon: Icon(Icons.arrow_back, color: R.color.textDark),
                    onPressed: () {
                      // Navigator.pushNamed(context, NavigatorName.profile);
                      Navigator.of(context).pop();
                    }),
              ),
              SizedBox(
                width: screenWidth * 0.9,
                child: Image.asset(
                  R.drawable.interview_theme,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Cảm ơn bạn đã hoàn \n thành buổi phỏng vấn!",
                style: TextStyle(
                    color: R.color.greenGradientBottom,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    height: 1.2),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 8,
              ),
              Text(
                "Cảm ơn bạn đã dành thời gian cho \n chương trình. Chuyên gia sẽ gửi kết quả \n cho bạn sớm nhất.",
                style: TextStyle(fontSize: 16, color: R.color.textDark),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16),
                  height: 48,
                  width: screenWidth * 0.45,
                  decoration: BoxDecoration(
                      color: R.color.mainColor,
                      borderRadius: BorderRadius.circular(200),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [
                            R.color.greenGradientTop,
                            R.color.greenGradientBottom
                          ])),
                  child: Center(
                      child: Text("Hoàn thành",
                          style: TextStyle(
                              color: R.color.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemTimeFrame() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius:
            BorderRadius.circular(8), // Adjust the radius value as needed
      ),
      child: Text(
        "07 : 00",
        style: TextStyle(color: R.color.mainColor, fontSize: 18),
      ),
    );
  }

  Widget _buildTimeFrameRow() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center, // Căn giữa các widget trong hàng
      children: [
        Row(
          children: [
            _buildItemTimeFrame(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "-",
                style: TextStyle(color: R.color.mainColor, fontSize: 30),
              ),
            ),
            _buildItemTimeFrame(),
          ],
        ),
        SizedBox(
          width: 12,
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Căn giữa các widget trong hàng
          children: [
            _buildItemTimeFrame(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "-",
                style: TextStyle(color: R.color.mainColor, fontSize: 30),
              ),
            ),
            _buildItemTimeFrame(),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeFrame() {
    return Center(
      child: Column(
        children: [
          _buildTimeFrameRow(),
          SizedBox(height: 16),
          _buildTimeFrameRow(),
          SizedBox(height: 16),
          _buildTimeFrameRow()
        ],
      ),
    );
  }

  Widget _buildSectionInterviewSuccess() {
    DateTime today = DateTime.now();
    // Generate activeDates list for the next 7 days
    List<DateTime> activeDates = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = today.add(Duration(days: i));
      activeDates.add(date);
    }

    return Container(
      margin: EdgeInsets.all(16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color to white
        borderRadius: BorderRadius.circular(16.0), // Set the radius here
      ),
      child: CustomCalendarDatePicker(
        initialDate: DateTime.now(),
        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
        activeDates: activeDates,
        lastDate: DateTime.now().add(Duration(days: 7)),
        onDateChanged: (datetime) {
          // selectedDate = datetime ?? DateTime.now();
        },
      ),
    );
  }

  void showPopupWaring() {}
}
