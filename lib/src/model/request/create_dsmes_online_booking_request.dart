class CreateOnlineDsmesBookingRequest {
  final String startTime;
  final String endTime;
  final String clinicId;
  final String doctorId;
  final String symptom;
  final String patientPhoneNumber;
  final String phoneCode;
  final String patientName;
  final String patientGender;
  final String patientEmail;
  final String extraInfo;
  final String bookingForClinic;
  final String language;
  final String birthday;
  final String address;
  final String idCardNumber;
  final String serviceType;
  final PaymentInfo paymentInfo;

  CreateOnlineDsmesBookingRequest({
    required this.startTime,
    required this.endTime,
    required this.clinicId,
    required this.doctorId,
    required this.symptom,
    required this.patientPhoneNumber,
    required this.phoneCode,
    required this.patientName,
    required this.patientGender,
    required this.patientEmail,
    required this.extraInfo,
    required this.bookingForClinic,
    required this.language,
    required this.birthday,
    this.address = '',
    this.idCardNumber = '',
    this.serviceType = 'online',
    required this.paymentInfo,
  });

  Map<String, dynamic> toJson() => {
    'start_time': startTime,
    'end_time': endTime,
    'clinic_id': clinicId,
    'doctor_id': doctorId,
    'symptom': symptom,
    'patient_phone_number': patientPhoneNumber,
    'phone_code': phoneCode,
    'patient_name': patientName,
    'patient_gender': patientGender,
    'patient_email': patientEmail,
    'extra_info': extraInfo,
    'booking_for_clinic': bookingForClinic,
    'language': language,
    'birthday': birthday,
    'address': address,
    'id_card_number': idCardNumber,
    'service_type': serviceType,
    'payment_info[payment_type]': paymentInfo.paymentType,
    'payment_info[services][]': paymentInfo.services.join(','),
    ...paymentInfo.serviceQuantities.map((key, value) => 
        MapEntry('payment_info[service_quantity][$key]', value.toString())),
  };
}

class PaymentInfo {
  final String paymentType;
  final List<String> services;
  final Map<String, int> serviceQuantities;

  PaymentInfo({
    required this.paymentType,
    required this.services,
    required this.serviceQuantities,
  });
}
