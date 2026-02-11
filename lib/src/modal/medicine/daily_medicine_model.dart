class DailyMedicineModel {
  final String id;
  final String accountId;
  final String name;
  final int type;
  final int appointmentDate;
  final String? targetSchedulerId;
  final int? dayInAgenda;
  final int? dayInPackage;
  final int? weekInAgenda;
  final String? packageAccountTransactionId;
  final int? weekInPackage;
  final int executeType;
  final int executeDayTimes;
  final int actualExecuteDayTimes;
  final int? completedDate;
  final String? surveyId;
  final String? lessonId;
  final String? exerciseMovementId;
  final String? calendarId;
  final String? prescriptionId;
  final String? medicationId;
  final String? description;
  final String? data;
  final int state;
  final String? targetScheduler;
  final String? exerciseMovement;
  final String? lesson;
  final String? survey;
  final String? calendar;
  final String prescriptionName;
  final int moment;
  final double dosage;
  final String dosageUnit;
  final String? timeSchedule;

  DailyMedicineModel({
    required this.id,
    required this.accountId,
    required this.name,
    required this.type,
    required this.appointmentDate,
    this.targetSchedulerId,
    this.dayInAgenda,
    this.dayInPackage,
    this.weekInAgenda,
    this.packageAccountTransactionId,
    this.weekInPackage,
    required this.executeType,
    required this.executeDayTimes,
    required this.actualExecuteDayTimes,
    this.completedDate,
    this.surveyId,
    this.lessonId,
    this.exerciseMovementId,
    this.calendarId,
    this.prescriptionId,
    this.medicationId,
    this.description,
    this.data,
    required this.state,
    this.targetScheduler,
    this.exerciseMovement,
    this.lesson,
    this.survey,
    this.calendar,
    required this.prescriptionName,
    required this.moment,
    required this.dosage,
    required this.dosageUnit,
    this.timeSchedule,
  });

  factory DailyMedicineModel.fromJson(Map<String, dynamic> json) {
    return DailyMedicineModel(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 0,
      appointmentDate: json['appointmentDate'] ?? 0,
      targetSchedulerId: json['targetSchedulerId'],
      dayInAgenda: json['dayInAgenda'],
      dayInPackage: json['dayInPackage'],
      weekInAgenda: json['weekInAgenda'],
      packageAccountTransactionId: json['packageAccountTransactionId'],
      weekInPackage: json['weekInPackage'],
      executeType: json['executeType'] ?? 0,
      executeDayTimes: json['executeDayTimes'] ?? 0,
      actualExecuteDayTimes: json['actualExecuteDayTimes'] ?? 0,
      completedDate: json['completedDate'],
      surveyId: json['surveyId'],
      lessonId: json['lessonId'],
      exerciseMovementId: json['exerciseMovementId'],
      calendarId: json['calendarId'],
      prescriptionId: json['prescriptionId'],
      medicationId: json['medicationId'],
      description: json['description'],
      data: json['data'],
      state: json['state'] ?? 0,
      targetScheduler: json['targetScheduler'],
      exerciseMovement: json['exerciseMovement'],
      lesson: json['lesson'],
      survey: json['survey'],
      calendar: json['calendar'],
      prescriptionName: json['prescriptionName'] ?? (json['medicationInfo'] as Map<String, dynamic>?)?['prescriptionName']?.toString() ?? '',
      moment: json['moment'] ?? (json['medicationInfo'] as Map<String, dynamic>?)?['moment'] ?? 0,
      dosage: (json['dosage'] as num?)?.toDouble() ?? ((json['medicationInfo'] as Map<String, dynamic>?)?['dosage'] as num?)?.toDouble() ?? 0.0,
      dosageUnit: json['dosageUnit'] ?? (json['medicationInfo'] as Map<String, dynamic>?)?['dosageUnit']?.toString() ?? '',
      timeSchedule: json['timeSchedule']?.toString() ?? (json['medicationInfo'] as Map<String, dynamic>?)?['timeSchedule']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'name': name,
      'type': type,
      'appointmentDate': appointmentDate,
      'targetSchedulerId': targetSchedulerId,
      'dayInAgenda': dayInAgenda,
      'dayInPackage': dayInPackage,
      'weekInAgenda': weekInAgenda,
      'packageAccountTransactionId': packageAccountTransactionId,
      'weekInPackage': weekInPackage,
      'executeType': executeType,
      'executeDayTimes': executeDayTimes,
      'actualExecuteDayTimes': actualExecuteDayTimes,
      'completedDate': completedDate,
      'surveyId': surveyId,
      'lessonId': lessonId,
      'exerciseMovementId': exerciseMovementId,
      'calendarId': calendarId,
      'prescriptionId': prescriptionId,
      'medicationId': medicationId,
      'description': description,
      'data': data,
      'state': state,
      'targetScheduler': targetScheduler,
      'exerciseMovement': exerciseMovement,
      'lesson': lesson,
      'survey': survey,
      'calendar': calendar,
      'prescriptionName': prescriptionName,
      'moment': moment,
      'dosage': dosage,
      'dosageUnit': dosageUnit,
      'timeSchedule': timeSchedule,
    };
  }
}