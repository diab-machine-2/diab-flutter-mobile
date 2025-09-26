import 'package:flutter/material.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart'
    as learning_post_model;
import 'package:medical/src/widget/home/widget/home_lesson.dart';

class ExercisesLesson extends StatefulWidget {
  const ExercisesLesson({Key? key, this.gutterGhost = false}) : super(key: key);
  final bool? gutterGhost;

  @override
  ExercisesLessonState createState() => ExercisesLessonState();
}

class ExercisesLessonState extends State<ExercisesLesson> {
  bool gutterGhost = false;
  @override
  void initState() {
    super.initState();
    // Initialize any necessary data or state here
    gutterGhost = widget.gutterGhost ?? false;
  }

  final mockLessons = [
    for (int i = 1; i <= 6; i++)
      learning_post_model.LessonModel(
        id: 'lesson_$i',
        name: 'Lesson $i',
        image: ImagesModel(
          id: 'image_$i',
          url: 'https://example.com/image_$i.jpg',
        ),
        description: 'Description for Lesson $i',
        status: 1,
        type: 0,
        level: 'Level $i',
        module: 'Module $i',
        learningStatus: 0,
        percentComplete: 100,
        order: i,
        levelOrder: i,
        isNew: i % 2 == 0,
        activeDateTime: DateTime.now().millisecondsSinceEpoch,
      ),
  ].toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
      margin: gutterGhost
          ? const EdgeInsets.all(0)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: HomeLesson(
        lessons: mockLessons,
        showGutter: true,
        onLessonTap: (lesson) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on: ${lesson.name}')),
          );
        },
        onLike: (lesson) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Liked: ${lesson.name}')),
          );
        },
        onComment: (lesson) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Commented on: ${lesson.name}')),
          );
        },
        onShare: (lesson) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Shared: ${lesson.name}')),
          );
        },
      ),
    );
  }
}
