import 'package:medical/src/model/response/meta.dart';

class GetCustomerReceivesUserResponse {
  Meta? meta;
  List<CustomerReceivesData>? data;

  GetCustomerReceivesUserResponse({this.meta, this.data});

  GetCustomerReceivesUserResponse.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['data'] != null) {
      data = <CustomerReceivesData>[];
      json['data'].forEach((v) {
        data!.add(CustomerReceivesData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerReceivesData {
  String id = '';
  int isDeleted = 0;
  int createDatetime = 0;
  int updateDatetime = 0;
  String creatorId = '';
  String updaterId = '';
  String name = '';
  String phoneNumber = '';
  String birthYear = '';
  String contactSource = '';
  int gender = 0;
  int status = 0;
  bool followOaFlag = false;
  bool joinGroupchatFlag = false;
  bool downloadAppFlag = false;
  bool loginFlag = false;
  bool boardingBookingFlag = false;
  bool boardingTestingFlag = false;
  bool boardingDoneFlag = false;
  bool joinHeathCourseFlag = false;
  String callCount = '';
  String reasonOut = '';
  String diseaseType = '';
  String accountId = '';
  String patientId = '';
  String coachId = '';
  String courseId = '';
  int timeAccepted = 0;
  String courseName = '';
  String startCourse = '';
  String endCourse = '';
  String code = '';
  String packageId = '';
  String dsmesWorkflowProcessId = '';
  bool zaloVerify = false;
  String zaloGroup = '';

  CustomerReceivesData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? '';
    isDeleted = json['isDeleted'] ?? 0;
    createDatetime = json['createDatetime'] ?? 0;
    updateDatetime = json['updateDatetime'] ?? 0;
    creatorId = json['creatorId']?.toString() ?? '';
    updaterId = json['updaterId']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    phoneNumber = json['phoneNumber']?.toString() ?? '';
    birthYear = json['birthYear']?.toString() ?? '';
    contactSource = json['contactSource']?.toString() ?? '';
    gender = json['gender'] ?? 0;
    status = json['status'] ?? 0;
    followOaFlag = json['followOaFlag'] ?? false;
    joinGroupchatFlag = json['joinGroupchatFlag'] ?? false;
    downloadAppFlag = json['downloadAppFlag'] ?? false;
    loginFlag = json['loginFlag'] ?? false;
    boardingBookingFlag = json['boardingBookingFlag'] ?? false;
    boardingTestingFlag = json['boardingTestingFlag'] ?? false;
    boardingDoneFlag = json['boardingDoneFlag'] ?? false;
    joinHeathCourseFlag = json['joinHeathCourseFlag'] ?? false;
    callCount = json['callCount']?.toString() ?? '';
    reasonOut = json['reasonOut']?.toString() ?? '';
    diseaseType = json['diseaseType']?.toString() ?? '';
    accountId = json['accountId']?.toString() ?? '';
    patientId = json['patientId']?.toString() ?? '';
    coachId = json['coachId']?.toString() ?? '';
    courseId = json['courseId']?.toString() ?? '';
    timeAccepted = json['timeAccepted'] ?? 0;
    courseName = json['courseName']?.toString() ?? '';
    startCourse = json['startCourse']?.toString() ?? '';
    endCourse = json['endCourse']?.toString() ?? '';
    code = json['code']?.toString() ?? '';
    packageId = json['packageId']?.toString() ?? '';
    dsmesWorkflowProcessId = json['dsmesWorkflowProcessId']?.toString() ?? '';
    zaloVerify = json['zaloVerify'] ?? false;
    zaloGroup = json['zaloGroup']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['isDeleted'] = isDeleted;
    data['createDatetime'] = createDatetime;
    data['updateDatetime'] = updateDatetime;
    data['creatorId'] = creatorId;
    data['updaterId'] = updaterId;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['birthYear'] = birthYear;
    data['contactSource'] = contactSource;
    data['gender'] = gender;
    data['status'] = status;
    data['followOaFlag'] = followOaFlag;
    data['joinGroupchatFlag'] = joinGroupchatFlag;
    data['downloadAppFlag'] = downloadAppFlag;
    data['loginFlag'] = loginFlag;
    data['boardingBookingFlag'] = boardingBookingFlag;
    data['boardingTestingFlag'] = boardingTestingFlag;
    data['boardingDoneFlag'] = boardingDoneFlag;
    data['joinHeathCourseFlag'] = joinHeathCourseFlag;
    data['callCount'] = callCount;
    data['reasonOut'] = reasonOut;
    data['diseaseType'] = diseaseType;
    data['accountId'] = accountId;
    data['patientId'] = patientId;
    data['coachId'] = coachId;
    data['courseId'] = courseId;
    data['timeAccepted'] = timeAccepted;
    data['courseName'] = courseName;
    data['startCourse'] = startCourse;
    data['endCourse'] = endCourse;
    data['code'] = code;
    data['packageId'] = packageId;
    data['dsmesWorkflowProcessId'] = dsmesWorkflowProcessId;
    data['zaloVerify'] = zaloVerify;
    data['zaloGroup'] = zaloGroup;
    return data;
  }
}
