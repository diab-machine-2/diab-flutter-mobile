import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medical/src/bloc/bcb_campaign/bcb_campaign_bloc.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_exam_result_model.dart';

/// Phase 6 — KH xem kết quả khám.
/// Tự động gọi MarkResultViewedEvent khi màn hình mở.
class BcbResultScreen extends StatefulWidget {
  final BcbCustomerModel customer;

  const BcbResultScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<BcbResultScreen> createState() => _BcbResultScreenState();
}

class _BcbResultScreenState extends State<BcbResultScreen> {
  late BcbCampaignBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BcbCampaignBloc();
    _bloc.add(LoadBcbExamResultEvent(campaignCustomerId: widget.customer.id ?? ''));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _openFileUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở file kết quả.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kết quả khám'),
          centerTitle: true,
        ),
        body: BlocConsumer<BcbCampaignBloc, BcbCampaignState>(
          listener: (context, state) {
            if (state is BcbExamResultLoaded) {
              // Mark result viewed after loading — best effort, silent
              final result = state.result;
              if (result.id != null && result.viewedAt == null) {
                _bloc.add(MarkResultViewedEvent(examResultId: result.id!));
              }
            }
          },
          builder: (context, state) {
            if (state is BcbCampaignLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BcbCampaignError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: Colors.red.shade300),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(LoadBcbExamResultEvent(
                          campaignCustomerId: widget.customer.id ?? '')),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is BcbExamResultLoaded || state is BcbResultMarkedViewed) {
              final result = state is BcbExamResultLoaded
                  ? state.result
                  : (context.read<BcbCampaignBloc>().state is BcbExamResultLoaded
                      ? (context.read<BcbCampaignBloc>().state
                              as BcbExamResultLoaded)
                          .result
                      : widget.customer.examResult);

              if (result == null) {
                return const Center(
                  child: Text('Chưa có kết quả khám.',
                      style: TextStyle(color: Colors.grey)),
                );
              }

              return _ResultContent(
                customer: widget.customer,
                result: result,
                onViewFile: () {
                  if (result.fileUrl != null) {
                    _openFileUrl(result.fileUrl!);
                  }
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final BcbCustomerModel customer;
  final BcbExamResultModel result;
  final VoidCallback onViewFile;

  const _ResultContent({
    Key? key,
    required this.customer,
    required this.result,
    required this.onViewFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appointment = customer.appointment;
    final examDateStr = appointment?.appointmentDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(appointment!.appointmentDate!)
        : '--';
    final uploadedStr = result.uploadedAt != null
        ? DateFormat('dd/MM/yyyy').format(result.uploadedAt!)
        : '--';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Patient info card ---
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.person_outline,
                label: 'Bệnh nhân',
                value: customer.fullName ?? '--',
              ),
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Ngày khám',
                value: examDateStr,
              ),
              if (appointment?.clinicName != null) ...[
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Phòng khám',
                  value: appointment!.clinicName!,
                ),
              ],
              if (appointment?.doctorName != null) ...[
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Bác sĩ',
                  value: appointment!.doctorName!,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // --- Exam result card ---
          _InfoCard(
            children: [
              const Text(
                'Kết quả khám',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.upload_file_outlined,
                label: 'Ngày cập nhật',
                value: uploadedStr,
              ),
              if (result.additionalServices != null &&
                  result.additionalServices!.isNotEmpty) ...[
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.add_circle_outline,
                  label: 'Dịch vụ bổ sung',
                  value: result.additionalServices!,
                ),
              ],
              if (result.viewedAt != null) ...[
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.visibility_outlined,
                  label: 'Đã xem lúc',
                  value: DateFormat('dd/MM/yyyy HH:mm').format(result.viewedAt!),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // --- View file button ---
          if (result.fileUrl != null && result.fileUrl!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewFile,
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text(
                  'Xem file kết quả',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Text(
                  'File kết quả chưa sẵn sàng.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({Key? key, required this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
