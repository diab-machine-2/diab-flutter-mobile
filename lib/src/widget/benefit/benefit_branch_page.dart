import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/response/search_list_clinic_response.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/dsmes_appointment/dsmes_appointment_cubit.dart';
import 'package:medical/src/widget/benefit/benefit_navigator_scope.dart';
import 'package:medical/src/widgets/gap_widget.dart';

/// Branch selection page for the Benefit booking flow.
///
/// Shows a list of branches from the clinic's clusters for the user to select.
/// The selected branch name + address will be appended to the booking note.
class BenefitBranchPage extends StatefulWidget {
  final String serviceType;
  final String action;
  final int? appointmentId;
  final String bookingType;
  final bool isBypassPayment;
  final String? specialtyName;
  final String? itemId;
  final int? itemType;

  const BenefitBranchPage({
    Key? key,
    required this.serviceType,
    this.action = 'create',
    this.appointmentId,
    this.bookingType = Const.BOOKING_TYPE_CLINIC,
    this.isBypassPayment = false,
    this.specialtyName,
    this.itemId,
    this.itemType,
  }) : super(key: key);

  @override
  _BenefitBranchPageState createState() => _BenefitBranchPageState();
}

class _BenefitBranchPageState extends State<BenefitBranchPage> {
  BranchItem? _selectedBranch;

  /// Finds branches matching the selected clinic from the cubit's clusters.
  List<BranchItem> _getBranches() {
    final cubit = context.read<DsmesAppointmentCubit>();
    final clinicId = cubit.selectedClinic?.id;
    if (clinicId == null) return [];

    for (final cluster in cubit.listClinicClusters) {
      if (cluster.clinicId == clinicId) {
        return cluster.branches;
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final branches = _getBranches();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: R.color.backgroundColorNew),
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    R.color.greenGradientTop02,
                    R.color.greenGradientBottom
                  ],
                  stops: const [0.01, 0.99],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: CustomAppBar(
                backgroundColor: Colors.transparent,
                title: Text(
                  R.string.benefit_select_branch.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: R.color.white,
                  ),
                ),
                leadingIcon: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(Icons.arrow_back, color: R.color.white),
                  onPressed: () => BenefitNavigatorScope.popOrRoot(context),
                ),
              ),
            ),
            if (branches.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    R.string.benefit_no_branch_data.tr(),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: branches.length,
                  separatorBuilder: (_, __) => GapH(12),
                  itemBuilder: (_, index) {
                    final branch = branches[index];
                    final isSelected = _selectedBranch == branch;
                    return _buildBranchItem(branch, isSelected);
                  },
                ),
              ),
            // Confirm button
            Container(
              height: 74,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                boxShadow: [createBoxShadow()],
                color: R.color.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildConfirmButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchItem(BranchItem branch, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBranch = branch;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? R.color.greenGradientBottom : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            isSelected
                ? BoxShadow(
                    color: R.color.greenGradientBottom.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                : BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branch.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: R.color.color0xff111515,
                    ),
                  ),
                  GapH(6),
                  Text(
                    branch.address,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: R.color.color0xff636A6B,
                    ),
                  ),
                ],
              ),
            ),
            GapW(12),
            if (isSelected)
              SvgPicture.asset(
                R.icons.ic_benefit_selected,
                width: 20,
                height: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isEnabled = _selectedBranch != null;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              _onConfirm();
            }
          : null,
      child: Container(
        height: 44,
        decoration: isEnabled
            ? BoxDecoration(
                color: R.color.mainColor,
                borderRadius: BorderRadius.circular(200),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [
                    R.color.greenGradientTop,
                    R.color.greenGradientMid,
                    R.color.greenGradientBottom,
                  ],
                ),
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(200),
                color: R.color.color0xffC2C2C2,
              ),
        child: Center(
          child: Text(
            R.string.confirm.tr(),
            style: TextStyle(
              color: isEnabled ? R.color.white : R.color.grey200,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _onConfirm() {
    if (_selectedBranch == null) return;

    // Clear branches so the confirm route handler doesn't redirect to branch page again
    context.read<DsmesAppointmentCubit>().selectedClinicBranches = null;

    BenefitNavigatorScope.of(context).currentState?.pushNamed(
      NavigatorName.benefit_confirm_information,
      arguments: {
        'serviceType': widget.serviceType,
        'action': widget.action,
        'appointmentId': widget.appointmentId,
        'bookingType': widget.bookingType,
        'isBypassPayment': widget.isBypassPayment,
        'branchName': _selectedBranch!.name,
        'branchAddress': _selectedBranch!.address,
        'branchId': _selectedBranch!.clinicId,
        'specialtyName': widget.specialtyName,
        'itemId': widget.itemId,
        'itemType': widget.itemType,
      },
    );
  }

  BoxShadow createBoxShadow() {
    return BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, -2),
    );
  }
}
