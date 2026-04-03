import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/my_lesson_response.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/lesson_status_widget.dart';

import '../lesson_detail/lesson_detail.dart';
import 'lesson_search_cache.dart';

class LessonSearchPage extends StatefulWidget {
  const LessonSearchPage({super.key});

  @override
  State<LessonSearchPage> createState() => _LessonSearchPageState();
}

class _LessonSearchPageState extends State<LessonSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounce;

  bool _isLoadingInitial = false;
  bool _isSearching = false;
  bool _showEmptyState = false;

  List<MyLessonResponseData?> _allLessons = [];
  List<MyLessonResponseData?> _searchResults = [];

  /// Module filter chips, first item is "Tất cả".
  final List<String> _moduleFilters = <String>['Tất cả'];
  int _selectedModuleIndex = 0;

  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadInitialLessons();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLessons() async {
    setState(() {
      _isLoadingInitial = true;
    });

    final List<MyLessonResponseData?>? cached = LessonSearchCache.lessons;
    _allLessons = List<MyLessonResponseData?>.from(cached ?? const []);
    _buildModuleFilters();

    if (mounted) {
      setState(() {
        _isLoadingInitial = false;
      });
    }
  }

  void _buildModuleFilters() {
    final Set<String> modules = <String>{};
    for (final MyLessonResponseData? lesson in _allLessons) {
      final String raw = lesson?.module?.trim() ?? '';
      if (raw.isNotEmpty) {
        modules.add(raw);
      }
    }
    _moduleFilters
      ..clear()
      ..add('Tất cả')
      ..addAll(modules.toList());
  }

  void _onSearchChanged(String value) {
    final String trimmed = value.trim();
    _currentQuery = trimmed;

    // If user clears text manually, return to suggested state.
    if (trimmed.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _isSearching = false;
        _showEmptyState = false;
        _searchResults.clear();
      });
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(trimmed);
    });
  }

  void _onSearchSubmitted(String value) {
    final String trimmed = value.trim();
    _debounce?.cancel();
    _performSearch(trimmed);
  }

  void _performSearch(String query) {
    final String q = query.toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _isSearching = false;
        _showEmptyState = false;
        _searchResults.clear();
      });
      return;
    }

    Iterable<MyLessonResponseData?> filtered = _allLessons;

    filtered = filtered.where(
      (MyLessonResponseData? lesson) =>
          (lesson?.name ?? '').toLowerCase().contains(q),
    );

    if (_selectedModuleIndex != 0 &&
        _selectedModuleIndex < _moduleFilters.length) {
      final String moduleFilter = _moduleFilters[_selectedModuleIndex];
      filtered = filtered.where(
        (MyLessonResponseData? lesson) =>
            (lesson?.module ?? '').trim() == moduleFilter,
      );
    }

    final List<MyLessonResponseData?> results = filtered.toList();

    setState(() {
      _isSearching = true;
      _searchResults = results;
      _showEmptyState = results.isEmpty;
    });
  }

  void _onClearPressed() {
    _debounce?.cancel();
    _searchController.clear();
    _currentQuery = '';

    setState(() {
      _isSearching = false;
      _showEmptyState = false; // Match the "cleared text" behavior.
      _searchResults.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _onTapOutside() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      body: GestureDetector(
        onTap: _onTapOutside,
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            _buildSearchAppBar(context),
            Expanded(
              child: _isLoadingInitial
                  ? Center(
                      child: CircularProgressIndicator(
                        color: R.color.greenGradientBottom,
                      ),
                    )
                  : _buildBodyContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAppBar(BuildContext context) {
    return Container(
      color: R.color.greenGradientBottom,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: R.color.white),
                onPressed: () {
                  NavigationUtil.pop(context);
                },
              ),
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: R.color.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    textAlignVertical: TextAlignVertical.center,
                    onChanged: _onSearchChanged,
                    onSubmitted: _onSearchSubmitted,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      border: InputBorder.none,
                      hintText: 'Tìm bài học',
                      hintStyle: TextStyle(
                        color: R.color.grey_2,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: R.color.grey_2,
                        size: 20,
                      ),
                      suffixIcon: _currentQuery.isNotEmpty || _showEmptyState
                          ? GestureDetector(
                              onTap: _onClearPressed,
                              child: Icon(
                                Icons.close,
                                color: R.color.grey_2,
                                size: 18,
                              ),
                            )
                          : null,
                    ),
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 14,
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

  Widget _buildBodyContent() {
    // Standalone empty state only when user cleared search (no query).
    if (_showEmptyState && !_isSearching) {
      return _buildEmptyState();
    }

    // No active search -> show suggested lessons (library home style).
    if (!_isSearching) {
      return _buildSuggestedLessons();
    }

    // Has search query -> always show chips + result count + list or empty.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModuleChips(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            '${_searchResults.length} kết quả',
            style: TextStyle(
              color: R.color.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _searchResults.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (BuildContext context, int index) {
                    final MyLessonResponseData? lesson = _searchResults[index];
                    return _buildResultRow(lesson);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: _searchResults.length,
                ),
        ),
      ],
    );
  }

  Widget _buildModuleChips() {
    if (_moduleFilters.length <= 1) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          final bool isActive = index == _selectedModuleIndex;
          final String label = _moduleFilters[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedModuleIndex = index;
              });
              if (_currentQuery.isNotEmpty) {
                _performSearch(_currentQuery);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isActive ? R.color.greenGradientBottom : R.color.white,
                borderRadius: BorderRadius.circular(200),
                border: isActive
                    ? null
                    : Border.all(color: R.color.captionColorGray),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? R.color.white : R.color.captionColorGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _moduleFilters.length,
      ),
    );
  }

  Widget _buildSuggestedLessons() {
    if (_allLessons.isEmpty) {
      return _buildEmptyState();
    }

    final Map<String, List<MyLessonResponseData?>> moduleMap = {};
    for (final MyLessonResponseData? lesson in _allLessons) {
      if (lesson == null) continue;
      final String key = (lesson.module ?? '').trim().isEmpty
          ? R.string.title_route.tr()
          : lesson.module!.trim();
      moduleMap.putIfAbsent(key, () => <MyLessonResponseData?>[]).add(lesson);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemBuilder: (BuildContext context, int index) {
        final String moduleName = moduleMap.keys.elementAt(index);
        final List<MyLessonResponseData?> lessons =
            moduleMap[moduleName] ?? <MyLessonResponseData?>[];
        return Container(
          color: R.color.white,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  moduleName,
                  style: TextStyle(
                    color: R.color.textDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: lessons.length,
                  itemBuilder: (BuildContext context, int idx) {
                    final MyLessonResponseData? lesson = lessons[idx];
                    return _buildSuggestedCard(lesson);
                  },
                ),
              ),
            ],
          ),
        );
      },
      itemCount: moduleMap.length,
    );
  }

  Widget _buildSuggestedCard(MyLessonResponseData? lesson) {
    final String category = lesson?.module ?? '';
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson),
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: R.color.grey_6),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 132,
                width: double.infinity,
                child: Image.network(
                  lesson?.image?.url ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: R.color.grey_6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (category.isNotEmpty)
              Text(
                category,
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: Text(
                lesson?.name ?? '',
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            LessonStatusWidget(
              learningStatus: lesson?.learningStatus,
              progress: lesson?.percentComplete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(MyLessonResponseData? lesson) {
    final String module = lesson?.module ?? '';
    return InkWell(
      onTap: () => _navigateToLessonDetail(lesson),
      child: Container(
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: R.color.grey_6),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.network(
                  lesson?.image?.url ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: R.color.grey_6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (module.isNotEmpty)
                    Text(
                      module,
                      style: TextStyle(
                        color: R.color.greenGradientBottom,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    lesson?.name ?? '',
                    style: TextStyle(
                      color: R.color.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  LessonStatusWidget(
                    learningStatus: lesson?.learningStatus,
                    progress: lesson?.percentComplete,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: R.color.greenGradientBottom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            R.drawable.img_activity_empty,
            width: 268.w,
            height: 200.w,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              R.string.no_matched_lesson.tr(),
              style: TextStyle(
                color: R.color.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToLessonDetail(MyLessonResponseData? lesson) async {
    if (lesson?.id?.isEmpty != false) return;
    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: lesson?.type,
        lessonId: lesson!.id!,
        onComplete: (_, __) {},
      ),
    );
  }
}
