import 'package:flutter_test/flutter_test.dart';
import 'package:medical/src/model/response/lesson_section_list_response.dart';

Map<String, dynamic> _lesson(String id) => {
      'id': id,
      'name': 'Lesson $id',
      'learningStatus': 1,
      'percentComplete': 40,
      'lessonModule': {'name': 'Bệnh lý'},
      'image': {'url': 'https://x/$id.png'},
      'lessonSections': [
        {'id': '$id-s1', 'name': 'Part 1', 'firstContent': '<p>long html</p>'},
      ],
    };

void main() {
  test('Library list response keeps card fields but drops lessonSections', () {
    final res = LessonModuleTypeResponse.fromJson({
      'meta': {'success': true},
      'data': [_lesson('a'), _lesson('b')],
    });
    expect(res.data, hasLength(2));
    final first = res.data!.first!;
    expect(first.id, 'a');
    expect(first.name, 'Lesson a');
    expect(first.learningStatus, 1);
    expect(first.percentComplete, 40);
    expect(first.lessonModule?.name, 'Bệnh lý');
    expect(first.image?.url, 'https://x/a.png');
    expect(first.lessonSections, isNull);
  });

  test('lesson detail parsing still reads lessonSections', () {
    final detail = LessonSectionListResponseData.fromJson(_lesson('a'));
    expect(detail.lessonSections, hasLength(1));
    expect(detail.lessonSections!.first?.id, 'a-s1');
  });
}
