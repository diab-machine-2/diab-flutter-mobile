class DsmesClinicRatingResponse {
  final int code;
  final DsmesClinicRatingData data;

  DsmesClinicRatingResponse({
    required this.code,
    required this.data,
  });

  factory DsmesClinicRatingResponse.fromJson(Map<String, dynamic> json) {
    return DsmesClinicRatingResponse(
      code: json['code'] ?? 0,
      data: DsmesClinicRatingData.fromJson(json['data'] ?? {}),
    );
  }
}

class DsmesClinicRatingData {
  final double totalRate;
  final List<ClinicReview> topReview;
  final List<ClinicReview> normalReview;
  final int totalBooking;
  final Map<String, int> totalRateStar;
  final int totalStar;

  DsmesClinicRatingData({
    required this.totalRate,
    required this.topReview,
    required this.normalReview,
    required this.totalBooking,
    required this.totalRateStar,
    required this.totalStar,
  });

  factory DsmesClinicRatingData.fromJson(Map<String, dynamic> json) {
    return DsmesClinicRatingData(
      totalRate: json['total_rate'] == null
          ? 0.0
          : json['total_rate'] is int
              ? (json['total_rate'] as int).toDouble()
              : (json['total_rate'] as double),
      topReview: (json['top_review'] as List?)
              ?.map((e) => ClinicReview.fromJson(e))
              .toList() ??
          [],
      normalReview: (json['normal_review'] as List?)
              ?.map((e) => ClinicReview.fromJson(e))
              .toList() ??
          [],
      totalBooking: json['total_booking'] ?? 0,
      totalRateStar: Map<String, int>.from(json['total_rate_star'] ?? {}),
      totalStar: json['total_star'] ?? 0,
    );
  }
}

class ClinicReview {
  final int id;
  final int doctorId;
  final int patientId;
  final int clinicId;
  final int appointmentId;
  final List<String> suggestion;
  final String title;
  final String comment;
  final String anonymous;
  final String rating;
  final int like;
  final int unlike;
  final String createdAt;
  final int active;
  final int sortComment;
  final String ratingName;
  final ReviewUser patient;
  final ReviewClinic clinic;
  final ReviewAppointment appointment;
  final int isLiked;
  final String clinicName;
  final String friendlinessStar;
  final String timelinessStar;
  final String procedure;
  final String review;
  final String writerName;

  ClinicReview({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.clinicId,
    required this.appointmentId,
    required this.suggestion,
    required this.title,
    required this.comment,
    required this.anonymous,
    required this.rating,
    required this.like,
    required this.unlike,
    required this.createdAt,
    required this.active,
    required this.sortComment,
    required this.ratingName,
    required this.patient,
    required this.clinic,
    required this.appointment,
    required this.isLiked,
    required this.clinicName,
    required this.friendlinessStar,
    required this.timelinessStar,
    required this.procedure,
    required this.review,
    required this.writerName,
  });

  factory ClinicReview.fromJson(Map<String, dynamic> json) {
    return ClinicReview(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      clinicId: json['clinic_id'] ?? 0,
      appointmentId: json['appointment_id'] ?? 0,
      suggestion: List<String>.from(json['suggestion'] ?? []),
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      anonymous: json['anonymous'] ?? '',
      rating: json['rating'] ?? '',
      like: json['like'] ?? 0,
      unlike: json['unlike'] ?? 0,
      createdAt: json['created_at'] ?? '',
      active: json['active'] ?? 0,
      sortComment: json['sort_comment'] ?? 0,
      ratingName: json['rating_name'] ?? '',
      patient: (json['patient'] is! List)
          ? ReviewUser.fromJson(json['patient'] ?? {})
          : ReviewUser.fromJson({}),
      clinic: (json['clinic'] is! List)
          ? ReviewClinic.fromJson(json['clinic'] ?? {})
          : ReviewClinic.fromJson({}),
      appointment: ReviewAppointment.fromJson(json['appointment'] ?? {}),
      isLiked: json['is_liked'] ?? 0,
      clinicName: json['clinic_name'] ?? '',
      friendlinessStar: json['friendliness_star'] ?? '',
      timelinessStar: json['timeliness_star'] ?? '',
      procedure: json['procedure'] ?? '',
      review: json['review'] ?? '',
      writerName: json['writer_name'] ?? '',
    );
  }

  static String getSuggestionText(String suggestionKey, String locale) {
    final Map<String, Map<String, String>> suggestions = {
      'vi': {
        'friendly': 'Đón tiếp chu đáo',
        'speedy_appointment': 'Thủ tục khám nhanh chóng',
        'clear_explanation': 'Tư vấn rất chi tiết',
        'professional_doctor': 'Bác sĩ rất chuyên nghiệp',
        'reasonable_price': 'Chi phí khám hợp lý',
        'modern_equipment': 'Trang thiết bị hiện đại',
      },
      'en': {
        'friendly': 'Friendly staff',
        'speedy_appointment': 'Speedy Appointment',
        'clear_explanation': 'Clear explanation',
        'professional_doctor': 'Professional doctor',
        'reasonable_price': 'Reasonable price',
        'modern_equipment': 'Modern equipment',
      }
    };

    return suggestions[locale]?[suggestionKey] ?? suggestionKey;
  }
}

class ReviewUser {
  final int id;
  final String displayName;

  ReviewUser({
    required this.id,
    required this.displayName,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] is String ? 0 : (json['id'] ?? 0),
      displayName: json['display_name'] ?? '',
    );
  }
}

class ReviewClinic {
  final int id;
  final String name;

  ReviewClinic({
    required this.id,
    required this.name,
  });

  factory ReviewClinic.fromJson(Map<String, dynamic> json) {
    return ReviewClinic(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ReviewAppointment {
  final int id;
  final String displayName;

  ReviewAppointment({
    required this.id,
    required this.displayName,
  });

  factory ReviewAppointment.fromJson(Map<String, dynamic> json) {
    return ReviewAppointment(
      id: json['id'] ?? 0,
      displayName: json['display_name'] ?? '',
    );
  }
}
