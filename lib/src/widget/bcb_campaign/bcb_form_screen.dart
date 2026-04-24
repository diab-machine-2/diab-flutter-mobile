import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/bloc/bcb_campaign/bcb_campaign_bloc.dart';
import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/model/bcb_campaign/bcb_customer_model.dart';
import 'package:medical/src/widget/bcb_campaign/components/bcb_slot_picker.dart';

/// Phase 2 — KH điền form thông tin + chọn 3 slot ngày giờ khám mong muốn.
class BcbFormScreen extends StatefulWidget {
  final BcbCampaignModel campaign;
  final BcbCustomerModel customer;

  const BcbFormScreen({
    Key? key,
    required this.campaign,
    required this.customer,
  }) : super(key: key);

  @override
  State<BcbFormScreen> createState() => _BcbFormScreenState();
}

class _BcbFormScreenState extends State<BcbFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorNoteController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  final List<DateTime?> _slots = [null, null, null];

  late BcbCampaignBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BcbCampaignBloc();

    // Pre-fill nếu đã có dữ liệu đăng ký trước đó
    final reg = widget.customer.registration;
    if (reg != null) {
      _doctorNoteController.text = reg.doctorNote ?? '';
      _medicalHistoryController.text = reg.medicalHistory ?? '';
      if (reg.wishes != null) {
        for (final wish in reg.wishes!) {
          final idx = (wish.priority ?? 1) - 1;
          if (idx >= 0 && idx < 3) {
            _slots[idx] = wish.examDate;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _doctorNoteController.dispose();
    _medicalHistoryController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onSlotChanged(int index, DateTime dateTime) {
    setState(() {
      _slots[index] = dateTime;
    });
  }

  bool get _allSlotsSelected => _slots.every((s) => s != null);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_allSlotsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn đủ 3 ngày khám mong muốn.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final wishes = List.generate(3, (i) {
      return BcbAppointmentWishModel(
        priority: i + 1,
        examDate: _slots[i],
      );
    });

    _bloc.add(SubmitBcbRegistrationEvent(
      campaignCustomerId: widget.customer.id ?? '',
      doctorNote: _doctorNoteController.text.trim().isEmpty
          ? null
          : _doctorNoteController.text.trim(),
      medicalHistory: _medicalHistoryController.text.trim().isEmpty
          ? null
          : _medicalHistoryController.text.trim(),
      wishes: wishes,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đăng ký khám sức khoẻ'),
          centerTitle: true,
        ),
        body: BlocListener<BcbCampaignBloc, BcbCampaignState>(
          listener: (context, state) {
            if (state is BcbRegistrationSubmitted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đăng ký thành công! Chúng tôi sẽ liên hệ xác nhận lịch khám.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true);
            } else if (state is BcbCampaignError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<BcbCampaignBloc, BcbCampaignState>(
            builder: (context, state) {
              final isLoading = state is BcbCampaignLoading;
              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Campaign info card ---
                          _CampaignInfoCard(campaign: widget.campaign),
                          const SizedBox(height: 20),

                          // --- Doctor note ---
                          const Text(
                            'Ghi chú cho bác sĩ',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _doctorNoteController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Nhập ghi chú cho bác sĩ (tuỳ chọn)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- Medical history ---
                          const Text(
                            'Bệnh lý',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _medicalHistoryController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Nhập bệnh lý hiện tại (tuỳ chọn)',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- Slot picker section ---
                          Row(
                            children: [
                              const Text(
                                'Chọn 3 ngày khám mong muốn',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '*',
                                style: TextStyle(
                                    color: Colors.red.shade600, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chúng tôi sẽ xếp lịch dựa trên ưu tiên của bạn.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          for (int i = 0; i < 3; i++) ...[
                            BcbSlotPicker(
                              priority: i + 1,
                              selectedDateTime: _slots[i],
                              onDateTimeSelected: (dt) =>
                                  _onSlotChanged(i, dt),
                            ),
                            if (i < 2) const SizedBox(height: 10),
                          ],
                          const SizedBox(height: 32),

                          // --- Submit button ---
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Text(
                                      'Đăng ký',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Color(0x33000000),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CampaignInfoCard extends StatelessWidget {
  final BcbCampaignModel campaign;

  const _CampaignInfoCard({Key? key, required this.campaign}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            campaign.name ?? 'Chiến dịch khám sức khoẻ',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (campaign.partnerName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business_outlined,
                    size: 14,
                    color: Theme.of(context).primaryColor.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  campaign.partnerName!,
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
