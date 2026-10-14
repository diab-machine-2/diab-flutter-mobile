import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';

/// One option of [SpecialtyGrid]: a local 3D icon ([assetIcon]) when we have
/// one for the specialty, otherwise the backend image ([networkIcon]).
class SpecialtyGridItem {
  const SpecialtyGridItem({
    required this.name,
    required this.onTap,
    this.assetIcon,
    this.networkIcon,
  });

  final String name;
  final String? assetIcon;
  final String? networkIcon;
  final VoidCallback onTap;
}

/// "Chọn nhu cầu khám" grid (Figma 22514:9046): 3 columns of round 3D icons
/// with the specialty name underneath. Shared by the benefit flow and the
/// Home utilities booking flows, which keep their own data and navigation.
class SpecialtyGrid extends StatelessWidget {
  const SpecialtyGrid({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 24),
  });

  static const int columns = 3;

  final List<SpecialtyGridItem> items;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final rows = <List<SpecialtyGridItem>>[
      for (var i = 0; i < items.length; i += columns)
        items.sublist(i, (i + columns).clamp(0, items.length)),
    ];
    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var c = 0; c < columns; c++) ...[
                  if (c > 0) const SizedBox(width: 12),
                  Expanded(
                    child: c < rows[r].length
                        ? _SpecialtyOption(item: rows[r][c])
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialtyOption extends StatelessWidget {
  const _SpecialtyOption({required this.item});

  final SpecialtyGridItem item;

  @override
  Widget build(BuildContext context) {
    // Icons are 256px; decode at display size.
    final cache = (64 * MediaQuery.devicePixelRatioOf(context)).round();
    final fallback = Image.asset(R.drawable.ic3d_chung,
        width: 64, height: 64, cacheWidth: cache);
    final Widget icon = item.assetIcon != null
        ? Image.asset(item.assetIcon!, width: 64, height: 64, cacheWidth: cache)
        : (item.networkIcon?.isNotEmpty == true
            // API images are square photos; crop to the circle so they sit
            // with the 3D icons.
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: item.networkIcon!,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => fallback,
                ),
              )
            : fallback);
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  R.color.specialtyCircleTop,
                  R.color.specialtyCircleBottom,
                ],
              ),
            ),
            child: icon,
          ),
          const SizedBox(height: 10),
          Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: R.color.color0xff111515,
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Local 3D icons for specialties.
class SpecialtyIcons {
  SpecialtyIcons._();

  /// Benefit flow: the image file code the Docosan API returns
  /// (`.../cxk.png` → `cxk`). Unknown → null (use the API image).
  static String? forImageCode(String? image) {
    if (image == null || image.isEmpty) return null;
    final fileName = image.replaceAll('\\', '/').split('/').last;
    final dot = fileName.lastIndexOf('.');
    final code =
        (dot > 0 ? fileName.substring(0, dot) : fileName).toLowerCase();
    switch (code) {
      case 'cxk':
        return R.drawable.ic3d_co_xuong_khop;
      case 'tcbp':
        return R.drawable.ic3d_thua_can_beo_phi;
      case 'tt':
        return R.drawable.ic3d_tinh_than;
      case 'tdtd':
        return R.drawable.ic3d_tien_dai_thao_duong;
      case 'dtd':
        return R.drawable.ic3d_dai_thao_duong;
      case 'dtdtk':
        return R.drawable.ic3d_dtd_thai_ky;
      case 'rlch':
        return R.drawable.ic3d_roi_loan_chuyen_hoa;
      case 'tha':
        return R.drawable.ic3d_tang_huyet_ap;
      case 'tm':
        return R.drawable.ic3d_tim_mach;
      case 'tmt':
        return R.drawable.ic3d_than_man_tinh;
    }
    return null;
  }

  /// Benefit flow fallback by specialty name slug (for specialties without a
  /// known image code, e.g. "dinh-duong", "van-dong").
  static String? forNameSlug(String slug) {
    switch (slug) {
      case 'dinh-duong':
        return R.drawable.ic3d_dinh_duong;
      case 'van-dong':
        return R.drawable.ic3d_van_dong;
      case 'co-xuong-khop':
        return R.drawable.ic3d_co_xuong_khop;
      case 'thua-can-beo-phi':
        return R.drawable.ic3d_thua_can_beo_phi;
      case 'tinh-than':
        return R.drawable.ic3d_tinh_than;
      case 'tien-dai-thao-duong':
        return R.drawable.ic3d_tien_dai_thao_duong;
      case 'dai-thao-duong':
        return R.drawable.ic3d_dai_thao_duong;
      case 'dai-thao-duong-thai-ky':
        return R.drawable.ic3d_dtd_thai_ky;
      case 'roi-loan-chuyen-hoa':
        return R.drawable.ic3d_roi_loan_chuyen_hoa;
      case 'tang-huyet-ap':
        return R.drawable.ic3d_tang_huyet_ap;
      case 'tim-mach':
        return R.drawable.ic3d_tim_mach;
      case 'than-man-tinh':
        return R.drawable.ic3d_than_man_tinh;
    }
    return null;
  }
}
