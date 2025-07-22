import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/bloc/exercrises/exercrises_bloc.dart';
import 'package:medical/src/model/response/exercise_lesson_response.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

class ExercrisesLessonSection extends StatefulWidget {
  const ExercrisesLessonSection({super.key, required this.onLessonTap});

  final Function(ExerciseLesson) onLessonTap;

  @override
  State<ExercrisesLessonSection> createState() =>
      ExercrisesLessonSectionState();
}

class ExercrisesLessonSectionState extends State<ExercrisesLessonSection> {
  int _currentIndex = 0;
  final double _lessonItemWidth = 338.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // * Scroll listener
  void _onScroll() {
    final double currentScroll = _scrollController.position.pixels;
    final double eachItemWidth = _lessonItemWidth;

    int currentIndex = (currentScroll / eachItemWidth).round();
    setState(() {
      _currentIndex = currentIndex;
    });
  }

  final _bloc = ExercrisesBloc();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc.add(FetchSupportExercises());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<ExercrisesBloc, ExercrisesState>(
          builder: (context, state) {
        if (state is ExerciseSupportLessonsLoaded) {
          final exercises = state.exercises ?? [];

          if (exercises.isEmpty) {
            return SizedBox();
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    R.string.knowledge_from_diab_experts.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: R.color.dark,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // List of items
                SizedBox(
                  height: 318,
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(left: 12),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        child: _buildLessonItem(exercises[index]),
                        height: 318,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(width: 12);
                    },
                    itemCount: exercises.length,
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  height: 8,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < exercises.length; i++)
                          Container(
                            width: _currentIndex == i ? 16 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: _currentIndex == i
                                  ? R.color.mainColor
                                  : Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        }
        // Widget hiển thị khi đang loading
        return Center(
          child: CircularProgressIndicator(),
        );
      }),
    );
  }

  Widget _buildLessonItem(ExerciseLesson lesson) {
    return SizedBox(
      height: 252.0,
      width: _lessonItemWidth,
      child: InkWell(
        onTap: () => widget.onLessonTap(lesson),
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE4E4E7), width: 1.0),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: NetWorkImageWidget(
                  imageUrl: lesson.image?.url ?? lesson.thumbnailUrl ?? '',
                  fit: BoxFit.cover,
                  height: 174.0,
                  width: double.infinity,
                ),
              ),

              const SizedBox(height: 12.0),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.name ?? 'Unnamed Exercise',
                        maxLines: 2,
                        style: TextStyle(
                          color: R.color.textDark,
                          fontSize: 15.0,
                          height: 24.0 / 15.0,
                        ),
                      ),
                      // const SizedBox(height: 4.0),
                      // Category
                      // Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     Image.asset(
                      //       R.drawable.ic_lesson_category,
                      //       width: 16.0,
                      //       height: 16.0,
                      //     ),
                      //     const SizedBox(width: 6.0),
                      //     Text(
                      //       '${lesson.duration?.toInt() ?? 0} phút',
                      //       style: TextStyle(
                      //         color: R.color.color0xff666666,
                      //         fontSize: 12.0,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),

              // const SizedBox(height: 12.0),
              Divider(
                height: 1,
                color: R.color.color0xffE5E5E5,
              ),

              // Actions
              SizedBox(
                height: 40,
                child: Center(
                  child: InkWell(
                    onTap: () {},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(R.drawable.ic_lesson_share,
                            width: 20.0, height: 20.0),
                        const SizedBox(width: 8.0),
                        Text(
                          R.string.share.tr(),
                          style: TextStyle(
                              color: R.color.textDark, fontSize: 15.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
