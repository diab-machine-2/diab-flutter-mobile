import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'exercise_detail.dart';
import 'models/video_manager.dart';

class ExerciseDetailCubit extends Cubit<ExerciseDetailState> {
  ExerciseDetailCubit(this.repository) : super(const ExerciseDetailInitial());

  final AppRepository repository;

  VideoManager videoManager = VideoManager(
    url:
        'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    loop: 1,
  );

}
