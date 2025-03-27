// screens/programs_list_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/request/notify_subscription_request.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/subscription/model/package_program_model.dart';
import 'package:medical/src/widget/subscription/services/package_program_service.dart';
import 'package:medical/src/widget/subscription/subscription_cubit.dart';
import 'package:medical/src/widget/subscription/subscription_navigation_mixin.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgramsListPage extends StatefulWidget {
  const ProgramsListPage({Key? key}) : super(key: key);

  @override
  State<ProgramsListPage> createState() => _ProgramsListPageState();
}

class _ProgramsListPageState extends State<ProgramsListPage> {
  late SubscriptionCubit _cubit;
  late Future<List<PackageProgram>> _programsFuture;
  final ProgramService _programService = ProgramService();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SubscriptionCubit>();
    _programsFuture = _programService.getPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      body: FutureBuilder<List<PackageProgram>>(
        future: _programsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(R.drawable.img_activity_empty, width: 200),
                  const SizedBox(height: 16),
                  const Text('Không có chương trình nào'),
                ],
              ),
            );
          } else {
            final programs = snapshot.data!;
            return Column(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        R.color.greenGradientTop02,
                        R.color.greenGradientBottom
                      ],
                      stops: [0.01, 0.99],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: CustomAppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      R.string.basic_program.tr(),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          // fontFamily: 'sfpro',
                          color: R.color.white),
                    ),
                    actions: [
                      InkWell(
                        onTap: () async {
                          final launchUri =
                              Uri(scheme: 'tel', path: Const.HOTLINE_NUMBER);
                          if (await canLaunchUrl(launchUri)) {
                            await launchUrl(launchUri);
                          } else {
                            throw 'Could not make phone call ${Const.HOTLINE_NUMBER}';
                          }
                        },
                        child: Container(
                          width: 85,
                          height: 33,
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 6),
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
                              Text(
                                R.string.contact.tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'sfpro',
                                  fontWeight: FontWeight.w700,
                                  color: R.color.greenGradientBottom,
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
                      onPressed: () {
                        SubscriptionNavigationMixin.navigationKey.currentState
                            ?.pop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: programs.length,
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemBuilder: (context, index) {
                      return ProgramCard(program: programs[index]);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final PackageProgram program;

  const ProgramCard({Key? key, required this.program}) : super(key: key);

  // Helper function to determine if we're on a mobile device
  double getShortestSide(BuildContext context) {
    double shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return shortestSide;
  }

  notifySubscriptionSuccess(BuildContext context) async {
    final subscriptionCubit = BlocProvider.of<SubscriptionCubit>(context);

    if (subscriptionCubit.selectedPackage == null) return;

    final request = NotifySubscriptionRequest(
        servicePackage: subscriptionCubit.selectedPackage!.title,
        programName: program.title);
    await subscriptionCubit.notifySubscriptionSuccess(request);
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a mobile device (shortestSide < 540)
    bool isMobile = getShortestSide(context) < Const.TABLET_BREAKPOINT;

    return Stack(
      children: [
        Container(
          margin:
              EdgeInsets.fromLTRB(12, program.isRecommended ? 24 : 12, 12, 12),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              Utils.getBoxShadowDropCard(),
            ],
          ),
          child: isMobile
              ? _buildMobileLayout(context)
              : _buildTabletLayout(context),
        ),
        if (program.isRecommended)
          Positioned(
            top: 10,
            left: 24,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    R.color.gradientGold1,
                    R.color.gradientGold2,
                    R.color.gradientGold3,
                    R.color.gradientGold4,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.25, 0.63, 1],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                R.string.most_suitable.tr(),
                style: TextStyle(
                  color: R.color.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }

// Mobile layout with calculated image height accounting for multi-line text
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Program Title
        Row(
          children: [
            Flexible(
              child: Text(
                program.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        GapH(8),

        // Content row with items and image side by side
        if (ProgramService.getProgramImage(program.id).isNotEmpty)
          LayoutBuilder(builder: (context, constraints) {
            double totalContentHeight = program.items.length *
                ((15 * 1.2 * 1.5) +
                    12); // (fontSize * lineHeight * avg lines) + padding

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column with program items
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: program.items
                        .map((item) => ProgramItemWidget(item: item))
                        .toList(),
                  ),
                ),

                // Adjustable gap between content and image
                SizedBox(width: constraints.maxWidth * 0.04),

                // Right column with image container fixed to content height
                Expanded(
                  flex: 2,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: totalContentHeight,
                      maxWidth:
                          totalContentHeight, // Square constraint for 1:1 ratio
                    ),
                    child: Image.asset(
                      ProgramService.getProgramImage(program.id),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            );
          })
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: program.items
                .map((item) => ProgramItemWidget(item: item))
                .toList(),
          ),

        SizedBox(height: 16),

        // Buttons row
        Row(
          children: [
            Expanded(
                child: GestureDetector(
              onTap: () {
                SubscriptionNavigationMixin.navigationKey.currentState
                    ?.pushNamed(NavigatorName.package_program_detail,
                        arguments: {'program': program});
              },
              child: Container(
                height: 43,
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                    color: R.color.greenGradientBottom,
                  ),
                ),
                child: Center(
                  child: Text(
                    R.string.more.tr(),
                    style: TextStyle(
                      color: R.color.greenGradientBottom,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )),
            GapW(16),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await notifySubscriptionSuccess(context);
                  ProgramService.showPopupRequestConsultSubscription(
                    context: context,
                    title: R.string.receive_consult_request_title.tr(),
                    subtitle: R.string.receive_consult_request_subtitle.tr(),
                    isShowImg: true,
                    primaryButtonTitle: R.string.back_home_page.tr(),
                    secondaryButtonTitle: R.string.support.tr(),
                    onNavigateHome: () {
                      Navigator.of(context, rootNavigator: true)
                          .pushNamedAndRemoveUntil(
                        NavigatorName.tabbar,
                        (route) => false, // This removes all routes from stack
                      );
                    },
                    onContact: () async {
                      final launchUri =
                          Uri(scheme: 'tel', path: Const.HOTLINE_NUMBER);
                      if (await canLaunchUrl(launchUri)) {
                        await launchUrl(launchUri);
                      } else {
                        throw 'Could not make phone call ${Const.HOTLINE_NUMBER}';
                      }
                    },
                  );
                },
                child: Container(
                  height: 43,
                  decoration: BoxDecoration(
                    color: R.color.mainColor,
                    borderRadius: BorderRadius.circular(200),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        R.color.greenGradientTop02,
                        R.color.greenGradientBottom,
                        R.color.greenGradientBottom,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      R.string.consult_request.tr(),
                      style: TextStyle(
                        color: R.color.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    // If no image, just return the content column
    if (ProgramService.getProgramImage(program.id).isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabletTitleAndContent(context, null),
        ],
      );
    }

    // Create a row with content and image
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate image size based on available width with 1:1 ratio
      // Image takes up 2/5 of the total width (based on flex 3:2 ratio)
      double imageWidth = (constraints.maxWidth * 2 / 5) - 48; // minus padding
      double imageHeight = imageWidth; // 1:1 ratio

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column with title, program items, and buttons
          Expanded(
            flex: 3,
            child: _buildTabletTitleAndContent(context, imageHeight),
          ),

          GapW(48),

          // Right column with image fixed by width with 1:1 ratio
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 8),
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: imageWidth,
                height: imageWidth,
                child: Image.asset(
                  ProgramService.getProgramImage(program.id),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  // Helper method to build the left column content for tablet layout
  // Added imageHeight parameter to adjust the gap to match total height
  Widget _buildTabletTitleAndContent(
      BuildContext context, double? imageHeight) {
    // Measure the content heights
    return LayoutBuilder(builder: (context, constraints) {
      // Title height is estimated based on font size and line height
      double titleHeight = 18 * 1.2; // fontSize * lineHeight
      double titleGapHeight = 8; // Gap after title

      // Calculate estimated height of all program items
      final GlobalKey _itemsKey = GlobalKey();
      final itemsWidget = Column(
        key: _itemsKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            program.items.map((item) => ProgramItemWidget(item: item)).toList(),
      );

      // Estimate program items height based on line count
      double itemLineHeight = 15 * 1.2; // fontSize * lineHeight
      double totalItemsHeight = program.items.length *
          (itemLineHeight + 12); // Item height + vertical padding

      // Button height
      double buttonHeight = 42;

      // Total content height without the adjustable gap
      double contentHeightWithoutGap =
          titleHeight + titleGapHeight + totalItemsHeight + buttonHeight;

      // Determine the gap needed to match the image height
      double adjustableGap = 16; // Default gap

      if (imageHeight != null) {
        // Calculate how much gap we need to make content height equal to image height
        adjustableGap = imageHeight - contentHeightWithoutGap;
        // Ensure we don't have a negative gap
        adjustableGap = adjustableGap > 12 ? adjustableGap : 12;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Title
          Row(
            children: [
              Flexible(
                child: Text(
                  program.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          GapH(8),

          // Program Items
          itemsWidget,

          // Adjustable gap
          GapH(adjustableGap),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    SubscriptionNavigationMixin.navigationKey.currentState
                        ?.pushNamed(NavigatorName.package_program_detail,
                            arguments: {'program': program});
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: R.color.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: R.color.greenGradientBottom,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        R.string.more.tr(),
                        style: TextStyle(
                          color: R.color.greenGradientBottom,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GapW(12),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () async {
                    await notifySubscriptionSuccess(context);
                    ProgramService.showPopupRequestConsultSubscription(
                      context: context,
                      title: R.string.receive_consult_request_title.tr(),
                      subtitle: R.string.receive_consult_request_subtitle.tr(),
                      isShowImg: true,
                      primaryButtonTitle: R.string.back_home_page.tr(),
                      secondaryButtonTitle: R.string.support.tr(),
                      onNavigateHome: () {
                        Navigator.of(context, rootNavigator: true)
                            .pushNamedAndRemoveUntil(
                          NavigatorName.tabbar,
                          (route) =>
                              false, // This removes all routes from stack
                        );
                      },
                      onContact: () async {
                        final launchUri =
                            Uri(scheme: 'tel', path: Const.HOTLINE_NUMBER);
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        } else {
                          throw 'Could not make phone call ${Const.HOTLINE_NUMBER}';
                        }
                      },
                    );
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          R.color.greenGradientTop02,
                          R.color.greenGradientBottom,
                          R.color.greenGradientBottom,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(200),
                    ),
                    child: Center(
                      child: Text(
                        R.string.consult_request.tr(),
                        style: TextStyle(
                          color: R.color.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class ProgramItemWidget extends StatelessWidget {
  final ProgramItem item;

  const ProgramItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 6),
            child: Image.asset(
              R.drawable.subscription_bullet,
              width: 6,
              height: 6,
            ),
          ),
          GapW(8),
          Expanded(
            child: Text(
              item.description,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: R.color.color0xff111515,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
