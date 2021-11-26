class ScheduleReminderModel {
  String? id;
  int? remindType;
  List<int>? days;
  bool? isWakeUp;
  bool? isBreakfast;
  bool? isLunch;
  bool? isDinner;
  bool? isSleeping;
  String? name;
  String? content;
  bool? isActive;

  ScheduleReminderModel(
      { this.id,
        this.remindType = 1,
        this.days,
        this.isWakeUp = false,
        this.isBreakfast = false,
        this.isLunch = false,
        this.isDinner = false,
        this.isSleeping = false,
        this.name = '',
        this.content = '',
        this.isActive = true});

  ScheduleReminderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    remindType = json['remindType'];
    days = json['days'].cast<int>();
    isWakeUp = json['isWakeUp'];
    isBreakfast = json['isBreakfast'];
    isLunch = json['isLunch'];
    isDinner = json['isDinner'];
    isSleeping = json['isSleeping'];
    name = json['name'];
    content = json['content'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['remindType'] = this.remindType;
    data['days'] = this.days;
    data['isWakeUp'] = this.isWakeUp;
    data['isBreakfast'] = this.isBreakfast;
    data['isLunch'] = this.isLunch;
    data['isDinner'] = this.isDinner;
    data['isSleeping'] = this.isSleeping;
    data['name'] = this.name;
    data['content'] = this.content;
    data['isActive'] = this.isActive;
    return data;
  }

  static List<ScheduleReminderModel> toList(List<dynamic> items) {
    return items.map((item) => ScheduleReminderModel.fromJson(item)).toList();
  }
}
