import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/my_benefit_response.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/widgets/video_widget.dart';

class BenefitPartnerIntroPage extends StatelessWidget {
  final MyBenefitItem? item;

  const BenefitPartnerIntroPage({Key? key, this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final benefitType = item?.benefitType;
    final partnerName = benefitType?.title ?? R.string.benefit_partner.tr();
    final mediaList = benefitType?.media ?? [];

    // Banner media (type == 1): whichever has the smallest sortOrder is the
    // cover, the rest (sorted ascending) form the gallery.
    final bannerMedia = mediaList.where((m) => m.type == 1).toList()
      ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
    final coverMedia = bannerMedia.isNotEmpty ? bannerMedia.first : BenefitMedia();
    final galleryMedia = bannerMedia.skip(1).toList();
    final String coverUrl = coverMedia.imageUrl?.url ?? coverMedia.url ?? '';

    // Expiration date string
    String validUntilStr = '30/06/2030';
    if (benefitType?.validUntil != null) {
      final dt =
          DateTime.fromMillisecondsSinceEpoch(benefitType!.validUntil! * 1000);
      validUntilStr = DateFormat('dd/MM/yyyy').format(dt);
    }

    // Voucher value string
    final String voucherValueStr = (benefitType?.voucherValue != null &&
            benefitType!.voucherValue!.isNotEmpty)
        ? benefitType.voucherValue!
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(context, partnerName),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCoverBanner(coverUrl),
                  _buildPartnerCard(partnerName, benefitType),
                  const SizedBox(height: 16),
                  if (galleryMedia.isNotEmpty) _buildImageGallery(galleryMedia),
                  const SizedBox(height: 20),
                  _buildBenefitContentSection(
                    context,
                    benefitType,
                    mediaList,
                    validUntilStr,
                    voucherValueStr,
                    coverUrl,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, benefitType),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.43,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // IconButton(
          //   splashColor: Colors.transparent,
          //   highlightColor: Colors.transparent,
          //   icon: SvgPicture.asset(
          //     R.icons.ic_telephone,
          //     width: 24,
          //     height: 24,
          //     fit: BoxFit.scaleDown,
          //   ),
          //   onPressed: () async {
          //     await HomeSupportFunctions.showModalAddData(context);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildCoverBanner(String coverUrl) {
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: Stack(
        children: [
          _buildImage(coverUrl, width: double.infinity, height: 220),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(String name, BenefitType? benefitType) {
    final locationText = benefitType?.location ?? '';
    final subName = (benefitType?.description ?? '').replaceAll('\\n', '\n');
    final openTime = benefitType?.openTime ?? '';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                    letterSpacing: -0.43,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: ShapeDecoration(
                  color: const Color(0x1901645A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  R.string.benefit_partner.tr(),
                  style: const TextStyle(
                    color: Color(0xFF01645A),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            subName,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.54,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationText,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.access_time, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  openTime,
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<BenefitMedia> galleryMedia) {
    final urls = galleryMedia
        .map((m) => m.imageUrl?.url ?? m.url)
        .where((u) => u != null && u.isNotEmpty)
        .cast<String>()
        .toList();

    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: urls.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => _openImageViewer(context, urls, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(urls[index], width: 140, height: 90),
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(
    BuildContext context,
    List<String> urls,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _BenefitImageGalleryViewer(
          urls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  /// Renders the voucher card when [BenefitType.hasVoucher] is set; otherwise
  /// falls back to a promo image (media type == 4) or a playable promo video
  /// (media type == 2).
  Widget _buildBenefitContentSection(
    BuildContext context,
    BenefitType? benefitType,
    List<BenefitMedia> mediaList,
    String validUntilStr,
    String voucherValueStr,
    String coverUrl,
  ) {
    if (benefitType?.hasVoucher == 1) {
      return _buildVoucherSection(
        context,
        benefitType,
        validUntilStr,
        voucherValueStr,
      );
    }

    final promoImage = mediaList.firstWhereOrNull((m) => m.type == 4);
    if (promoImage != null) {
      final url = promoImage.imageUrl?.url ?? promoImage.url ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _buildImage(
            url,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          ),
        ),
      );
    }

    final promoVideo = mediaList.firstWhereOrNull(
      (m) => m.type == 2 && (m.url ?? '').isNotEmpty,
    );
    if (promoVideo != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: VideoWidget(
            url: promoVideo.url!,
            onComplete: () {},
            setVideoManager: (_) {},
            videoTitle: benefitType?.title,
            videoThumbnail: coverUrl,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildVoucherSection(
    BuildContext context,
    BenefitType? benefitType,
    String validUntilStr,
    String voucherValueStr,
  ) {
    final code = benefitType?.voucherCode ?? '';
    final voucherName = benefitType?.voucherName ?? '';
    final voucherSubName =
        benefitType?.voucherSubName ?? '';
    final applicableTo = benefitType?.applicableTo ?? '';
    final applicableLocation =
        benefitType?.applicableLocation ?? R.string.benefit_all_branches.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              R.string.benefit_your_voucher.tr(),
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.50,
                letterSpacing: -0.22,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2, color: Color(0xFF0FB4A5)),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            // The border sits 2px inside the container's edge (its own
            // rounded rect deflated by the stroke width), but Container's
            // own clipBehavior would clip children to the outer (un-deflated)
            // path — letting the opaque child paint flush over the border at
            // the rounded corners and cut it off. Clipping the child
            // ourselves to the deflated radius (16 - 2 = 14) keeps it fully
            // inside the stroke everywhere, corners included.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section (Green background 0xFF01645A)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 18,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFF01645A)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucherName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.44,
                                letterSpacing: -0.45,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucherSubName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.80),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: ShapeDecoration(
                          color: Colors.white.withOpacity(0.20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          benefitType?.status == 1
                              ? R.string.benefit_active.tr()
                              : R.string.benefit_inactive.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Middle section: Divider with Cutout Notches
                _buildVoucherDivider(),

                // Bottom details section (White background)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 16,
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Voucher Code + Copy Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                R.string.benefit_voucher_code.tr(),
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                ),
                              ),
                              Text(
                                code,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  height: 1.50,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    R.string.benefit_copied_voucher_code.tr(),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF0FDF4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.copy,
                                    size: 14,
                                    color: Color(0xFF01645A),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    R.string.benefit_copy.tr(),
                                    style: const TextStyle(
                                      color: Color(0xFF01645A),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Key Value Rows
                      _buildVoucherRow(
                        R.string.benefit_value.tr(),
                        voucherValueStr,
                        valueColor: const Color(0xFF01645A),
                        isBold: true,
                      ),
                      const SizedBox(height: 8),
                      _buildVoucherRow(
                        R.string.benefit_apply_for.tr(),
                        applicableTo,
                      ),
                      const SizedBox(height: 8),
                      _buildVoucherRow(
                        R.string.benefit_valid_until.tr(),
                        validUntilStr,
                        valueColor: const Color(0xFF01645A),
                        isBold: true,
                      ),
                      const SizedBox(height: 8),
                      _buildVoucherRow(
                        R.string.benefit_applicable_location.tr(),
                        applicableLocation,
                      ),
                      const SizedBox(height: 14),

                      // Note Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF9FAFB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          R.string.benefit_voucher_terms_note.tr(),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherDivider() {
    return Container(
      height: 14,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherRow(
    String label,
    String value, {
    Color valueColor = const Color(0xFF1F2937),
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.50,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            height: 1.50,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, BenefitType? benefitType) {
    String remainingDaysStr = R.string.benefit_remaining_days.tr(args: ['181']);
    if (benefitType?.validUntil != null) {
      final expiry =
          DateTime.fromMillisecondsSinceEpoch(benefitType!.validUntil! * 1000);
      final now = DateTime.now();
      final diffDays = expiry.difference(now).inDays;
      remainingDaysStr = diffDays > 0
          ? R.string.benefit_remaining_days.tr(args: ['$diffDays'])
          : R.string.benefit_voucher_expired.tr();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        28 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                R.string.benefit_voucher_expiry.tr(),
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
              Text(
                remainingDaysStr,
                style: const TextStyle(
                  color: Color(0xFF01645A),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                  letterSpacing: -0.14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await HomeSupportFunctions.showModalAddData(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF01645A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                R.string.contact.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                  letterSpacing: -0.22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(
    String url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height ?? 200,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image, size: 48, color: Colors.grey),
          ),
        ),
      );
    }
    return Image.asset(
      url.isNotEmpty ? url : R.drawable.bg_home,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height ?? 200,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}

/// Full-screen swipeable viewer for a partner intro's gallery images,
/// opened by tapping a thumbnail in [BenefitPartnerIntroPage]'s carousel.
class _BenefitImageGalleryViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;

  const _BenefitImageGalleryViewer({
    required this.urls,
    required this.initialIndex,
  });

  @override
  State<_BenefitImageGalleryViewer> createState() =>
      _BenefitImageGalleryViewerState();
}

class _BenefitImageGalleryViewerState
    extends State<_BenefitImageGalleryViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildViewerImage(String url) {
    final errorBuilder = (BuildContext _, Object __, StackTrace? ___) =>
        const Center(
          child: Icon(Icons.image, size: 64, color: Colors.white54),
        );
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(url, errorBuilder: errorBuilder);
    }
    return Image.asset(url, errorBuilder: errorBuilder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.urls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Center(
              child: InteractiveViewer(
                child: _buildViewerImage(widget.urls[index]),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          if (widget.urls.length > 1)
            Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Text(
                    '${_currentIndex + 1}/${widget.urls.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
