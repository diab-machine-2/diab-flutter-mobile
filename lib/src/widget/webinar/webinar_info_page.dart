import 'dart:ui' as ui;
import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/learning/learning_post_model.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/learning_post_response.dart';
import 'package:medical/src/model/service/api_result.dart';
import 'package:medical/src/model/service/network_exceptions.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/home/widget/home_support_functions.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail_page.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/html_text_widget.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/model/response/user_info_response.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/widget/booking_doctor/booking_doctor_page.dart';

class WebinarInfoPage extends StatefulWidget {
  final String id;

  const WebinarInfoPage({Key? key, required this.id}) : super(key: key);

  @override
  State<WebinarInfoPage> createState() => _WebinarInfoPageState();
}

class _WebinarInfoPageState extends State<WebinarInfoPage> {
  final AppRepository _repository = AppRepository();

  LearningPostModel? _webinar;
  List<LearningPostModel> _similarEvents = [];
  bool _loading = true;
  bool _registering = false;
  bool _showFullContent = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    try {
      final ApiResult<WebinarDetailResponse> detailResult =
          await _repository.getLearningPostEvent(widget.id);
      final ApiResult<List<WebinarDetailResponse>> eventsResult =
          await _repository.getLearningPostEvents();

      detailResult.when(
        success: (resp) {
          _webinar = resp.data;
        },
        failure: (error) {
          Message.showToastMessage(
              context, NetworkExceptions.getErrorMessage(error));
        },
      );

      eventsResult.when(
        success: (resp) {
          _similarEvents = resp
              .map((e) => e.data)
              .where((e) => e != null && e.id != _webinar?.id)
              .cast<LearningPostModel>()
              .toList();
        },
        failure: (error) {
          // ignore but log toast for debugging
          Message.showToastMessage(
              context, NetworkExceptions.getErrorMessage(error));
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _onRegister() async {
    if (_webinar == null || _registering) return;
    setState(() {
      _registering = true;
    });
    BotToast.showLoading();
    try {
      await _repository.registerLearningPostEvent(_webinar!.id ?? '');
      Message.showToastMessage(context, 'Đăng ký tham gia thành công');
      // Reload data to update isJoin status
      _loadData();
    } catch (e) {
      Message.showToastMessage(
          context,
          NetworkExceptions.getErrorMessage(
              NetworkExceptions.getDioException(e)));
    } finally {
      BotToast.closeAllLoading();
      if (mounted) {
        setState(() {
          _registering = false;
        });
      }
    }
  }

  Future<void> _onJoinNow() async {
    if (_webinar?.link == null || _webinar!.link!.isEmpty) return;
    final launchUri = Uri.parse(_webinar!.link!);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Message.showToastMessage(context, 'Không thể mở liên kết');
    }
  }

  Future<void> _onWatchReplay() async {
    final webinar = _webinar;
    if (webinar == null) return;

    // Check if user is free user
    final isFreeUser = AppSettings.userInfo?.packageType == PackageType.free;
    if (isFreeUser) {
      showUpdateRequirePopup(context: context);
      return;
    }

    // Use lessonId if available, otherwise try to get it from lesson object
    final lessonId = webinar.lessonId ?? webinar.lesson?.id;
    final lessonType = webinar.lesson?.type;

    if (lessonId == null || lessonId.isEmpty) {
      Message.showToastMessage(context, 'Không có bài học để xem lại');
      return;
    }

    if (lessonType == null) {
      Message.showToastMessage(context, 'Không thể xác định loại bài học');
      return;
    }

    await NavigationUtil.navigatePage(
      context,
      LessonDetailPage(
        lessonType: lessonType,
        lessonId: lessonId,
        onComplete: (_, __) {},
      ),
    );
  }

  String _formatEventDate(LearningPostModel model) {
    if (model.eventDate == null || model.eventDate == 0) {
      return '';
    }
    final dt =
        DateTime.fromMillisecondsSinceEpoch(model.eventDate! * 1000).toLocal();
    final weekdayText = getWeekDay(model.eventDate!);
    final dateText = DateFormat('dd/MM/yyyy').format(dt);
    return '$weekdayText, $dateText';
  }

  String _formatEventTime(String? eventTime) {
    if (eventTime == null || eventTime.isEmpty) {
      return '';
    }
    try {
      final timeParts = eventTime.split(':');
      if (timeParts.length >= 2) {
        final hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      // If parsing fails, return original string
    }
    return eventTime;
  }

  DateTime? _getEventDateTime(LearningPostModel model) {
    if (model.eventDate == null || model.eventDate == 0) {
      return null;
    }
    var eventDateTime =
        DateTime.fromMillisecondsSinceEpoch(model.eventDate! * 1000).toLocal();

    // Parse eventTime if available
    if (model.eventTime != null && model.eventTime!.isNotEmpty) {
      try {
        final timeParts = model.eventTime!.split(':');
        if (timeParts.length >= 2) {
          final hour = int.tryParse(timeParts[0]) ?? 0;
          final minute = int.tryParse(timeParts[1]) ?? 0;
          eventDateTime = eventDateTime.copyWith(hour: hour, minute: minute);
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }
    return eventDateTime;
  }

  int _calculateHoursUntilEvent(LearningPostModel model) {
    final eventDateTime = _getEventDateTime(model);
    if (eventDateTime == null) return 0;

    final now = DateTime.now();
    final difference = eventDateTime.difference(now);
    return difference.inHours > 0 ? difference.inHours : 0;
  }

  DateTime? _getEventEndDateTime(LearningPostModel model) {
    final eventDateTime = _getEventDateTime(model);
    if (eventDateTime == null) return null;

    // duration is stored in HOURS
    final duration = (model.duration ?? 0);
    return eventDateTime.add(Duration(hours: duration));
  }

  bool _isEventStarted(LearningPostModel model) {
    final eventDateTime = _getEventDateTime(model);
    if (eventDateTime == null) return false;

    final now = DateTime.now();
    final eventEndDateTime = _getEventEndDateTime(model);

    // Event is started if current time is after start time
    if (now.isBefore(eventDateTime)) return false;

    // Event is still ongoing if current time is before end time (if duration is set)
    if (eventEndDateTime != null) {
      return now.isBefore(eventEndDateTime);
    }

    // If no duration, check if it's the same day and after start time
    final isSameDay = now.year == eventDateTime.year &&
        now.month == eventDateTime.month &&
        now.day == eventDateTime.day;
    return isSameDay && now.isAfter(eventDateTime);
  }

  bool _isEventUpcoming(LearningPostModel model) {
    final eventDateTime = _getEventDateTime(model);
    if (eventDateTime == null) return false;
    final now = DateTime.now();
    return now.isBefore(eventDateTime);
  }

  bool _isEventEnded(LearningPostModel model) {
    final eventEndDateTime = _getEventEndDateTime(model);
    if (eventEndDateTime == null) {
      // If no duration, we can't determine if event has ended
      // Fall back to checking if it's past the start date
      final eventDateTime = _getEventDateTime(model);
      if (eventDateTime == null) return false;
      final now = DateTime.now();
      // If it's past the start date and not the same day, consider it ended
      if (now.isAfter(eventDateTime)) {
        final isSameDay = now.year == eventDateTime.year &&
            now.month == eventDateTime.month &&
            now.day == eventDateTime.day;
        return !isSameDay;
      }
      return false;
    }
    final now = DateTime.now();
    return now.isAfter(eventEndDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final webinar = _webinar;

    return Scaffold(
      backgroundColor: R.color.backgroundColorNew,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
              stops: [0.01, 0.99],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          child: CustomAppBar(
            backgroundColor: Colors.transparent,
            title: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context)
                    .textScaler
                    .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
              ),
              child: Text(
                R.string.event.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: R.color.white,
                ),
              ),
            ),
            actions: [
              InkWell(
                onTap: () async {
                  HomeSupportFunctions.showModalAddData(context);
                },
                child: Container(
                  height: 36,
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  margin: EdgeInsets.fromLTRB(0, 12, 16, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: R.color.color0xffCAFAF5,
                    border: Border.all(
                      color: R.color.color0xff8FEBE0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        R.icons.ic_telephone,
                        width: 16,
                        height: 16,
                        color: R.color.greenGradientBottom,
                        fit: BoxFit.scaleDown,
                      ),
                      GapW(4),
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: MediaQuery.of(context)
                              .textScaler
                              .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                        ),
                        child: Text(
                          R.string.contact.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'sfpro',
                            fontWeight: FontWeight.w700,
                            color: R.color.greenGradientBottom,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            leadingIcon: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(
                Icons.arrow_back,
                color: R.color.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : webinar == null
              ? const Center(child: Text('Không tìm thấy sự kiện'))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section 1: Banner and Event Details (White Container)
                            Container(
                              color: Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Banner with overlay
                                  if (webinar.imageBannerUrl?.url?.isNotEmpty ==
                                      true)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          child: NetWorkImageWidget(
                                            imageUrl:
                                                webinar.imageBannerUrl!.url!,
                                            width: 1.sw,
                                            height: 210.h,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Overlay at bottom depending on event status
                                        if (_isEventUpcoming(webinar))
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16.sp,
                                                    color: Colors.white,
                                                  ),
                                                  GapW(4.w),
                                                  Text(
                                                    'Sẽ diễn ra sau ${_calculateHoursUntilEvent(webinar)} tiếng',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else if (_isEventStarted(webinar))
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10.w,
                                                            vertical: 6.h),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xff0FB4A5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 6.w,
                                                          height: 6.h,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        ),
                                                        GapW(6.w),
                                                        Text(
                                                          'Đang diễn ra',
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (webinar.eventJoinCount !=
                                                      null)
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.group,
                                                          size: 16.sp,
                                                          color: Colors.white,
                                                        ),
                                                        GapW(4.w),
                                                        Text(
                                                          '${webinar.eventJoinCount}',
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else if (_isEventEnded(webinar))
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xff5E6566),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Đã kết thúc sự kiện',
                                                    style: TextStyle(
                                                      fontSize: 15.sp,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 16.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Chips row with registration count
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Wrap(
                                                spacing: 8.w,
                                                runSpacing: 4.h,
                                                children: [
                                                  if (webinar
                                                      .learningPostTagMappings
                                                      .isNotEmpty)
                                                    ...webinar
                                                        .learningPostTagMappings
                                                        .map((t) =>
                                                            _buildChip(t.name)),
                                                ],
                                              ),
                                            ),
                                            if (webinar.eventJoinCount != null)
                                              Text(
                                                '${webinar.eventJoinCount} lượt đăng ký',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color:
                                                      const Color(0xFF6B7280),
                                                ),
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          webinar.title,
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        // Time row: eventTime on left, date on right
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.access_time,
                                                    size: 16.sp,
                                                    color: const Color(
                                                        0xFF6B7280)),
                                                GapW(4.w),
                                                Text(
                                                  _formatEventTime(
                                                      webinar.eventTime),
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 16.sp,
                                                    color: const Color(
                                                        0xFF6B7280)),
                                                GapW(4.w),
                                                Text(
                                                  _formatEventDate(webinar),
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        // Location row
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              // eventType true = offline, false = online
                                              webinar.eventType == true
                                                  ? Icons.location_on_outlined
                                                  : Icons.videocam,
                                              size: 16.sp,
                                              color: const Color(0xFF6B7280),
                                            ),
                                            GapW(4.w),
                                            Expanded(
                                              child: InkWell(
                                                onTap: () async {
                                                  // Only make it clickable for offline events with a valid link
                                                  if (webinar.eventType ==
                                                          true &&
                                                      webinar.link != null &&
                                                      webinar.link!
                                                          .trim()
                                                          .isNotEmpty) {
                                                    final uri = Uri.tryParse(
                                                        webinar.link!.trim());
                                                    if (uri != null &&
                                                        await canLaunchUrl(
                                                            uri)) {
                                                      await launchUrl(uri);
                                                    }
                                                  }
                                                },
                                                child: Text(
                                                  // eventType true = offline, false = online
                                                  webinar.eventType == true
                                                      ? (webinar.eventAddress ??
                                                          '')
                                                      : 'Sự kiện trực tuyến',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color:
                                                        const Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GapH(8.h),
                            // Section 2: Program Information (White Container)
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 16.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông tin chương trình',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  // HTML content with ellipsis and show more
                                  _buildContentSection(webinar),
                                  if (webinar.doctor != null) ...[
                                    SizedBox(height: 8.h),
                                    _buildSpeakerCard(webinar),
                                  ],
                                ],
                              ),
                            ),
                            GapH(8.h),
                            // Section 3: Similar Events
                            if (_similarEvents.isNotEmpty) ...[
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(
                                    left: 16.w,
                                    right: 16.w,
                                    top: 16.h,
                                    bottom: 8.h),
                                child: Text(
                                  'Sự kiện tương tự',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: SizedBox(
                                  height: 210.h,
                                  child: ListView.separated(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, index) {
                                      final item = _similarEvents[index];
                                      return _buildSimilarEventItem(item);
                                    },
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: 12.w),
                                    itemCount: _similarEvents.length,
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: 16.h),
                          ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final actionButton = _buildActionButton();
                        if (actionButton == null) {
                          return const SizedBox.shrink();
                        }
                        return SafeArea(
                          top: false,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: actionButton,
                          ),
                        );
                      },
                    ),
                  ],
                ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xff0FB4A5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildContentSection(LearningPostModel webinar) {
    final content = webinar.content ?? '';
    if (content.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if content is longer than 3 lines (approximate)
    final plainText = content.replaceAll(RegExp(r'<[^>]*>'), '');
    final textPainter = TextPainter(
      text: TextSpan(
        text: plainText,
        style: TextStyle(fontSize: 14.sp, height: 1.5),
      ),
      maxLines: 3,
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 1.sw - 32.w);
    final isLongContent = textPainter.didExceedMaxLines;
    // Approximate height for 3 lines: fontSize * lineHeight * 3
    final maxHeight = 15.5.sp * 1.5 * 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _showFullContent
            ? WidgetHtmlText(
                content,
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  height: 1.5,
                  color: const Color(0xFF111827),
                ),
              )
            : isLongContent
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: maxHeight,
                        child: ClipRect(
                          child: WidgetHtmlText(
                            content,
                            textStyle: TextStyle(
                              fontSize: 15.sp,
                              height: 1.5,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : WidgetHtmlText(
                    content,
                    textStyle: TextStyle(
                      fontSize: 15.sp,
                      height: 1.5,
                      color: const Color(0xFF111827),
                    ),
                  ),
        if (isLongContent && !_showFullContent)
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullContent = true;
              });
            },
            child: Text(
              R.string.show_more.tr(),
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF95682E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (isLongContent && _showFullContent)
          GestureDetector(
            onTap: () {
              setState(() {
                _showFullContent = false;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                R.string.show_less.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF95682E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSpeakerCard(LearningPostModel webinar) {
    if (webinar.doctor == null) return const SizedBox.shrink();

    final doctor = webinar.doctor!;
    final specialtyName =
        doctor.specialty.isNotEmpty ? doctor.specialty.first.name : '';
    final titleText = doctor.graduateName.isNotEmpty && specialtyName.isNotEmpty
        ? '${doctor.graduateName} $specialtyName'
        : doctor.graduateName.isNotEmpty
            ? doctor.graduateName
            : specialtyName;
    final displayName = '${doctor.name}'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          R.string.participation.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: () => _navigateToDoctorDetail(doctor.id),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36.r,
                  backgroundColor: const Color(0xFFE5E7EB),
                  backgroundImage: doctor.avatar.isNotEmpty
                      ? NetworkImage(doctor.avatar)
                      : null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (titleText.isNotEmpty)
                        Text(
                          titleText,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: R.color.main_1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      if (titleText.isNotEmpty) SizedBox(height: 4.h),
                      Text(
                        displayName,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: R.color.color0xff111515),
                      ),
                      if (specialtyName.isNotEmpty) SizedBox(height: 8.h),
                      if (specialtyName.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFEF3C7), // Light yellow/beige
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            specialtyName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: R.color.color0xff95682E,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatEventDateTimeForSimilar(LearningPostModel model) {
    if (model.eventDate == null || model.eventDate == 0) {
      return '';
    }
    final dt =
        DateTime.fromMillisecondsSinceEpoch(model.eventDate! * 1000).toLocal();
    final weekdayText = getWeekDay(model.eventDate!);
    final dateText = DateFormat('dd/MM/yyyy').format(dt);
    final timeText = _formatEventTime(model.eventTime);
    return '$timeText $weekdayText, $dateText';
  }

  Widget _buildSimilarEventItem(LearningPostModel item) {
    return InkWell(
      onTap: () {
        if (item.id != null && item.id!.isNotEmpty) {
          Navigator.pushNamed(
            context,
            NavigatorName.webinar_info,
            arguments: {'id': item.id},
          );
        }
      },
      child: SizedBox(
        width: 260.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner with bottom overlay (only when event has started)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetWorkImageWidget(
                    imageUrl: item.imageBannerUrl?.url ??
                        item.imageUrl.url ??
                        '', // fallback
                    width: 260.w,
                    height: 120.h,
                    fit: BoxFit.cover,
                  ),
                ),
                if (_isEventStarted(item))
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Teal pill: ● Đang diễn ra
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xff0FB4A5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                GapW(6.w),
                                Text(
                                  'Đang diễn ra',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.eventJoinCount != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.group,
                                  size: 16.sp,
                                  color: Colors.white,
                                ),
                                GapW(4.w),
                                Text(
                                  '${item.eventJoinCount}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            // Calendar icon + eventTime + weekdayText, dd/MM/yyyy
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
                GapW(4.w),
                Expanded(
                  child: Text(
                    _formatEventDateTimeForSimilar(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            // Event title
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 4.h),
            // eventAddress or "Sự kiện trực tuyến" based on eventType
            Row(
              children: [
                Icon(
                  // eventType true = offline, false = online
                  item.eventType == true
                      ? Icons.location_on_outlined
                      : Icons.videocam,
                  size: 14.sp,
                  color: const Color(0xFF6B7280),
                ),
                GapW(4.w),
                Expanded(
                  child: Text(
                    // eventType true = offline, false = online
                    item.eventType == true
                        ? (item.eventAddress ?? '')
                        : 'Sự kiện trực tuyến',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            // {eventJoinCount} lượt tham gia
            if (item.eventJoinCount != null)
              Text(
                '${item.eventJoinCount} lượt tham gia',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildActionButton() {
    final webinar = _webinar;
    if (webinar == null) return null;

    final isJoined = webinar.isJoin == true;
    final isOnlineEvent = webinar.eventType == false;
    final hasLink = webinar.link != null && webinar.link!.isNotEmpty;
    final eventDateTime = _getEventDateTime(webinar);
    final now = DateTime.now();
    final isEventStarted = _isEventStarted(webinar);
    final isEventEnded = _isEventEnded(webinar);
    final isBeforeEvent = eventDateTime != null && now.isBefore(eventDateTime);

    // State 4: Event has ended
    if (isEventEnded) {
      // If user joined, show "Xem lại sự kiện" button
      if (isJoined) {
        return InkWell(
          onTap: _onWatchReplay,
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: R.color.greenGradientBottom,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Xem lại sự kiện',
                style: TextStyle(
                  color: R.color.greenGradientBottom,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      }
      // If user didn't join, hide the button
      return null;
    }

    // State 3: Event is currently happening (during event)
    if (isEventStarted) {
      // If user joined and it's online event with link, show "Tham gia ngay"
      if (isJoined && isOnlineEvent && hasLink) {
        return InkWell(
          onTap: _onJoinNow,
          child: Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  R.color.greenGradientTop,
                  R.color.greenGradientBottom,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'Tham gia ngay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: R.font.sfpro,
                ),
              ),
            ),
          ),
        );
      }
      // If user joined but it's offline event, show "Đã đăng ký"
      if (isJoined) {
        return Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xff0FB4A5),
              width: 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check,
                  size: 18,
                  color: const Color(0xff0FB4A5),
                ),
                GapW(8.w),
                Text(
                  'Đã đăng ký',
                  style: TextStyle(
                    color: const Color(0xff0FB4A5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: R.font.sfpro,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // If user hasn't joined yet during event, show "Đăng ký tham gia"
      return InkWell(
        onTap: _registering ? null : _onRegister,
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                R.color.greenGradientTop,
                R.color.greenGradientBottom,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: _registering
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    'Đăng ký tham gia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
          ),
        ),
      );
    }

    // State 2: Before event and user has joined - show "Đã đăng ký"
    if (isBeforeEvent && isJoined) {
      return Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xff0FB4A5),
            width: 1,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check,
                size: 18,
                color: const Color(0xff0FB4A5),
              ),
              GapW(8.w),
              Text(
                'Đã đăng ký',
                style: TextStyle(
                  color: const Color(0xff0FB4A5),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: R.font.sfpro,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // State 1: Before event and user hasn't joined - show "Đăng ký tham gia"
    return InkWell(
      onTap: _registering ? null : _onRegister,
      child: Container(
        width: double.infinity,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              R.color.greenGradientTop,
              R.color.greenGradientBottom,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: _registering
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Text(
                  'Đăng ký tham gia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: R.font.sfpro,
                  ),
                ),
        ),
      ),
    );
  }

  void showUpdateRequirePopup({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF008076),
                Color(0xFF0DA99C),
                Color(0xFFEAF9F7),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: Image.asset(
                  R.drawable.img_upgrade_package_v2,
                  width: 35,
                  height: 35,
                ),
              ),
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context)
                      .textScaler
                      .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.3),
                ),
                child: Text(
                  R.string.unlock_advanced_lessons.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: R.color.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GapH(16),
              Container(
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: MediaQuery.of(context).textScaler.clamp(
                                minScaleFactor: 1.0, maxScaleFactor: 1.3),
                          ),
                          child: Text(
                            R.string.membership_benefits.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: R.color.greenGradientBottom,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GapH(12),
                    _benefitRow(
                        R.string
                            .pathology_nutrition_exercise_psychology_knowledge_diverse
                            .tr(),
                        R.string.pathology_nutrition_knowledge.tr()),
                    _benefitRow(
                        R.string.personalized_healthy_lifestyle_roadmap.tr(),
                        R.string.healthy_lifestyle_roadmap.tr()),
                    _benefitRow(R.string.use_all_advanced_features.tr(),
                        R.string.advanced_features.tr()),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Observable.instance.notifyObservers(
                          [],
                          notifyName: Const
                              .NAVIGATE_TO_MY_PLAN_TAB_AUTO_TRIGGER_SUBSCRIPTION,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        height: 48,
                        decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.centerRight,
                            colors: [
                              R.color.greenGradientTop,
                              R.color.greenGradientBottom,
                              R.color.greenGradientBottom,
                            ],
                          ),
                        ),
                        child: Center(
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(
                              textScaler: MediaQuery.of(context)
                                  .textScaler
                                  .clamp(
                                      minScaleFactor: 1.0, maxScaleFactor: 1.3),
                            ),
                            child: Text(
                              R.string.tim_hieu_them.tr(),
                              style: TextStyle(
                                color: R.color.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _benefitRow(String text, String boldPart) {
    final parts = text.split(boldPart);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(
            R.drawable.ic_subscription_bullet,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: R.color.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: parts[0]),
                  TextSpan(
                    text: boldPart,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (parts.length > 1) TextSpan(text: parts[1]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToDoctorDetail(int doctorId) async {
    // Navigate to BookingDoctorPage with doctorId and fromWebinar flag
    // BookingDoctorPage will handle loading and auto-navigate to detail page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDoctorPage(
          pendingDoctorId: doctorId,
          fromWebinar: true,
        ),
      ),
    );
  }
}
