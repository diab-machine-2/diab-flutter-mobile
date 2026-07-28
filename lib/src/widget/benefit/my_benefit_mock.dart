import 'package:medical/src/model/response/my_benefit_response.dart';

/// Mock response matching the real `GET App/UserBundleOrders/my-benefit`
/// contract: `itemType`/`appFeature` are raw wire ints (see
/// [BenefitBundleItemType.resolve]), and `bookingType` is derived rather
/// than sent on the wire. Covers every item type plus the ignored
/// (`itemType == 0`) case and all three partnerIntro content branches
/// (voucher / promo image / promo video).
class MyBenefitMock {
  static MyBenefitResponse get response {
    // Two partnerIntro vouchers stay valid relative to "now" so the intro
    // page's remaining-days countdown always has something to show; two more
    // (Mommy Spa & Skincare, WeCare247) are deliberately left expired to
    // exercise the "Hết hạn" fallback — WeCare247 also has hasVoucher == 1,
    // so it doubles as the expired-card case on the "Voucher của tôi" list
    // (BenefitMyVoucherPage), which only lists items with an actual voucher.
    final now = DateTime.now();
    final validUntilMedArmor =
        now.add(const Duration(days: 200)).millisecondsSinceEpoch ~/ 1000;
    final validUntilCalifornia =
        now.add(const Duration(days: 90)).millisecondsSinceEpoch ~/ 1000;
    final validUntilMommySpaExpired =
        now.subtract(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000;
    final validUntilWeCareExpired =
        now.subtract(const Duration(days: 10)).millisecondsSinceEpoch ~/ 1000;

    return MyBenefitResponse.fromJson({
      'meta': {'success': true},
      'data': {
        'id': 'e2937f30-eec6-4071-13b9-08ded80d5c30',
        'name': 'Chương trình Chăm sóc sức khoẻ doanh nghiệp',
        'status': 1,
        'remainingDays': 200,
        'startDate': 1782777600,
        'endDate': 1790726400,
        'totalItems': 18,
        'usedItems': 0,
        'completionPercent': 0,
        'sections': [
          {
            'tagName': 'Thăm khám & Xét nghiệm',
            'items': [
              {
                'itemId': 'ignored-001',
                'itemType': 0,
                'appFeature': 0,
                'name': 'Glucophage XR 750mg',
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 0,
                'discountValue': 0,
                'discountType': 0,
              },
              {
                'itemId': 'booking-telemedicine-001',
                'itemType': 2,
                'appFeature': 1,
                'name': 'Tư vấn chuyên sâu với bác sĩ',
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 0,
                'discountValue': 0,
                'discountType': 0,
                'specialtyName': 'Cơ xương khớp',
                'clinicId': 1671,
              },
              {
                'itemId': 'booking-at-clinic-001',
                'itemType': 2,
                'appFeature': 2,
                'name': 'Khám cơ xương khớp',
                'category': 1,
                'specialtyId': 29,
                'specialtyName': 'Cơ xương khớp',
                'clinicId': 1644,
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 0,
                'discountValue': 0,
                'discountType': 0,
              },
              {
                'itemId': 'medicine-purchase-001',
                'itemType': 2,
                'appFeature': 5,
                'name': 'Giao thuốc tận nhà',
                'isUnlimited': 1,
                'quantity': 0,
                'quantityUsed': 0,
                'discountValue': 0,
                'discountType': 0,
              },
              {
                'itemId': 'lab-test-001',
                'itemType': 2,
                'appFeature': 6,
                'name': 'Xét nghiệm tại nhà',
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 0,
                'discountValue': 5,
                'discountType': 0,
              }
            ],
          },
          {
            'tagName': 'Dịch vụ sức khoẻ',
            'items': [
              {
                'itemId': 'report-001',
                'itemType': 2,
                'appFeature': 4,
                'name': 'Phân tích sức khỏe & Lộ trình cải thiện',
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 1,
                'discountValue': 0,
                'discountType': 0,
              },
              {
                'itemId': 'dsp-001',
                'itemType': 1,
                'appFeature': 0,
                'name': 'Chương trình nền tảng sức khỏe',
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 0,
                'discountValue': 0,
                'discountType': 0,
                "totalWeek": 12,
                "currentWeek": 3,
              },
              {
                'itemId': 'partner-004',
                'itemType': 2,
                'appFeature': 3,
                'name': 'Xét nghiệm Gene',
                'isUnlimited': 0,
                'quantity': 0,
                'quantityUsed': 0,
                'discountValue': 5,
                'discountType': 0,
                'benefitType': {
                  'id': 'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
                  'title': 'MedArmor',
                  'contentType': 2,
                  'contentValue': '',
                  'description':
                      'MedArmor Vietnam là trung tâm tầm soát và chăm sóc sức khỏe công nghệ cao, đặt tại 33C Lê Thánh Tôn, Quận 1, ứng dụng sinh học phân tử và trí tuệ nhân tạo để phân tích đa tầng dữ liệu sức khỏe cá nhân. \n Hệ thống 4DMatrix™ đánh giá hàng trăm chỉ dấu sinh học (gen, máu, mRNA, vi sinh đường ruột), hỗ trợ phát hiện sớm xu hướng sức khỏe và cá nhân hóa tư vấn phòng ngừa lâu dài. \n Trung tâm flagship tại TP.HCM, kết nối mạng lưới chuyên gia và đối tác y tế quốc tế để tư vấn chuyên sâu và theo dõi sức khỏe chủ động.',
                  'location': '33C Lê Thánh Tôn, Quận 1, TP.HCM',
                  'openTime':
                      '08:30 – 17:30, Thứ 2 – Thứ 7 (giờ có thể thay đổi, vui lòng đặt lịch trước)',
                  'status': 1,
                  'tag': null,
                  'hasVoucher': 1,
                  'voucherName': 'GIẢM 10%',
                  'voucherSubName': 'Gói dịch vụ tại MedArmor',
                  'voucherCode': 'CFY-CORP-2024',
                  'voucherValue': 'Giảm 10% trên tổng hoá đơn',
                  'applicableTo': 'Nhân viên Axon',
                  'validUntil': validUntilMedArmor,
                  'applicableLocation': 'Tất cả cơ sở',
                  'order': 1,
                  'bundleTagId': '76771441-2222-44e7-1909-08dedbdbb239',
                  'media': [
                    {
                      'id': '21e703a4-60d8-452f-c851-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
                      'imageId': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 0,
                      'imageUrl': {
                        'id': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                        'url': 'lib/res/drawables/med_image_title.jpg',
                      },
                    },
                    {
                      'id': '4025aa68-d124-4ba7-c84f-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
                      'imageId': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 1,
                      'imageUrl': {
                        'id': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                        'url': 'lib/res/drawables/med_sub_image_1.jpg',
                      },
                    },
                    {
                      'id': '809c4faf-aff7-44f4-c850-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'b5bbd0ea-2fb9-4c75-0ca4-08dedbdbb8bc',
                      'imageId': '958c06ee-afad-4d91-f214-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 2,
                      'imageUrl': {
                        'id': '958c06ee-afad-4d91-f214-08dee7defb35',
                        'url': 'lib/res/drawables/med_sub_image_2.jpg',
                      },
                    },
                  ],
                },
              },
              {
                'itemId': 'partner-001',
                'itemType': 2,
                'appFeature': 3,
                'name': 'Dịch vụ chăm sóc mẹ bầu Mommy Spa & Skincare',
                'isUnlimited': 0,
                'quantity': 0,
                'quantityUsed': 0,
                'discountValue': 5,
                'discountType': 0,
                'benefitType': {
                  'id': 'c4d7e1fa-2fb9-4c75-0ca4-08dedbdbb8bd',
                  'title': 'Mommy Spa & Skincare',
                  'contentType': 1,
                  'contentValue': '',
                  'description':
                      'Mommy Spa & Skincare là thương hiệu tiên phong chăm sóc mẹ bầu và mẹ sau sinh uy tín tại Việt Nam, hoạt động từ năm 2009 với hệ thống dịch vụ chuẩn y khoa.\n Các liệu trình massage, chăm sóc sau sinh và giảm béo bụng được xây dựng dưới sự tư vấn của bác sĩ chuyên khoa, kết hợp công nghệ INDIBA để phục hồi sức khỏe và sắc đẹp cho phụ nữ hiện đại.',
                  'location':
                      'Nhiều cơ sở tại TP.HCM & bệnh viện đối tác: Vinmec Central Park, Gia Định, Đồng Nai 2…',
                  'openTime':
                      '09:30 – 20:00 (giờ mở cửa có thể khác theo từng cơ sở)',
                  'status': 1,
                  'tag': null,
                  // No active voucher for this partner — the intro page
                  // falls back to a promo image (media type == 4).
                  'hasVoucher': 0,
                  'voucherName': 'GIẢM 10%',
                  'voucherSubName': 'Gói dịch vụ tại Mommy Spa & Skincare',
                  'voucherCode': 'CFY-CORP-2024',
                  'voucherValue': 'Giảm 10% trên tổng hoá đơn',
                  'applicableTo': 'Nhân viên Axon',
                  'validUntil': validUntilMommySpaExpired,
                  'applicableLocation': 'Tất cả cơ sở',
                  'order': 1,
                  'bundleTagId': '76771441-2222-44e7-1909-08dedbdbb239',
                  'media': [
                    {
                      'id': '21e703a4-60d8-452f-c851-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'c4d7e1fa-2fb9-4c75-0ca4-08dedbdbb8bd',
                      'imageId': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 0,
                      'imageUrl': {
                        'id': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                        'url': 'lib/res/drawables/mommy_image_title.jpg',
                      },
                    },
                    {
                      'id': '4025aa68-d124-4ba7-c84f-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'c4d7e1fa-2fb9-4c75-0ca4-08dedbdbb8bd',
                      'imageId': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 1,
                      'imageUrl': {
                        'id': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                        'url': 'lib/res/drawables/mommy_sub_image_1.jpg',
                      },
                    },
                    {
                      'id': '809c4faf-aff7-44f4-c850-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'c4d7e1fa-2fb9-4c75-0ca4-08dedbdbb8bd',
                      'imageId': '958c06ee-afad-4d91-f214-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 2,
                      'imageUrl': {
                        'id': '958c06ee-afad-4d91-f214-08dee7defb35',
                        'url': 'lib/res/drawables/mommy_sub_image_2.jpg',
                      },
                    },
                    {
                      'id': '809c4faf-aff7-44f4-c850-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'c4d7e1fa-2fb9-4c75-0ca4-08dedbdbb8bd',
                      'imageId': '958c06ee-afad-4d91-f214-08dee7defb35',
                      'url': null,
                      'type': 4,
                      'sortOrder': 2,
                      'imageUrl': {
                        'id': '958c06ee-afad-4d91-f214-08dee7defb35',
                        'url': 'lib/res/drawables/mommy_image_voucher.jpg',
                      },
                    },
                  ],
                },
              },
              {
                'itemId': 'partner-002',
                'itemType': 2,
                'appFeature': 3,
                'name': 'Tập luyện tại California Fitness & Yoga',
                'isUnlimited': 0,
                'quantity': 0,
                'quantityUsed': 0,
                'discountValue': 0,
                'discountType': 0,
                'benefitType': {
                  'id': 'd5e8f2ab-2fb9-4c75-0ca4-08dedbdbb8be',
                  'title': 'California Fitness & Yoga',
                  'contentType': 1,
                  'contentValue': '',
                  'description':
                      'Chuỗi phòng gym & yoga hàng đầu tại Việt Nam với hơn 20 cơ sở trên toàn quốc. Trang thiết bị hiện đại, đội ngũ HLV chuyên nghiệp và không gian rộng rãi, thoáng mát.',
                  'location': '20+ cơ sở tại TP.HCM, Hà Nội, Đà Nẵng',
                  'openTime': 'Mở cửa 05:30 – 22:30, tất cả các ngày',
                  'status': 1,
                  'tag': null,
                  // No active voucher — falls back to a promo video
                  // (media type == 2), played via VideoWidget.
                  'hasVoucher': 0,
                  'voucherName': 'GIẢM 10%',
                  'voucherSubName': 'Gói dịch vụ tại California Fitness & Yoga',
                  'voucherCode': 'CFY-CORP-2024',
                  'voucherValue': 'Miễn phí 100%',
                  'applicableTo': 'Nhân viên Axon',
                  'validUntil': validUntilCalifornia,
                  'applicableLocation': 'Tất cả cơ sở',
                  'order': 1,
                  'bundleTagId': '76771441-2222-44e7-1909-08dedbdbb239',
                  'media': [
                    {
                      'id': '21e703a4-60d8-452f-c851-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'd5e8f2ab-2fb9-4c75-0ca4-08dedbdbb8be',
                      'imageId': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 0,
                      'imageUrl': {
                        'id': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                        'url': 'lib/res/drawables/cali_image_title.jpg',
                      },
                    },
                    {
                      'id': '4025aa68-d124-4ba7-c84f-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'd5e8f2ab-2fb9-4c75-0ca4-08dedbdbb8be',
                      'imageId': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 1,
                      'imageUrl': {
                        'id': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                        'url': 'lib/res/drawables/cali_sub_image_1.jpg',
                      },
                    },
                    {
                      'id': '809c4faf-aff7-44f4-c850-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'd5e8f2ab-2fb9-4c75-0ca4-08dedbdbb8be',
                      'imageId': '958c06ee-afad-4d91-f214-08dee7defb35',
                      'url': 'https://www.youtube.com/watch?v=8-bKjcADU18',
                      'type': 2,
                      'sortOrder': 0,
                      'imageUrl': null,
                    },
                  ],
                },
              },
              {
                'itemId': 'partner-005',
                'itemType': 2,
                'appFeature': 3,
                'name': 'WeCare247',
                'isUnlimited': 0,
                'quantity': 1,
                'quantityUsed': 0,
                'discountValue': 5,
                'discountType': 0,
                'benefitType': {
                  'id': 'e6f9a3bc-2fb9-4c75-0ca4-08dedbdbb8bf',
                  'title': 'WeCare247',
                  'contentType': 2,
                  'contentValue': '',
                  'description':
                      'WeCare247 là đơn vị cung cấp dịch vụ chăm sóc sức khỏe cá nhân tại nhà và tại bệnh viện, thành lập năm 2017 với sứ mệnh nâng cao chất lượng sống cho các gia đình Việt Nam.\n Đội ngũ chăm sóc viên và điều dưỡng được đào tạo bài bản, làm việc 24/7, hỗ trợ người cao tuổi và người bệnh trong sinh hoạt, theo dõi sức khỏe và phối hợp cùng bác sĩ điều trị.',
                  'location':
                      'Dịch vụ tại nhà & bệnh viện tại TP.HCM, mạng lưới hợp tác nhiều bệnh viện tuyến đầu',
                  'openTime':
                      'Hoạt động linh hoạt 24/7, kể cả Lễ Tết (đặt lịch trước để sắp xếp chăm sóc viên)',
                  'status': 1,
                  'tag': null,
                  'hasVoucher': 1,
                  'voucherName': 'GIẢM 10%',
                  'voucherSubName': 'Gói dịch vụ tại WeCare247',
                  'voucherCode': 'CFY-CORP-2024',
                  'voucherValue': 'Giảm 10% trên tổng hoá đơn',
                  'applicableTo': 'Nhân viên Axon',
                  'validUntil': validUntilWeCareExpired,
                  'applicableLocation': 'Tất cả cơ sở',
                  'order': 1,
                  'bundleTagId': '76771441-2222-44e7-1909-08dedbdbb239',
                  'media': [
                    {
                      'id': '21e703a4-60d8-452f-c851-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'e6f9a3bc-2fb9-4c75-0ca4-08dedbdbb8bf',
                      'imageId': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 0,
                      'imageUrl': {
                        'id': '1d0fdf24-5e06-4ca9-f212-08dee7defb35',
                        'url': 'lib/res/drawables/wecare_image_title.jpg',
                      },
                    },
                    {
                      'id': '4025aa68-d124-4ba7-c84f-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'e6f9a3bc-2fb9-4c75-0ca4-08dedbdbb8bf',
                      'imageId': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 1,
                      'imageUrl': {
                        'id': '4d15d771-3ecb-4c5e-f213-08dee7defb35',
                        'url': 'lib/res/drawables/wecare_sub_image_1.jpg',
                      },
                    },
                    {
                      'id': '809c4faf-aff7-44f4-c850-08dee7df0a19',
                      'bundleBenefitTypeId':
                          'e6f9a3bc-2fb9-4c75-0ca4-08dedbdbb8bf',
                      'imageId': '958c06ee-afad-4d91-f214-08dee7defb35',
                      'url': null,
                      'type': 1,
                      'sortOrder': 2,
                      'imageUrl': {
                        'id': '958c06ee-afad-4d91-f214-08dee7defb35',
                        'url': 'lib/res/drawables/wecare_sub_image_2.jpg',
                      },
                    },
                  ],
                },
              },
            ],
          },
        ],
      },
    });
  }
}
