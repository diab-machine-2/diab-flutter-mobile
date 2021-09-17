import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

class PolicyController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //     backgroundColor: R.color.white,
        //     title: Text(
        //       'Điều khoản & điều kiện',
        //       style: TextStyle(fontSize: 20, color: R.color.black),
        //     ),
        //     centerTitle: false,
        //     automaticallyImplyLeading: false,
        //     actions: [
        //       IconButton(
        //           icon: Icon(Icons.close, color: R.color.black),
        //           onPressed: () {
        //             Navigator.pop(context);
        //           })
        //     ]),
        resizeToAvoidBottomInset: false,
        backgroundColor: R.color.white,
        body: SafeArea(
            child: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: R.color.grayComponentBorder)),
            child: ListView(padding: EdgeInsets.all(16), children: [
              Image.asset('assets/images/icon_banner.png',
                  width: 106, height: 37),
              Text(
                  'Các điều khoản và điều kiện này cấu thành nên một hợp đồng giữa quý khách và Apple ("Thỏa thuận"). Vui lòng đọc kỹ Thỏa thuận. \n\nA. GIỚI THIỆU DỊCH VỤ CỦA CHÚNG TÔI\n\nThỏa thuận này điều chỉnh việc quý khách sử dụng các dịch vụ của Apple ("Dịch vụ"), thông qua đó quý khách có thể mua, nhận, cấp giấy phép, thuê hoặc đăng ký nội dung, Ứng dụng (như được định nghĩa dưới đây), và các dịch vụ khác trong ứng dụng (gọi chung là "Nội dung"). Nội dung có thể được cung cấp thông qua các Dịch vụ bởi Apple hoặc một bên thứ ba. Dịch vụ của chúng tôi sẵn có cho quý khách sử dụng ở nước hoặc lãnh thổ mà quý khách cư trú ("Nước sở tại"). Bằng cách tạo một tài khoản để sử dụng Dịch vụ ở một quốc gia hoặc vùng lãnh thổ cụ thể, quý khách đang chỉ định đó là Nước sở tại của mình. Để sử dụng Dịch vụ của chúng tôi, quý khách cần phần cứng, phần mềm tương thích (khuyến nghị và đôi khi bắt buộc sử dụng phiên bản mới nhất) và có kết nối Internet (có thể bị tính phí). Hiệu quả hoạt động của Dịch vụ của chúng tôi có thể bị ảnh hưởng bởi những yếu tố này.\n\nB. SỬ DỤNG DỊCH VỤ CỦA CHÚNG TÔI\n\nTHANH TOÁN, THUẾ VÀ HOÀN TIỀN\nQuý khách có thể có được Nội dung')
            ]),
          ),
        )));
  }
}
