// screens/package_program_detail_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class ProgramDetailPage extends StatefulWidget {
  final PackageProgram program;

  const ProgramDetailPage({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAudienceSection(),
                      GapH(20),
                      _buildTargetSection(),
                      GapH(20),
                      _buildActionSection(),
                      GapH(100),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: R.color.white,
                      boxShadow: [Utils.getBoxShadowDropButton()],
                    ),
                    child: _buildButton(
                      title: R.string.consult_request.tr(),
                      onTap: () async {
                        final subscriptionCubit =
                            BlocProvider.of<SubscriptionCubit>(context);

                        if (subscriptionCubit.selectedPackage == null) return;

                        final request = NotifySubscriptionRequest(
                            servicePackage:
                                subscriptionCubit.selectedPackage!.title,
                            programName: widget.program.title);
                        await subscriptionCubit.notifySubscriptionSuccess(request);
                        
                        ProgramService.showPopupRequestConsultSubscription(
                          context: context,
                          title: R.string.receive_consult_request_title.tr(),
                          subtitle:
                              R.string.receive_consult_request_subtitle.tr(),
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [R.color.greenGradientTop02, R.color.greenGradientBottom],
          stops: const [0.01, 0.99],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: CustomAppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.program.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: R.color.white,
          ),
        ),
        leadingIcon: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(
            Icons.arrow_back,
            color: R.color.white,
          ),
          onPressed: () {
            SubscriptionNavigationMixin.navigationKey.currentState?.pop();
          },
        ),
      ),
    );
  }

  Widget _buildAudienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
          child: Text(
            R.string.audience.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: R.color.color0xff111515,
            ),
          ),
        ),
        // Use LayoutBuilder to determine available height
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate card width
            final screenWidth = MediaQuery.of(context).size.width;
            double cardWidth = (screenWidth / 2) -
                18 -
                (widget.program.audiences.length > 2 ? 24 : 0); // 12 for margin

            // Calculate image height based on 4:3 ratio
            final imageHeight = (cardWidth * 3) / 4;

            // Text height calculation
            final fontSize = 15.0;
            final lineHeight = fontSize * 1.2;
            final twoLinesHeight =
                (lineHeight * 2) + 16 + 4; // 16 for padding, 4 for line spacing

            // Total card height
            final cardHeight = imageHeight + twoLinesHeight;

            return SizedBox(
              height: cardHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.program.audiences.length,
                itemBuilder: (context, index) {
                  return AudienceCard(
                    audience: widget.program.audiences[index],
                    cardWidth: cardWidth,
                    isLastItem: index == widget.program.audiences.length - 1,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTargetSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            R.string.target.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: R.color.color0xff111515,
            ),
          ),
        ),
        Column(
          children: [
            GapH(12),
            ...widget.program.targets.map((target) {
              return TargetCard(
                target: target,
                isLastItem: target.id == widget.program.targets.last.id,
                mainColor: widget.program.getProgramColor,
              );
            })
          ],
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Text(
            R.string.action.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: R.color.color0xff111515,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = MediaQuery.of(context).size.width;
              final crossAxisCount =
                  screenWidth >= Const.TABLET_BREAKPOINT ? 3 : 2;

              return GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.7 / 1, // Adjust height as needed
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: widget.program.actions.length,
                itemBuilder: (context, index) {
                  final action = widget.program.actions[index];
                  return ActionCard(
                    action: action,
                    mainColor: widget.program.getProgramColor,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        decoration: BoxDecoration(
          color: R.color.white,
        ),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
          child: Text(
            title,
            style: TextStyle(
                color: R.color.white,
                fontSize: 15,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class AudienceCard extends StatelessWidget {
  final ProgramAudience audience;
  final double cardWidth;
  final bool isLastItem;

  const AudienceCard({
    Key? key,
    required this.audience,
    required this.cardWidth,
    this.isLastItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate image height to maintain 4:3 aspect ratio
    final imageHeight = (cardWidth * 3) / 4;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(left: 12, right: isLastItem ? 12 : 0),
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          Utils.getBoxShadowDropCard(),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Only take up necessary space
        children: [
          // Image container with ClipRRect to respect border radius
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              width: cardWidth,
              height: imageHeight,
              child: Image.asset(
                ProgramService.getAudienceImageResource(audience.id),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Title with padding
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: Text(
                audience.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: R.color.color0xff111515,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TargetCard extends StatelessWidget {
  final ProgramTarget target;
  final bool isLastItem;
  final Color mainColor;

  const TargetCard({
    Key? key,
    required this.target,
    this.isLastItem = false,
    required this.mainColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, isLastItem ? 0 : 12),
      decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: BorderDirectional(
            end: BorderSide(
              color: mainColor,
              width: 3,
            ),
          ),
          boxShadow: [
            Utils.getBoxShadowDropCard(),
          ]),
      child: Row(
        children: [
          GapW(8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.asset(
              ProgramService.getTargetImageResource(target.id),
              width: 30,
              height: 30,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text(
                target.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: R.color.color0xff111515,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final ProgramAction action;
  final Color mainColor;

  const ActionCard({
    Key? key,
    required this.action,
    required this.mainColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Card container
        Container(
          margin: const EdgeInsets.only(top: 28),
          padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
          decoration: BoxDecoration(
            color: mainColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    action.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: R.color.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Image.asset(
            ProgramService.getActionImageResource(action.id),
            width: 40,
            height: 40,
          ),
        ),
      ],
    );
  }
}
