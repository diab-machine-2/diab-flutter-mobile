import 'meta.dart';
import 'survey_data.dart';

/// meta : {"success":true}
/// data : {"id":"5b002e55-639c-4b0c-0ea7-08d9983c72bb","code":"tieuduongquestion4","name":"B? câu h?i ti?u du?ng","description":"Tr? l?i câu h?i liên quan d?n cá nhân","isBeta":false,"questionCount":0,"status":2,"updateDatetime":"10/26/2021 04:52:42","updaterName":null,"updaterImage":null,"sections":[{"id":"c2ed3add-31e2-4239-2ee1-08d9983c72d0","name":"Ph?n 2: Ti?u du?ng c?p 2","order":1,"questions":[{"id":"608f01ff-0bde-4e4b-211a-08d9946a7083","code":null,"name":"Câu h?i s? 92","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"762b477c-4543-44f6-0beb-08d9946a708f","content":"Ðáp án 3","order":0,"point":3,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ecc972cb-79b5-4aec-0bec-08d9946a708f","content":"Ðáp án 4","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]},{"id":"811e61c9-3f87-4349-2761-08d994760864","code":null,"name":"Question 2","order":2,"type":2,"isScore":true,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[{"id":"3493d4c7-611f-45f0-0ce6-08d994760871","content":"123","order":0,"point":8,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ce9aa7b3-e340-4f4a-0ce7-08d994760871","content":"3333","order":1,"point":4,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]}]},{"id":"db2d854a-7c98-4131-2ee0-08d9983c72d0","name":"Ph?n 1: T?ng quan ti?u du?ng","order":0,"questions":[{"id":"1b3e5a4d-1fd0-4dbc-2119-08d9946a7083","code":null,"name":"Câu h?i s? 9.1","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"3a1bad82-bf21-4d54-0be9-08d9946a708f","content":"Ðáp án 1","order":0,"point":7,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"ec06dbe9-ef09-4b23-0bea-08d9946a708f","content":"Ðáp án 2","order":1,"point":9,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]},{"id":"32396f3a-dfef-44e7-622e-08d98882d94e","code":null,"name":"Câu hỏi 1","order":1,"type":1,"isScore":false,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[]},{"id":"46b456b4-4b8c-4dd8-3eba-08d993a9e5f5","code":null,"name":"Câu h?i s? 3 updated","order":1,"type":1,"isScore":true,"isRelatedQuestions":true,"isRelatedPatients":true,"answers":[{"id":"4928fed6-0ace-4cb6-1680-08d993aa066e","content":"Ðáp án 1 updated","order":0,"point":2,"rangeBegin":0,"rangeEnd":0,"titleBegin":"string","titleEnd":"string"},{"id":"85fcbbb7-a254-48e3-1681-08d993aa066e","content":"Ðáp án 2 updated","order":1,"point":2,"rangeBegin":0,"rangeEnd":0,"titleBegin":"string","titleEnd":"string"}]},{"id":"5a380642-2058-47d5-31af-08d99444dfde","code":null,"name":"Question 1","order":1,"type":2,"isScore":true,"isRelatedQuestions":false,"isRelatedPatients":false,"answers":[{"id":"49ccada5-d940-4161-76f5-08d9945e4f10","content":"test 2","order":0,"point":6,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null},{"id":"821ed2da-6cfc-4342-76f6-08d9945e4f10","content":"test","order":1,"point":5,"rangeBegin":0,"rangeEnd":0,"titleBegin":null,"titleEnd":null}]}]}]}

class DetailSurveyResponse {
  DetailSurveyResponse({
      Meta? meta,
    SurveyData? data,}){
    _meta = meta;
    _data = data;
}

  DetailSurveyResponse.fromJson(dynamic json) {
    _meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    _data = json['data'] != null ? SurveyData.fromJson(json['data']) : null;
  }
  Meta? _meta;
  SurveyData? _data;

  Meta? get meta => _meta;
  SurveyData? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_meta != null) {
      map['meta'] = _meta?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

