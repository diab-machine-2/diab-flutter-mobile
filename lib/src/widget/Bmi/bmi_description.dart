import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class BmiDescription extends StatelessWidget {
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
                              R.drawable.icon_des_person,
                              width: 71,
                              height: 76,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text('Kiểm soát cân nặng bệnh tiểu đường',
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
                                    'Người mắc bệnh tiểu đường loại 2 thường cảm thấy khó khăn khi kiểm soát cân nặng. Tình trạng thừa cân hay béo phì lại khiến bệnh nghiêm trọng hơn.\n\nBạn sẽ bất ngờ khi biết thừa cân hoặc béo phì làm tăng nguy cơ xảy ra các biến chứng liên quan đến tiểu đường hoặc ngược lại, người tiểu đường sẽ dễ bị thừa cân và béo phì hơn. Bạn nên giảm cân bằng thói quen ăn uống lành mạnh và tập thể dục kiểm soát đường huyết để giảm nguy cơ biến chứng và nhiều vấn đề về sức khỏe khác. Tuy nhiên, nhiều lúc tiểu đường loại 2 tác động đến cân nặng một cách thầm lặng mà bạn không hề hay biết.\n\nCác yếu tố ăn uống cũng ảnh hưởng đến nguy cơ phát triển tiểu đường loại 2. Việc tiêu thụ đồ uống có đường quá mức sẽ làm gia tăng nguy cơ dẫn đến bệnh tiểu đường. Các loại chất béo trong chế độ ăn uống là rất quan trọng. Chất béo bão hòa và các acid béo chuyển hóa làm tăng nguy cơ, trong khi chất béo không bão hòa đa (polyunsaturated fat) và không bão hòa đơn (monounsaturated fat) làm giảm nguy cơ phát triển bệnh. Thói quen ăn nhiều gạo trắng cũng góp phần làm tăng nguy cơ của bệnh. Ngoài ra, có khoảng 7% bệnh nhân bị tiểu đường là do ít tập thể dục.'),
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
