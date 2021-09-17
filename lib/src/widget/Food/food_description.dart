import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class FoodDescription extends StatelessWidget {
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
                              child: Text('Chế độ dinh dưỡng bệnh tiểu đường',
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
                                    'Chế độ dinh dưỡng có khoa học giúp kiểm soát tình trạng bệnh tiểu đường tốt hơn. Theo đó, những thực phẩm người bệnh tiểu đường nên ăn bao gồm:'),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: 'Nhóm đường bột: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              'Ngũ cốc nguyên hạt, đậu đỗ, gạo còn vỏ cám, rau củ... được chế biến bằng cách hấp, luộc, nướng, hạn chế tối đa rán, xào... Các loại củ như khoai sắn cũng cung cấp khá nhiều tinh bột, nên nếu người bệnh tiểu đường ăn các loại này thì cần phải giảm hoặc cắt cơm.'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: 'Nhóm thịt cá: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              'Người bệnh tiểu đường nên ăn cá, thịt nạc, thịt gia cầm bỏ da, thịt lọc bỏ mỡ, các loại đậu đỗ... được chế biến đơn giản như hấp, luộc, áp chảo nhằm loại bớt mỡ.'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: 'Nhóm chất béo, đường: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              'Các thực phẩm có chất béo không bão hòa được ưu tiên trong chế độ ăn của người bệnh tiểu đường như dầu đậu nành, vừng, dầu cá, mỡ cá, olive...'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: 'Nhóm rau: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              'Người bệnh tiểu đường nên ăn rau nhiều hơn trong thực đơn của mình thông qua các cách chế biến đơn giản như ăn sống, hấp, luộc, rau trộn nhưng không nên sử dụng nhiều loại sốt có chất béo.'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                RichText(
                                  text: TextSpan(
                                    text: 'Hoa quả: ',
                                    style: TextStyle(
                                        color: R.color.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                    children: <TextSpan>[
                                      TextSpan(
                                          style: TextStyle(
                                              color: R.color.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal),
                                          text:
                                              'Người bệnh tiểu đường cần tăng cường ăn trái cây tươi, không nên chế biến thêm bằng cách cho thêm kem, sữa, hạn chế ăn các loại quả chín ngọt như: sầu riêng, hồng chín, xoài chín,...'),
                                    ],
                                  ),
                                )
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
