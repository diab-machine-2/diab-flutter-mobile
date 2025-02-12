import 'package:easy_localization/easy_localization.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';

const locations = [
  {'code': 'hcm', 'name_vi': 'Tp Hồ Chí Minh', 'name_en': 'Ho Chi Minh City'},
  {'code': 'hanoi', 'name_vi': 'Hà Nội', 'name_en': 'Ha Noi'},
  {'code': 'danang', 'name_vi': 'Đà Nẵng', 'name_en': 'Da Nang'},
  {'code': 'dongnai', 'name_vi': 'Đồng Nai', 'name_en': 'Dong Nai'},
  {'code': 'binhduong', 'name_vi': 'Bình Dương', 'name_en': 'Binh Duong'},
  {'code': 'brvt', 'name_vi': 'Bà Rịa Vũng Tàu', 'name_en': 'Ba Ria Vung Tau'},
  {'code': 'tiengiang', 'name_vi': 'Tiền Giang', 'name_en': 'Tien Giang'},
  {'code': 'travinh', 'name_vi': 'Trà Vinh', 'name_en': 'Tra Vinh'},
  {'code': 'cantho', 'name_vi': 'Cần Thơ', 'name_en': 'Can Tho'},
  {'code': 'thanhhoa', 'name_vi': 'Thanh Hóa', 'name_en': 'Thanh Hoa'},
  {'code': 'langson', 'name_vi': 'Lạng Sơn', 'name_en': 'Lang Son'},
  {'code': 'haiphong', 'name_vi': 'Hải Phòng', 'name_en': 'Hai Phong'},
  {'code': 'hanam', 'name_vi': 'Hà Nam', 'name_en': 'Ha Nam'},
  {'code': 'angiang', 'name_vi': 'An Giang', 'name_en': 'An Giang'},
  {'code': 'quangninh', 'name_vi': 'Quảng Ninh', 'name_en': 'Quang Ninh'},
  {'code': 'nghean', 'name_vi': 'Nghệ An', 'name_en': 'Nghe An'},
  {'code': 'ninhbinh', 'name_vi': 'Ninh Bình', 'name_en': 'Ninh Binh'},
  {'code': 'khanhhoa', 'name_vi': 'Khánh Hòa', 'name_en': 'Khanh Hoa'},
  {'code': 'vinhlong', 'name_vi': 'Vĩnh Long', 'name_en': 'Vinh Long'},
  {'code': 'namdinh', 'name_vi': 'Nam Định', 'name_en': 'Nam Dinh'},
  {'code': 'bacninh', 'name_vi': 'Bắc Ninh', 'name_en': 'Bac Ninh'},
  {'code': 'lamdong', 'name_vi': 'Lâm Đồng', 'name_en': 'Lam Dong'},
  {'code': 'tayninh', 'name_vi': 'Tây Ninh', 'name_en': 'Tay Ninh'},
  {'code': 'bentre', 'name_vi': 'Bến Tre', 'name_en': 'Ben Tre'},
  {'code': 'yenbai', 'name_vi': 'Yên Bái', 'name_en': 'Yen Bai'},
  {'code': 'binhdinh', 'name_vi': 'Bình Định', 'name_en': 'Binh Dinh'},
  {'code': 'camau', 'name_vi': 'Cà Mau', 'name_en': 'Ca Mau'},
  {'code': 'thainguyen', 'name_vi': 'Thái Nguyên', 'name_en': 'Thai Nguyen'},
  {'code': 'gialai', 'name_vi': 'Gia Lai', 'name_en': 'Gia Lai'},
  {'code': 'daklak', 'name_vi': 'Đắk Lắk', 'name_en': 'Dak Lak'},
  {'code': 'binhthuan', 'name_vi': 'Bình Thuận', 'name_en': 'Binh Thuan'},
  {'code': 'hatinh', 'name_vi': 'Hà Tĩnh', 'name_en': 'Ha Tinh'},
  {
    'code': 'thuathienhue',
    'name_vi': 'Thừa Thiên Huế',
    'name_en': 'Thua Thien Hue'
  },
  {'code': 'quangnam', 'name_vi': 'Quảng Nam', 'name_en': 'Quang Nam'},
  {'code': 'quangtri', 'name_vi': 'Quảng Trị', 'name_en': 'Quang Trị'},
  {'code': 'baclieu', 'name_vi': 'Bạc Liêu', 'name_en': 'Bac Lieu'},
  {'code': 'bacgiang', 'name_vi': 'Bắc Giang', 'name_en': 'Bac Giang'},
  {'code': 'backan', 'name_vi': 'Bắc Kạn', 'name_en': 'Bac Kan'},
  {'code': 'binhphuoc', 'name_vi': 'Bình Phước', 'name_en': 'Binh Phuoc'},
  {'code': 'caobang', 'name_vi': 'Cao Bằng', 'name_en': 'Cao Bang'},
  {'code': 'daknong', 'name_vi': 'Đắk Nông', 'name_en': 'Dak Nong'},
  {'code': 'dienbien', 'name_vi': 'Điện Biên', 'name_en': 'Dien Bien'},
  {'code': 'dongthap', 'name_vi': 'Đồng Tháp', 'name_en': 'Dong Thap'},
  {'code': 'hagiang', 'name_vi': 'Hà Giang', 'name_en': 'Ha Giang'},
  {'code': 'haiduong', 'name_vi': 'Hải Dương', 'name_en': 'Hai Dương'},
  {'code': 'haugiang', 'name_vi': 'Hậu Giang', 'name_en': 'Hau Giang'},
  {'code': 'hoabinh', 'name_vi': 'Hòa Bình', 'name_en': 'Hoa Binh'},
  {'code': 'hungyen', 'name_vi': 'Hưng Yên', 'name_en': 'Hung Yen'},
  {'code': 'kiengiang', 'name_vi': 'Kiên Giang', 'name_en': 'Kien Giang'},
  {'code': 'kontum', 'name_vi': 'Kon Tum', 'name_en': 'Kon Tum'},
  {'code': 'laichau', 'name_vi': 'Lai Châu', 'name_en': 'Lai Chau'},
  {'code': 'laocai', 'name_vi': 'Lào Cai', 'name_en': 'Lao Cai'},
  {'code': 'longan', 'name_vi': 'Long An', 'name_en': 'Long An'},
  {'code': 'ninhthuan', 'name_vi': 'Ninh Thuận', 'name_en': 'Ninh Thuan'},
  {'code': 'phutho', 'name_vi': 'Phú Thọ', 'name_en': 'Phu Tho'},
  {'code': 'phuyen', 'name_vi': 'Phú Yên', 'name_en': 'Phu Yen'},
  {'code': 'quangbinh', 'name_vi': 'Quảng Bình', 'name_en': 'Quang Binh'},
  {'code': 'soctrang', 'name_vi': 'Sóc Trăng', 'name_en': 'Soc Trang'},
  {'code': 'sonla', 'name_vi': 'Sơn La', 'name_en': 'Son La'},
  {'code': 'thaibinh', 'name_vi': 'Thái Bình', 'name_en': 'Thai Binh'},
  {'code': 'tuyenquang', 'name_vi': 'Tuyên Quang', 'name_en': 'Tuyen Quang'},
  {'code': 'vinhphuc', 'name_vi': 'Vĩnh Phúc', 'name_en': 'Vinh Phuc'},
  {
    'code': 'quangngai',
    'name_vi': 'Quảng Ngãi',
    'name_en': 'Quang Ngai',
  },
];

class CityModel {
  final String code;
  final String nameVi;
  final String nameEn;
  final String slug;

  const CityModel({
    required this.code,
    required this.nameVi,
    required this.nameEn,
    required this.slug,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CityModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

List<CityModel> getListCityModel() {
  return locations
      .where((e) => e['name_vi']?.isNotEmpty == true)
      .map((e) => CityModel(
            code: e['code'] ?? '',
            nameVi: e['name_vi'] ?? '',
            nameEn: e['name_en'] ?? '',
            slug: convertToSlug(e['name_vi'] ?? ''),
          ))
      .toList();
}

List<CityModel> getDefaultCities() {
  return getListCityModel()
      .where((e) => ['hcm', 'hanoi', 'danang'].contains(e.code))
      .toList();
}

String convertToSlug(String nameVi) {
  return nameVi
      .toLowerCase()
      .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
      .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
      .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
      .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
      .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
      .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
      .replaceAll(RegExp(r'[đ]'), 'd')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'[^\w\-]+'), '')
      .replaceAll(RegExp(r'\-\-+'), '-')
      .replaceAll(RegExp(r'^-+'), '')
      .replaceAll(RegExp(r'-+$'), '');
}

List<String> getListCity() {
  return locations
      .where((e) => e['name_vi']?.isNotEmpty == true)
      .map((e) => convertToSlug(e['name_vi']!))
      .toList();
}

String getClinicTypeDisplay(String value) {
  switch (value) {
    case Const.CLINIC_TYPE_CLINIC:
      return R.string.phong_kham.tr();
    case Const.CLINIC_TYPE_HOSPITAL:
      return R.string.benh_vien_tu.tr();
    case Const.CLINIC_TYPE_PUBLIC_HOSPITAL:
      return R.string.benh_vien_cong.tr();
    default:
      return '';
  }
}

String getClinicTimeframeDisplay(String value) {
  switch (value) {
    case Const.CLINIC_TIMEFRAME_WEEKEND:
      return R.string.cuoi_tuan.tr();
    case Const.CLINIC_TIMEFRAME_WEEKDAY:
      return R.string.ngay_trong_tuan.tr();
    case Const.CLINIC_TIMEFRAME_AFTER_HOURS:
      return R.string.ngoai_gio.tr();
    default:
      return '';
  }
}
