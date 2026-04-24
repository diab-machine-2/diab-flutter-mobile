import 'package:flutter/material.dart';

/// Badge hiển thị trạng thái của KH trong chiến dịch BCB.
/// [status] — trạng thái KH (1..10 state machine) hoặc trạng thái campaign (1..4).
class BcbStatusBadge extends StatelessWidget {
  final int? status;
  final bool isCampaignStatus;

  const BcbStatusBadge({
    Key? key,
    required this.status,
    this.isCampaignStatus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final label = isCampaignStatus
        ? _campaignStatusLabel(status)
        : _customerStatusLabel(status);
    final color = isCampaignStatus
        ? _campaignStatusColor(status)
        : _customerStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _campaignStatusLabel(int? status) {
    switch (status) {
      case 1:
        return 'Nháp';
      case 2:
        return 'Đang diễn ra';
      case 3:
        return 'Hoàn thành';
      case 4:
        return 'Đã huỷ';
      default:
        return 'Không xác định';
    }
  }

  Color _campaignStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.grey;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _customerStatusLabel(int? status) {
    switch (status) {
      case 1:
        return 'Mới';
      case 2:
        return 'Đã mời';
      case 3:
        return 'Đã đăng ký';
      case 4:
        return 'Đã xếp lịch';
      case 5:
        return 'Đã xác nhận';
      case 6:
        return 'Đã khám';
      case 7:
        return 'Có kết quả';
      case 8:
        return 'Đã nhận kết quả';
      case 9:
        return 'Hoàn thành';
      case 10:
        return 'Huỷ';
      default:
        return 'Không xác định';
    }
  }

  Color _customerStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.grey;
      case 2:
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.blue;
      case 6:
      case 7:
      case 8:
        return Colors.teal;
      case 9:
        return Colors.green;
      case 10:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
