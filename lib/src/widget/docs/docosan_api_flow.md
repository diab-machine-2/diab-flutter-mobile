# Docosan API Flow Documentation

> Base URL: `https://api.docosan.com/` (production) / `https://api.staging.docosan.com/` (staging)
>
> Auth: `Bearer <token>` (in `Authorization` header) + `x-api-key` header (organization key)
>
> Content-Type: `application/json; charset=UTF-8`

---

## I. Docosan API Reference (All Endpoints)

### 1. User Registration & Authentication

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 1 | `GET` | `api/is-exist-user?phone_number=<phone>` | Check if Docosan user exists for given phone | `AppRepository.isExistDocosanUser()` — direct HTTP |
| 2 | `POST` | `api/register-internal` | Register a new Docosan user (patient), returns `accessToken` | `AppRepository.registerDocosanUser()` — direct HTTP |

**Request Body (register-internal) — `application/x-www-form-urlencoded`:**
```
email, type, display_name, gender, language, is_get_cares_order_info, phone_number
```

**Response (register-internal):**
```json
{
  "data": {
    "accessToken": "...",
    "language": "vi"
  }
}
```

> **Note:** On success, `accessToken` is saved into `AppSettings` preferences and used for all subsequent Docosan API calls.

---

### 2. Appointment Listing & Detail

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 3 | `GET` | `api/patients/my-appointment-partner?page=<page>` | Get paginated list of DSMES appointments | `DsmesAppointmentCubit.getDsmesAppointmentList()` |
| 4 | `GET` | `api/patients/my-appointment-detail?appointment_id=<id>` | Get single appointment detail (includes `paid_services`, `teleMedicine` etc.) | `DsmesAppointmentCubit.getDsmesAppointmentDetail()` |

---

### 3. Clinic Discovery & Detail

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 5 | `GET` | `api/clinics/profile-clinic-diab?type=<type>` | Get clinic list. `type` can be `"online"` for telemedicine clinics, or omitted for all | `DsmesAppointmentCubit.getClinicList()` |
| 6 | `GET` | `api/clinics/profile?id=<id>` | Get clinic detail with full info (services, categories, schedules, etc.) | `DsmesAppointmentCubit.getClinicDetail()` |
| 7 | `GET` | `api/clinics/profile-clinic-diab-schedule` | Get diabetes clinic schedule (merged slots) | `DsmesAppointmentCubit.getDiabClinicsSchedule()` |
| 8 | `GET` | `api/diseases-configuration?language=vi&version=<v>&top=<n>` | Get specialty/disease list for clinic filtering | `DsmesAppointmentCubit.getCLinicSpecialtyList()` |

---

### 4. Provider Search (Clinics & Doctors)

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 9 | `POST` | `api/seo-static-link-multi` | Search/filter clinic providers with pagination + filters | `AppRepository.searchListBookingClinic()` |
| 10 | `POST` | `api/partner-get-doctor-list` | Search/filter doctor providers with pagination + filters | `AppRepository.searchListBookingDoctor()` |
| 11 | `GET` | `api/partner-doctor?id=<id>` | Get doctor detail | `DsmesAppointmentCubit.getDoctorDetail()` |

**Request Body (seo-static-link-multi):**
```json
{
  "type": "location",
  "language": "vi",
  "url_keywords": ["hcm", "hanoi"],      // City/district slugs
  "specialty": "17",                      // Specialty ID
  "name": "",
  "keyword": "",
  "page": "1",
  "sv_available": ["telemedicine"],       // Service type filter
  "sell_type": "",
  "parent_term": "",
  "lng": "106.123",
  "lat": "10.456",
  "kind": "clinic",                       // "clinic" or "doctor"
  "timeframes": ["cuoituan"],             // Weekend, weekday, after-hours
  "clinic_types": ["clinic", "hospital"], // Clinic type filter
  "is_filter_distance": 1
}
```

---

### 5. Booking Creation

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 12 | `POST` | `api/doctors/patient-appointments-partner` | Create **offline (at-clinic)** booking | `AppRepository.createDsmesOfflineBooking()` |
| 13 | `POST` | `api/payment/create-order-partner` | Create **online (telemedicine)** booking with payment order | `AppRepository.createDsmesOnlineBooking()` |

**Request Body (shared `CreateDsmesBookingRequest`):**
```json
{
  "start_time": "2026-06-25 14:00:00",
  "end_time": "2026-06-25 15:00:00",
  "clinic_id": 123,
  "doctor_id": 0,
  "patient_phone_number": "84902900158",
  "patient_name": "Nguyen Van A",
  "birthday": "1990-01-01",
  "patient_gender": 1,
  "patient_email": "a@example.com",
  "extra_info": "",
  "booking_for_clinic": 1,           // 1=clinic, 0=doctor
  "language": "vi",
  "symptom": "Đau đầu",
  "symptom_attachment": ["url1"],
  "payment_info": {
    "payment_type": null,
    "services": [{"id": 45, "quantity": 1}]
  },
  "isTest": true,                    // for examination-at-home
  "homeAddress": "123 Đường ABC"     // for examination-at-home
}
```

---

### 6. Appointment Management

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 14 | `POST` | `api/patients/cancel-appointment` | Cancel an existing appointment | `AppRepository.cancelDsmesBooking()` |
| 15 | `POST` | `api/patients/reschedule-apt` | Reschedule an appointment (change start time) | `AppRepository.rescheduleDsmesBooking()` |

**Cancel Request Body:**
```json
{"id": 12345, "reason": ["Lý do hủy"]}
```

**Reschedule Request Body:**
```json
{
  "appointment_id": {"id": 12345},
  "start_time": "2026-06-26 10:00:00"
}
```

---

### 7. Ratings & Reviews

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 16 | `POST` | `api/clinics/rate?clinic_id=<id>` | Get clinic ratings/reviews | `DsmesAppointmentCubit.getClinicRate()` |
| 17 | `POST` | `api/doctors/rate?doctor_id=<id>` | Get doctor ratings/reviews | `DsmesAppointmentCubit.getDoctorRate()` |

---

### 8. Symptom Image Upload (Non-Docosan — Medical App Backend)

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 18 | `POST` | `api/appointment/upload-symptom` | Upload symptom attachment image (multipart) | `DsmesAppointmentCubit.uploadSymptomImage()` via `FetchClient().postHttp3()` |

---

### 9. Payment (VNPAY — Medical App Backend)

| # | Method | Endpoint | Description | Called From |
|---|---|---|---|---|
| 19 | `POST` | `/App/PaymentMethodVnpay` | Save VNPAY transaction info | `AppRepository.saveVnpayTransactionInfo()` via `FetchClient().postHttp()` |
| 20 | `PUT` | `/App/PaymentMethodVnpay/update-by-refcode?appointmentId=<id>&refCode=<txnRef>` | Update appointment with VNPAY transaction reference | `AppRepository.updateVnpayTransactionInfo()` via `FetchClient().putData()` |
| 21 | `GET` | `api/payment/vnpay-transaction-info?txnRef=<ref>` | Get VNPAY transaction details | `AppRepository.getPaymentVnpayTransactionInfo()` via `appClient` |

---

## II. User Registration & Entry Flow

Before any booking, the user must be registered on Docosan:

```
[START] initDsmesBooking()
  │
  ├─ isExistDocosanUser(phoneNumber)
  │    └─ GET api/is-exist-user?phone_number=<phone>
  │         ├─ if NOT exists → return false → flow stops
  │         └─ if exists → return true → continue
  │
  ├─ registerDocosanUser(phoneNumber)
  │    └─ POST api/register-internal
  │         Body: { email, type: "patient", display_name, gender, language, ... }
  │         └─ On success: saves accessToken → AppSettings
  │
  └─ fetchDsmesAppointmentList(page: 1)
       └─ GET api/patients/my-appointment-partner?page=1
```

> ⚠️ `registerDocosanUser` is called **every time** the booking center opens (not just first-time), because it both creates the user AND refreshes the access token.

---

## III. Telemedicine (Booking Online) Flow

Booking online = remote consultation via Zoom/web app, `DsmesAppointmentMode.telemedicine`.

```
[Main Page] User taps "Tư vấn từ xa" (Online Consulting card)
  │
  │  ──── DsmesAppointmentPage._navigateToSelectService() ────
  │
  ├─ Step 1: getClinicList(type: 'online')
  │    └─ GET api/clinics/profile-clinic-diab?type=online
  │
  ├─ Step 2: getClinicDetail(id: priorityClinic.id)
  │    └─ GET api/clinics/profile?id=<id>
  │    └─ Response includes clinic info + serviceList.categories
  │
  ├─ Step 3: initCreateDsmesBookingRequest(locale)
  │    └─ Builds CreateDsmesBookingRequest with user info (name, phone, gender, etc.)
  │
  ├─ [UI] Navigate to DsmesSelectServicePage (Chọn dịch vụ)
  │    └─ User selects 1-2 services from the clinic's service list
  │    └─ CUBIT: updateCreateDsmesBookingRequestServiceList(services)
  │         └─ Sets paymentInfo.services in the booking request
  │
  ├─ [UI] Navigate to DsmesCalendarSection (Chọn ngày giờ)
  │    └─ Optional: getDiabClinicsSchedule()
  │    └─ GET api/clinics/profile-clinic-diab-schedule
  │    └─ User picks date/time
  │    └─ CUBIT: updateCreateDsmesBookingRequestTime(startTime, endTime)
  │
  ├─ [UI] Navigate to DsmesConfirmCreateInformation (Xác nhận thông tin)
  │    └─ Optional: uploadSymptomImage() → POST api/appointment/upload-symptom
  │    └─ CUBIT: updateCreateDsmesBookingRequestSymptom(...)
  │    └─ CUBIT: updateCreateDsmesBookingRequestSymptomAttachments(...)
  │    └─ CUBIT: updateCreateDsmesBookingRequestRequesterInfo(name, phone)
  │    └─ CUBIT: updateCreateDsmesBookingRequestHomeExamination(isTest, homeAddress) -- if at-home
  │
  ├─ Step 4: createDsmesBookingOnline()
  │    └─ POST api/payment/create-order-partner
  │    └─ Body: CreateDsmesBookingRequest (full payload)
  │    └─ Response: CreateDsmesOfflineBookingResponse { data: DsmesAppointment }
  │
  ├─ Optional VNPAY Payment Flow (if payment required):
  │    └─ saveVnpayTransactionInfo(request)
  │         └─ POST /App/PaymentMethodVnpay (Medical Backend)
  │    └─ User redirected to VNPAY gateway (external)
  │    └─ On return: updateVnpayTransactionInfo(appointmentId, txnRef)
  │         └─ PUT /App/PaymentMethodVnpay/update-by-refcode?appointmentId=<id>&refCode=<ref>
  │    └─ getPaymentVnpayTransactionInfo(txnRef)
  │         └─ GET api/payment/vnpay-transaction-info?txnRef=<ref>
  │
  └─ [UI] Navigate to DsmesBookingDetail (Chi tiết cuộc hẹn)
       └─ Shows appointment info, telemedicine ID for joining call
       └─ Or navigate to WebViewScreen (Zoom/Join call room)
            └─ NavigatorName.dsmes_booking_online_join_room
```

**Key Files:**
- [dsmes_appointment_cubit.dart](../dsmes_appointment/dsmes_appointment_cubit.dart) — `createDsmesBookingOnline()`
- [dsmes_appointment_page.dart](../dsmes_appointment/dsmes_appointment_page.dart) — `_navigateToSelectService()`
- [dsmes_select_service_page.dart](../dsmes_appointment/pages/dsmes_select_service_page.dart)
- [dsmes_booking_select_datetime.dart](../dsmes_appointment/pages/dsmes_booking_select_datetime.dart)
- [dsmes_confirm_create_information_page.dart](../dsmes_appointment/pages/dsmes_confirm_create_information_page.dart)

---

## IV. Booking Clinic Offline Flow

Booking offline = physical visit to clinic, `DsmesAppointmentMode.atClinic`.

### Path A: From DSMES Appointment Page (Main Booking Center)

```
[Main Page] User taps "Khám tại phòng khám" (Offline Consulting card)
  │
  │  ──── DsmesAppointmentPage._handleOfflineDeeplink() ────
  │
  ├─ Step 1: getClinicList()
  │    └─ GET api/clinics/profile-clinic-diab (no type filter)
  │
  ├─ [UI] Navigate to DsmesBookingOfflinePage (Danh sách phòng khám)
  │    └─ User taps a clinic → getClinicDetail(id)
  │         └─ GET api/clinics/profile?id=<id>
  │    └─ Navigate to DsmesClinicDetailPage (Chi tiết phòng khám)
  │         └─ getClinicRate(id) → POST api/clinics/rate?clinic_id=<id>
  │
  ├─ User taps "Đặt lịch" → initCreateDsmesBookingRequest()
  │
  ├─ [UI] Navigate to DsmesCalendarSection (Chọn ngày giờ)
  │    └─ getDiabClinicsSchedule() → GET api/clinics/profile-clinic-diab-schedule
  │    └─ User picks date/time
  │    └─ CUBIT: updateCreateDsmesBookingRequestTime(startTime, endTime)
  │
  ├─ [UI] Navigate to DsmesSelectServicePage (Chọn dịch vụ)
  │    └─ User selects services
  │    └─ CUBIT: updateCreateDsmesBookingRequestServiceList(services)
  │
  ├─ [UI] Navigate to DsmesConfirmCreateInformation (Xác nhận thông tin)
  │    └─ Optional: uploadSymptomImage()
  │
  ├─ Step 2: createDsmesBooking()
  │    └─ POST api/doctors/patient-appointments-partner
  │    └─ Body: CreateDsmesBookingRequest
  │    └─ Response: CreateDsmesOfflineBookingResponse
  │
  └─ [UI] Navigate to DsmesBookingDetail
```

**Key Files:**
- [dsmes_appointment_page.dart](../dsmes_appointment/dsmes_appointment_page.dart) — `_handleOfflineDeeplink()`
- [dsmes_booking_offline_page.dart](../dsmes_appointment/pages/dsmes_booking_offline_page.dart)
- [dsmes_clinic_detail_page.dart](../dsmes_appointment/pages/dsmes_clinic_detail_page.dart)

---

### Path B: From Booking Clinic Page (Specialty-based, `BookingClinicPage`)

```
[BookingClinicPage] Shows specialty grid (Tiểu đường, Cao huyết áp, ...)
  │
  ├─ User taps a specialty card:
  │    ├─ If "Bệnh khác" → getCLinicSpecialtyList()
  │    │    └─ GET api/diseases-configuration?language=vi&version=8.5
  │    │    └─ Navigate to OtherDiseasesPage → user picks a specialty
  │    │         └─ Navigate to BookingClinicProvidersPage(specialtyId)
  │    │
  │    └─ Normal specialty → Navigate directly to BookingClinicProvidersPage(specialtyId)
  │
  ├─ [BookingClinicProvidersPage] Search clinic providers
  │    ├─ initSearchBookingClinicListRequest(specialtyId, lat, lng, kind: 'clinic')
  │    ├─ searchBookingClinicList(request, isRefresh: true)
  │    │    └─ POST api/seo-static-link-multi
  │    │    └─ Filter options (city, type, timeframe, service type) re-call this API
  │    │    └─ Paginated via clinicProviderCurrentPage
  │    │
  │    ├─ User taps a provider → getClinicDetail(id) + getClinicRate(id)
  │    │    └─ GET api/clinics/profile?id=<id>
  │    │    └─ POST api/clinics/rate?clinic_id=<id>
  │    │    └─ Navigate to DsmesClinicDetailPage
  │    │
  │    └─ User taps "Đặt lịch khám"
  │         ├─ getClinicDetail(id) (if not already loaded)
  │         ├─ initCreateDsmesBookingRequest(locale)
  │         │
  │         ├─ [UI] Navigate to DsmesCalendarSection (Chọn ngày giờ)
  │         │
  │         ├─ [UI] Navigate to BookingClinicSelectServicePage (Chọn dịch vụ)
  │         │    └─ User selects services (max 2)
  │         │    └─ CUBIT: updateCreateDsmesBookingRequestServiceList(services)
  │         │
  │         ├─ [UI] Navigate to DsmesConfirmCreateInformation (Xác nhận)
  │         │    └─ Optional: uploadSymptomImage()
  │         │
  │         └─ Create booking (depends on service mode):
  │              ├─ Telemedicine → createDsmesBookingOnline()
  │              │    └─ POST api/payment/create-order-partner
  │              └─ At-Clinic → createDsmesBooking()
  │                   └─ POST api/doctors/patient-appointments-partner
  │
  └─ [UI] Navigate to BookingClinicPaymentPage (if payment needed)
       └─ saveVnpayTransactionInfo → VNPAY → updateVnpayTransactionInfo
```

**Key Files:**
- [booking_clinic_page.dart](../booking_clinic/booking_clinic_page.dart)
- [booking_clinic_provider_page.dart](../booking_clinic/pages/booking_clinic_provider_page.dart)
- [booking_clinic_select_service.dart](../booking_clinic/pages/booking_clinic_select_service.dart)
- [booking_clinic_payment_page.dart](../booking_clinic/pages/booking_clinic_payment_page.dart)
- [other_diseases_page.dart](../booking_clinic/pages/other_diseases_page.dart)

---

## V. Examination Flow (Special)

Two sub-flows when the app opens directly in "examination mode":

### Examination at Home
```
BookingClinicPage(isExamination: true, examinationAtClinic: false)
  ├─ getClinicDetail(id: EXAMINATION_DEFAULT_CLINIC_ID=816)
  ├─ setExaminationData(isExamination, type, location: 'home', smartGoalId)
  ├─ initCreateDsmesBookingRequest(clearExamination: false)
  ├─ [UI] → DsmesCalendarSection
  └─ ... continues as normal booking (telemedicine mode)
```

### Examination at Clinic
```
BookingClinicPage(isExamination: true, examinationAtClinic: true)
  ├─ setExaminationData(isExamination, type, location: 'clinic', smartGoalId)
  ├─ [UI] → BookingClinicProvidersPage(specialtyId: 0, examinationType)
  ├─ Search providers via POST api/seo-static-link-multi
  ├─ User picks clinic → getClinicDetail(id)
  ├─ initCreateDsmesBookingRequest(clearExamination: false)
  ├─ [UI] → DsmesCalendarSection
  ├─ Auto-selects services matching examination type
  ├─ [UI] → DsmesConfirmCreateInformation
  └─ createDsmesBookingOnline() → POST api/payment/create-order-partner
```

---

## VI. Appointment Management Flows

### View Appointment List
```
Pull to refresh / on load
  └─ getDsmesAppointmentList(page, isRefresh)
       └─ GET api/patients/my-appointment-partner?page=<page>
       └─ Response: list filtered/sorted by relevance (upcoming, recent)
```

### View Appointment Detail
```
User taps an appointment card
  ├─ getClinicDetail(id: data.clinicId)
  ├─ getDsmesAppointmentDetail(appointmentId: data.id)
  │    └─ GET api/patients/my-appointment-detail?appointment_id=<id>
  └─ Navigate to DsmesBookingDetail
```

### Cancel Appointment
```
User cancels
  └─ cancelDsmesAppointment(request)
       └─ POST api/patients/cancel-appointment
       Body: { id: <appointmentId>, reason: ["<reason>"] }
```

### Reschedule Appointment
```
User changes date/time
  ├─ Navigate to DsmesCalendarSection(action: 'reschedule')
  ├─ rescheduleDsmesBooking(request)
  │    └─ POST api/patients/reschedule-apt
  │    Body: { appointment_id: { id: <id> }, start_time: "<new_start>" }
  └─ Navigate to DsmesConfirmCreateInformation(action: 'reschedule')
```

---

## VII. Flow Comparison: Telemedicine vs Booking Clinic Offline

| Aspect | Telemedicine (Online) | Booking Clinic (Offline) |
|---|---|---|
| **API endpoint** | `POST api/payment/create-order-partner` | `POST api/doctors/patient-appointments-partner` |
| **Clinic filter** | `getClinicList(type: 'online')` | `getClinicList()` (no filter) |
| **Service type** | `DsmesAppointmentMode.telemedicine` | `DsmesAppointmentMode.atClinic` or `telemedicine` |
| **Entry point** | DsmesAppointmentPage card | DsmesAppointmentPage card OR BookingClinicPage specialty grid |
| **Provider search** | Not used (uses clinic list directly) | **Yes** — `POST api/seo-static-link-multi` with filters |
| **Payment** | `create-order-partner` implies payment order creation | No payment order, but VNPAY can be added |
| **Join call** | Navigate to `WebViewScreen` (telemedicine ID) via Zoom | Not applicable |
| **Doctor booking** | `bookingForClinic: 1` | `bookingForClinic: 1` (clinic) or `0` (doctor) via `updateBookingDoctorInfoCreateRequest()` |

---

## VIII. Directory Structure

```
dsmes_appointment/                 # Main booking center (telemedicine + offline)
├── dsmes_appointment_cubit.dart    # Business logic, all API calls
├── dsmes_appointment_page.dart     # Main page with navigator + routing
├── dsmes_appointment_state.dart    # Bloc states
├── model/
│   ├── dsmes_appointment_model.dart # DsmesAppointment, Doctor, ClinicInfo, TeleMedicine, etc.
│   └── dsmes_clinic_model.dart      # DsmesClinicModel (clinic detail)
├── pages/
│   ├── dsmes_select_service_page.dart      # Service selection
│   ├── dsmes_booking_select_datetime.dart  # Date/time picker
│   ├── dsmes_confirm_create_information_page.dart # Confirmation + symptom
│   ├── dsmes_booking_detail.dart           # Appointment detail
│   ├── dsmes_booking_offline_page.dart     # Offline clinic list
│   ├── dsmes_clinic_detail_page.dart       # Clinic detail view
│   ├── dsmes_appointment_history_page.dart # Past appointments
│   ├── dsmes_booking_online_join_call_page.dart  # WebView/Join call
│   └── dsmes_navigation_mixin.dart         # Navigation helpers
└── widgets/
    ├── dsmes_appointment_item.dart
    ├── dsmes_empty_widget.dart
    └── section_add_symptom.dart

booking_clinic/                    # Specialty-based clinic booking
├── booking_clinic_page.dart       # Main page with specialty grid
├── helper/
│   ├── booking_clinic_helper.dart # Location, city list utilities
│   └── vnpay_payment_service.dart
├── model/
│   ├── booking_clinic_provider_model.dart
│   ├── clinic_specialty_model.dart
│   └── vnpay_model.dart
├── pages/
│   ├── booking_clinic_provider_page.dart    # Clinic list with filters
│   ├── booking_clinic_select_service.dart   # Service selection (for clinic booking)
│   ├── booking_clinic_payment_page.dart     # Payment screen
│   ├── other_diseases_page.dart             # Other specialties picker
│   └── empty_clinic_provider_page.dart
└── widgets/
    └── vnpay_view_widget.dart

model/repository/
└── app_repository.dart            # Mediates all API calls (appClient + docosanClient)

model/docosan_api.dart             # Retrofit interface with all Docosan endpoints
model/service/docosan_client.dart  # Dio client setup for Docosan API (auth interceptors)
```
