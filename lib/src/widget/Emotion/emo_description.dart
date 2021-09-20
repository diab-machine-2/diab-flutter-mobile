import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class EmoDescription extends StatelessWidget {
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
                          image: AssetImage(R.drawable.bg_des),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            Image.asset(
                              R.drawable.im_des_person,
                              width: 71,
                              height: 76,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text('Kiểm soát cảm xúc bệnh tiểu đường',
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
                                    'Một chẩn đoán bệnh tiểu đường có thể đến như một cú sốc. Bạn có thể trải qua nhiều cảm xúc, và thật bình thường khi có cảm giác tức giận, buồn bã, đau buồn, chối bỏ, mất mát hoặc sợ hãi. Nếu những cảm xúc này trở nên quá khó đối phó, điều quan trọng là nói chuyện với bác sĩ gia đình của bạn hoặc tìm kiếm sự trợ giúp chuyên nghiệp.\nÁp lực của việc theo dõi và quản lý bệnh tiểu đường có thể gây căng thẳng - và căng thẳng có thể gây ra sự dao động về mức đường huyết, cũng như có ảnh hưởng đến sức khỏe tâm thần chung của bạn.\nCố gắng đặt kỳ vọng thực tế và các chiến lược thực tế để đối phó với những suy nghĩ, cảm xúc và cảm xúc liên quan đến bệnh tiểu đường. Cũng cố gắng để giữ một số quan điểm về mục tiêu của bạn và những gì bạn có thể quản lý '),
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
                            color: R.color.greenGradientTop,
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
