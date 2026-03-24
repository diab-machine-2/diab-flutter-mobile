import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class CancellationRefundPolicyController extends StatefulWidget {
  @override
  State<CancellationRefundPolicyController> createState() =>
      _CancellationRefundPolicyControllerState();
}

class _CancellationRefundPolicyControllerState
    extends State<CancellationRefundPolicyController> {
  String get policyHtml => '''
    <div style="font-family: 'Roboto', sans-serif; line-height: 1.6; color: #333;">
      <h1 style="color: #000000; font-size: 24px; font-weight: bold; margin-bottom: 20px; text-align: center;">
        Chính sách hủy dịch vụ và hoàn tiền
      </h1>
      
      <h2 style="color: #000000; font-size: 20px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;">
        1. Điều kiện hủy/hoàn dịch vụ
      </h2>
      
      <h3 style="color: #000000; font-size: 18px; font-weight: bold; margin-top: 20px; margin-bottom: 10px;">
        1.1. Ngay tại thời điểm xác nhận dịch vụ:
      </h3>
      <p style="margin-bottom: 15px; padding-left: 8px;">
        Nếu phát hiện thông tin đặt dịch vụ sai lệch (ví dụ: sai tên khách hàng, sai gói dịch vụ, sai thời gian đặt lịch), khách hàng có quyền từ chối xác nhận và yêu cầu chỉnh sửa ngay.
      </p>
      
      <h3 style="color: #000000; font-size: 18px; font-weight: bold; margin-top: 20px; margin-bottom: 10px;">
        1.2. Sau khi thanh toán:
      </h3>
      <p style="margin-bottom: 10px; padding-left: 8px;">Khách hàng có thể yêu cầu hủy/hoàn dịch vụ trong các trường hợp:</p>
      <ul style="margin-bottom: 15px; padding-left: 0px;">
        <li style="margin-bottom: 8px;">Lịch hẹn hoặc dịch vụ không thể thực hiện do lỗi từ phía hệ thống hoặc nhà cung cấp (ví dụ: bác sĩ/đơn vị xét nghiệm không thể tiếp nhận đúng giờ đã đặt).</li>
        <li style="margin-bottom: 8px;">Gói dịch vụ/subscription bị kích hoạt sai so với đơn hàng (nhầm loại gói, nhầm thời lượng, thiếu quyền lợi đi kèm).</li>
        <li style="margin-bottom: 8px;">Dịch vụ bị gián đoạn, không thể truy cập hoặc sử dụng theo cam kết trong hợp đồng/gói.</li>
      </ul>
      
      <h3 style="color: #000000; font-size: 18px; font-weight: bold; margin-top: 20px; margin-bottom: 10px;">
        1.3. Không áp dụng hoàn trả trong các trường hợp:
      </h3>
      <ul style="margin-bottom: 15px; padding-left: 0px;">
        <li style="margin-bottom: 8px;">Khách hàng thay đổi ý định cá nhân sau khi dịch vụ đã được sử dụng một phần hoặc toàn bộ.</li>
        <li style="margin-bottom: 8px;">Khách hàng tự ý cung cấp thông tin sai lệch dẫn đến không thể thực hiện dịch vụ.</li>
      </ul>
      
      <hr style="border: none; border-top: 2px solid #E0E0E0; margin: 20px 0;">
      
      <h2 style="color: #000000; font-size: 20px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;">
        2. Phương thức hoàn tiền
      </h2>
      <ul style="margin-bottom: 15px; padding-left: 0px;">
        <li style="margin-bottom: 10px;"><strong>Hoàn toàn:</strong> Nếu toàn bộ dịch vụ không thể cung cấp, khách hàng sẽ được hoàn 100% chi phí qua tài khoản ngân hàng.</li>
        <li style="margin-bottom: 10px;"><strong>Một phần:</strong> Nếu dịch vụ đã sử dụng một phần, hệ thống sẽ tính toán phần giá trị chưa sử dụng (pro-rata) để hoàn tiền hoặc quy đổi thành điểm tín dụng/tài khoản thành viên.</li>
        <li style="margin-bottom: 10px;"><strong>Đổi dịch vụ:</strong> Trong trường hợp còn dịch vụ thay thế tương đương, khách hàng có thể chọn đổi sang dịch vụ khác thay vì hoàn tiền.</li>
      </ul>
      
      <hr style="border: none; border-top: 2px solid #E0E0E0; margin: 20px 0;">
      
      <h2 style="color: #000000; font-size: 20px; font-weight: bold; margin-top: 8px;">
        3. Quy trình yêu cầu hoàn tiền
      </h2>
      <ol style="padding-left: 0px;">
        <li style="margin-bottom: 10px;">Khách hàng cần gửi yêu cầu trong vòng 24 giờ kể từ khi phát sinh sự cố hoặc phát hiện lỗi, thông qua website/app hoặc hotline CSKH.</li>
        <li style="margin-bottom: 10px;">Bộ phận CSKH sẽ phản hồi về tính hợp lệ của yêu cầu trong vòng 72 giờ.</li>
        <li style="margin-bottom: 10px;">Nếu hợp lệ, trong vòng 48 giờ tiếp theo, khách hàng sẽ được hướng dẫn lựa chọn hình thức hoàn tiền/đổi dịch vụ.</li>
        <li style="margin-bottom: 10px;">Sau khi xác nhận, hệ thống sẽ xử lý hoàn tiền trong vòng 5–15 ngày làm việc (không tính Thứ 7, Chủ Nhật và ngày lễ).</li>
      </ol>
      
      <hr style="border: none; border-top: 2px solid #E0E0E0; margin: 20px 0;">
      
      <h2 style="color: #000000; font-size: 20px; font-weight: bold; margin-top: 15px; margin-bottom: 10px;">
        4. Yêu cầu với dịch vụ hủy/hoàn
      </h2>
      <p style="margin-bottom: 10px;">Một yêu cầu hoàn dịch vụ hợp lệ phải đảm bảo:</p>
      <ul style="margin-bottom: 15px; padding-left: 0px;">
        <li style="margin-bottom: 8px;">Thông tin cung cấp trong "Phiếu yêu cầu hủy/hoàn dịch vụ" đầy đủ và chính xác.</li>
        <li style="margin-bottom: 8px;">Dịch vụ chưa sử dụng hoặc chỉ sử dụng một phần nhỏ (tùy theo quy định từng gói).</li>
        <li style="margin-bottom: 8px;">Mỗi đơn dịch vụ chỉ có thể yêu cầu hủy/hoàn tối đa 1 lần.</li>
      </ul>
      
      <p style="margin-bottom: 10px; font-weight: bold;">Các trường hợp không hợp lệ bao gồm:</p>
      <ul style="margin-bottom: 15px; padding-left: 0px;">
        <li style="margin-bottom: 8px;">Gửi yêu cầu quá hạn 10 ngày sau khi được xác nhận hủy/hoàn.</li>
        <li style="margin-bottom: 8px;">Thông tin cung cấp không trùng khớp với dữ liệu hệ thống.</li>
        <li style="margin-bottom: 8px;">Dịch vụ đã được sử dụng toàn bộ.</li>
      </ul>
      
      <hr style="border: none; border-top: 2px solid #E0E0E0; margin: 20px 0;">
      
      <h2 style="color: #000000; font-size: 20px; font-weight: bold; margin-top: 0px; margin-bottom: 10px;">
        5. Thời gian xử lý hoàn tiền
      </h2>
      <p style="margin-bottom: 10px;">Nếu yêu cầu hợp lệ, khách hàng sẽ nhận được hoàn tiền hoặc điểm tín dụng trong vòng 5–15 ngày làm việc kể từ ngày xác nhận.</p>
      <p style="margin-bottom: 20px;">Nếu yêu cầu không hợp lệ, bộ phận CSKH sẽ liên hệ để thỏa thuận phương án xử lý khác (nếu có).</p>
    </div>
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  R.color.color0xFFFDC798.withOpacity(0.3),
                  R.color.greenbg.withOpacity(0.9),
                ],
                begin: FractionalOffset(1, 1),
                end: FractionalOffset(0.9, 0.5),
                stops: [0.0, 1.0])),
        child: Column(
          children: [
            CustomAppBar(
              backgroundColor: R.color.transparent,
              title: Text("Chính sách đổi trả",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: R.color.textDark)),
              leadingIcon: IconButton(
                  splashColor: R.color.transparent,
                  highlightColor: R.color.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.textDark),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Html(
                    data: policyHtml,
                    style: {
                      "body": Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
