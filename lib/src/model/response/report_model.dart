class ReportModel {
  String? id;
  String? reportName;
  String? virtualFilePath;
  String? fileName;
  String? description;
  String? patientId;
  int? createDatetime;
  String? creatorId;
  String? creator;

  ReportModel(
      {this.id,
      this.reportName,
      this.virtualFilePath,
      this.fileName,
      this.description,
      this.patientId,
      this.createDatetime,
      this.creatorId,
      this.creator});

  ReportModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reportName = json['reportName'];
    virtualFilePath = json['virtualFilePath'];
    fileName = json['fileName'];
    description = json['description'];
    patientId = json['patientId'];
    createDatetime = json['createDatetime'];
    creatorId = json['creatorId'];
    creator = json['creator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['reportName'] = this.reportName;
    data['virtualFilePath'] = this.virtualFilePath;
    data['fileName'] = this.fileName;
    data['description'] = this.description;
    data['patientId'] = this.patientId;
    data['createDatetime'] = this.createDatetime;
    data['creatorId'] = this.creatorId;
    data['creator'] = this.creator;
    return data;
  }
}