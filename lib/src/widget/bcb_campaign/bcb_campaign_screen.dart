import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical/src/bloc/bcb_campaign/bcb_campaign_bloc.dart';
import 'package:medical/src/model/bcb_campaign/bcb_campaign_model.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/bcb_campaign/components/bcb_status_badge.dart';

/// Màn hình danh sách chiến dịch BCB của KH.
/// Tap vào campaign → navigate to form (status 1-4) hoặc result (status 9-10).
class BcbCampaignScreen extends StatefulWidget {
  final String accountId;

  const BcbCampaignScreen({Key? key, required this.accountId})
      : super(key: key);

  @override
  State<BcbCampaignScreen> createState() => _BcbCampaignScreenState();
}

class _BcbCampaignScreenState extends State<BcbCampaignScreen> {
  late BcbCampaignBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BcbCampaignBloc();
    _bloc.add(LoadBcbCampaignEvent(campaignId: widget.accountId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _onCampaignTap(BuildContext context, BcbCampaignModel campaign) {
    final customerBloc = BcbCampaignBloc();
    if (campaign.id == null) return;

    // Load customer detail first, then navigate based on customer status
    customerBloc.add(LoadMyBcbCustomerEvent(campaignId: campaign.id!));

    Navigator.of(context).pushNamed(
      NavigatorName.bcb_campaign_detail,
      arguments: {
        'campaign': campaign,
        'accountId': widget.accountId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chiến dịch khám sức khoẻ'),
          centerTitle: true,
        ),
        body: BlocBuilder<BcbCampaignBloc, BcbCampaignState>(
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
                      onPressed: () => _bloc.add(
                          LoadBcbCampaignEvent(campaignId: widget.accountId)),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is BcbCampaignListLoaded) {
              if (state.campaigns.isEmpty) {
                return const Center(
                  child: Text(
                    'Bạn chưa tham gia chiến dịch nào.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _bloc.add(
                      LoadBcbCampaignEvent(campaignId: widget.accountId));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.campaigns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final campaign = state.campaigns[index];
                    return _CampaignCard(
                      campaign: campaign,
                      onTap: () => _onCampaignTap(context, campaign),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  final BcbCampaignModel campaign;
  final VoidCallback onTap;

  const _CampaignCard({Key? key, required this.campaign, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = campaign.startDate != null
        ? DateFormat('dd/MM/yyyy').format(campaign.startDate!)
        : '--';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name ?? 'Chiến dịch',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  BcbStatusBadge(
                    status: campaign.status,
                    isCampaignStatus: true,
                  ),
                ],
              ),
              if (campaign.partnerName != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.business_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      campaign.partnerName!,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Bắt đầu: $dateStr',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios,
                      size: 12, color: Theme.of(context).primaryColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
