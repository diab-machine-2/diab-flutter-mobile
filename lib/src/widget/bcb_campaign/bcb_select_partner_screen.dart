import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/bcb_campaign/bcb_partner_info_model.dart';
import 'package:medical/src/repo/bcb_campaign/bcb_campaign_client.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/bcb_campaign/bcb_select_wish_slots_screen.dart';

class BcbSelectPartnerScreen extends StatefulWidget {
  final String bcbCampaignId;
  final String? bcbCampaignName;
  final bool isReschedule;
  final String? appointmentId;

  const BcbSelectPartnerScreen({
    Key? key,
    required this.bcbCampaignId,
    this.bcbCampaignName,
    this.isReschedule = false,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<BcbSelectPartnerScreen> createState() => _BcbSelectPartnerScreenState();
}

class _BcbSelectPartnerScreenState extends State<BcbSelectPartnerScreen> {
  List<BcbPartnerInfo> _partners = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  Future<void> _fetchPartners() async {
    setState(() => _loading = true);
    try {
      final client = BcbCampaignClient();
      final partners = await client.fetchPartnerInfos(widget.bcbCampaignId);
      if (!mounted) return;
      setState(() => _partners = partners);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onPartnerTap(BcbPartnerInfo partner) {
    final scheduleDays = partner.toScheduleDays();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BcbSelectWishSlotsScreen(
          bcbCampaignId: widget.bcbCampaignId,
          bcbCampaignName: widget.bcbCampaignName,
          scheduleDays: scheduleDays,
          isReschedule: widget.isReschedule,
          appointmentId: widget.appointmentId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: R.color.greenGradientBottom,
                    ),
                  )
                : _partners.isEmpty
                    ? Center(
                        child: Text(
                          'Không có phòng khám nào',
                          style: TextStyle(color: R.color.color0xff111515),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _partners.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildPartnerItem(_partners[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SizedBox(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
            stops: const [0.01, 0.99],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: CustomAppBar(
          backgroundColor: R.color.transparent,
          centerTitle: false,
          title: Text(
            'Chọn phòng khám',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xffFFFFFF),
            ),
          ),
          leadingIcon: IconButton(
            splashColor: R.color.transparent,
            highlightColor: R.color.transparent,
            icon: Icon(Icons.arrow_back, color: R.color.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerItem(BcbPartnerInfo partner) {
    return GestureDetector(
      onTap: () => _onPartnerTap(partner),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: R.color.color0xff111515.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              partner.partnerName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: R.color.color0xff111515,
              ),
            ),
            if (partner.partnerAddress != null &&
                partner.partnerAddress!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    R.drawable.ic_map_marker,
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      partner.partnerAddress!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: R.color.color0xff777E90,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
