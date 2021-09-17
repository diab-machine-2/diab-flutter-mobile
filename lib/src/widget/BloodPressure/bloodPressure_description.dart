import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class BloodPressureDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.transparent,
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bg_des.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            Image.asset(
                              'assets/images/icon_des_person.png',
                              width: 71,
                              height: 76,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                  'Chỉ số huyết áp đối với bệnh tiểu đường',
                                  style: TextStyle(
                                      color: R.color.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                            )
                          ]),
                          SizedBox(height: 16),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: ListView(children: [
                                Text(
                                    'Tăng huyết áp, hay huyết áp cao, rất thường gặp ở những người bị đái tháo đường (tiểu đường) tuýp 2. Dù chưa biết lý do vì sao có sự tương quan đáng kể giữa đái tháo đường và tăng huyết áp nhưng người ta giả định rằng béo phì, chế độ ăn uống nhiều natri và lười vận động dẫn đến sự gia tăng đồng thời cả hai bệnh trên.\n\nTăng huyết áp được biết đến như một “kẻ giết người thầm lặng” vì nó không có triệu chứng rõ ràng. Một cuộc khảo sát năm 2002 của Hiệp hội Đái tháo đường Hoa Kỳ (ADA) cho thấy, khoảng 68% những người bị bệnh đái tháo đường không biết họ cũng có nguy cơ gia tăng bệnh tim và đột quỵ vì liên quan đến tăng huyết áp mạn tính.\n\nTăng huyết áp kéo dài sẽ khiến cho cơ tim mệt mỏi do phải bơm máu với áp lực cao và khiến cơ tim dần giãn rộng ra. Trong năm 2008, những người bệnh đái tháo đường trên 20 tuổi có huyết áp cao hơn 140/90 chiếm tới 67%.\n\nỞ người khỏe mạnh, huyết áp 140/90 được xem là bình thường, nhưng đối với bệnh nhân đái tháo đường tuýp 2, các bác sĩ khuyên bạn nên giữ chỉ số này thấp hơn 135/80.\n\nTrong đó, con số đầu tiên (135) được gọi là huyết áp tâm thu, cho thấy áp lực máu do tim co bóp để bơm đi. Số thứ hai (80), được gọi là huyết áp tâm trương, là áp lực được duy trì trong các động mạch giữa các nhịp co bóp của tim.\n\nNgười khỏe mạnh nên kiểm tra huyết áp vài lần trong năm, nhưng bệnh nhân đái tháo đường cần phải thận trọng hơn. Ngoài việc kiểm tra huyết áp ít nhất bốn lần mỗi năm, các chuyên gia khuyến cáo hãy tự theo dõi tại nhà, ghi lại các chỉ số và thông báo với bác sĩ.'),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xff4BB2AB),
                            borderRadius: BorderRadius.circular(30)),
                        child: IconButton(
                            icon: Icon(Icons.close, color: R.color.white),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ),
                  )
                ],
              ))),
    );
  }
}
