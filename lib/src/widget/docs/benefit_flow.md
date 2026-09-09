# Tài liệu luồng Benefit Bundle

> Endpoint: `GET App/UserBundleOrders/my-benefit` (Retrofit method `AppApi.getMyBenefit()` trong `app_api.dart`)
>
> Repo: `AppRepository.getMyBenefit()` trong `app_repository.dart` — hiện đang bị ép dùng `MyBenefitMock.response` qua flag `_useMyBenefitMock = true` trong lúc UI còn đang kiểm thử với dữ liệu mock; chuyển thành `false` khi backend thật đã sẵn sàng.
>
> Model: `lib/src/model/response/my_benefit_response.dart` (viết tay, không dùng `json_serializable` — không cần chạy codegen khi thêm field mới).
>
> Mock: `lib/src/widget/benefit/my_benefit_mock.dart`.

---

## I. Cấu trúc dữ liệu

```
MyBenefitResponse
└── meta: Meta
└── data: MyBenefitData
    ├── id, name, status, remainingDays, startDate, endDate
    ├── totalItems, usedItems, completionPercent, partnerHotline
    └── sections: List<MyBenefitSection>
        ├── tagName
        └── items: List<MyBenefitItem>
            ├── itemId, itemType, appFeature, name
            ├── category, reportType
            ├── specialtyId, specialtyName, clinicId       // item booking
            ├── isUnlimited, quantity, quantityUsed
            ├── discountValue, discountType
            ├── totalWeek, currentWeek, servicePackageId   // chỉ item dsp
            └── benefitType: BenefitType?                  // chỉ item partnerIntro
                ├── id, title, contentType, description
                ├── status (1 = active, 0 = inactive)
                ├── hasVoucher (1/0), voucherName, voucherSubName, voucherCode, voucherValue
                ├── applicableTo, applicableLocation, validUntil (unix seconds)
                ├── location, openTime, order, bundleTagId, tag
                └── media: List<BenefitMedia>
                    ├── id, bundleBenefitTypeId, imageId, url
                    ├── type   // xem chi tiết ý nghĩa ở mục III
                    ├── sortOrder
                    └── imageUrl: { id, url }
```

`MyBenefitSection.visibleItems` là getter lọc `items` chỉ giữ lại những item mà `bundleItemType` resolve được (khác `null`). Luôn duyệt qua getter này thay vì `items` gốc — section chỉ toàn item bị "ignore" sẽ bị `benefit_introduce_bundle_page.dart` bỏ qua hoàn toàn.

---

## II. Rule `itemType` + `appFeature` → `BenefitBundleItemType`

`BenefitBundleItemType.resolve({itemType, appFeature})` (trong `my_benefit_response.dart`) là nguồn duy nhất quyết định loại item. `MyBenefitItem.bundleItemType` gọi hàm này và trả về `null` nếu không map được — mọi nơi tiêu thụ dữ liệu phải coi `null` là "không hiển thị item này".

| `itemType` | `appFeature` | Kết quả `BenefitBundleItemType` | Ghi chú |
|---|---|---|---|
| `0` | bất kỳ | `null` (bị ignore) | Không bao giờ hiển thị trong danh sách benefit. |
| `1` | (không xét) | `dsp` | `appFeature` không có ý nghĩa với dsp (thường là `0`). Đi kèm `totalWeek` / `currentWeek` / `servicePackageId`. |
| `2` | `1` | `booking` | Đặt khám từ xa (telemedicine). |
| `2` | `2` | `booking` | Đặt khám tại phòng khám (at-clinic). Đi kèm `specialtyId` / `specialtyName` / `clinicId`. |
| `2` | `3` | `partnerIntro` | Đi kèm `benefitType`. |
| `2` | `4` | `report` | Đi kèm `reportType`. |
| `2` | `5` | `medicinePurchase` | |
| `2` | `6` | `labTest` | |
| `2` | giá trị khác | `null` (bị ignore) | |

`MyBenefitItem.bookingType` là giá trị **tự suy ra** từ `itemType`/`appFeature`, không phải field API trả về trên wire:
```dart
if (itemType == 2 && appFeature == 1) return 'telemedicine';
if (itemType == 2 && appFeature == 2) return 'at_clinic';
return null;
```

Với `booking` (`appFeature == 2`, tại phòng khám), nếu item có sẵn cả `specialtyId` **và** `clinicId`, luồng đặt lịch sẽ bỏ qua bước chọn chuyên khoa/chọn phòng khám và đi thẳng tới màn lịch hẹn (`BenefitSpecialtyPage._onSelectAtClinicPreselected`, tương tự cơ chế auto-pick sẵn có của telemedicine).

---

## III. Ý nghĩa `media.type`

`media.type` chỉ có ý nghĩa trong phạm vi `benefitType.media` (danh sách media của item `partnerIntro`), dùng bởi `benefit_partner_intro_page.dart`:

| `media.type` | Ý nghĩa | Được dùng khi nào |
|---|---|---|
| `1` | Ảnh banner/gallery | Luôn được xét bất kể `hasVoucher`. Trong tập `type == 1`, ảnh có `sortOrder` **nhỏ nhất** là ảnh cover (banner đầu trang); các ảnh còn lại (sắp xếp tăng dần theo `sortOrder`) tạo thành gallery cuộn ngang, bấm vào ảnh nào sẽ mở xem toàn màn hình bắt đầu từ ảnh đó. |
| `2` | Video quảng cáo (chứa `url` phát trực tiếp) | Chỉ được xét khi `hasVoucher != 1` **và** không có media `type == 4`. Media đầu tiên khớp điều kiện được phát bằng `VideoWidget`. |
| `4` | Ảnh quảng cáo thay thế voucher | Chỉ được xét khi `hasVoucher != 1`. Nếu có, ưu tiên hiển thị ảnh này (trước cả video `type == 2`). |

Rule chọn nội dung hiển thị bên dưới phần gallery (`_buildBenefitContentSection`), theo thứ tự ưu tiên:
1. `hasVoucher == 1` → hiển thị thẻ voucher (không xét media `type == 2`/`4` nữa).
2. Ngược lại, nếu có media `type == 4` → hiển thị ảnh đó.
3. Ngược lại, nếu có media `type == 2` có `url` khác rỗng → phát video.
4. Không rơi vào trường hợp nào ở trên → không hiển thị gì.

---

## IV. Vài lưu ý xử lý khác (không liên quan tới rule itemType/media.type)

- `BenefitType.description` đôi khi chứa chuỗi ký tự `\n` dạng literal (dấu gạch chéo ngược + chữ n) thay vì ký tự xuống dòng thật — cần `.replaceAll('\\n', '\n')` trước khi hiển thị (đã áp dụng ở `benefit_partner_intro_page.dart`, cùng cách xử lý với `csv_asset_loader.dart`).
- Trang "Voucher của tôi" (`benefit_my_voucher_page.dart`) chỉ lấy các item `partnerIntro`, và lọc bỏ thêm những item có `benefitType.validUntil` đã ở quá khứ (item không có `validUntil` thì luôn được giữ vì không có hạn dùng).
- Màn "Tại nhà" ở Home (`home_benefit.dart`) không lấy từ bundle mà dựng một `MyBenefitItem` từ JSON lưu trong Firebase Remote Config, key `BENEFIT_AT_HOME_INFO` — JSON đó phải có hình dạng giống một item `partnerIntro` thật (`itemType: 2, appFeature: 3, benefitType: {...}`).

---

## V. Mock data

`MyBenefitMock.response` (`lib/src/widget/benefit/my_benefit_mock.dart`) mô phỏng lại đúng cấu trúc một payload thật từ môi trường dev (tên field, `sortOrder`/`type` của media, các giá trị `category`/`appFeature`/`reportType`/`specialtyId`/`clinicId`/`servicePackageId`/`totalWeek`), chỉ khác 2 điểm:

1. URL ảnh remote (`https://api.dev.diab.vn/App/Image/...`) được thay bằng asset local `lib/res/drawables/*.jpg` để chạy được offline.
2. `benefitType.validUntil` được tính tương đối theo `DateTime.now()` (ví dụ `now.add(const Duration(days: 200))`) thay vì dùng epoch cố định từ payload mẫu, để voucher không tự nhiên "hết hạn" chỉ vì thời gian trôi qua kể từ lúc lấy mẫu.
